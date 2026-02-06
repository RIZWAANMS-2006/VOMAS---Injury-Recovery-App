import { WebSocketGateway, WebSocketServer, SubscribeMessage, MessageBody, ConnectedSocket } from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { AnglesDto, FilteredAnglesOutput, FilteredJointMeasurement } from './dto/debug-angles.dto';
import { getMeasurementsForAction, MeasurementType } from './config/action-mapping.config';
import { VOMASService } from './injury-recovery.service';

@WebSocketGateway({ cors: { origin: '*' } })
export class VOMASGateway {
  constructor(private readonly vomasService: VOMASService) {}
  @WebSocketServer()
  server: Server;

  // Store latest full angle data
  private latestAngles: AnglesDto | null = null;

  // Track each client's selected action
  private clientActions: Map<string, string> = new Map();

  afterInit() {
    console.log('Socket.IO server initialized');
  }

  handleConnection(client: Socket) {
    console.log('Client connected:', client.id);
  }

  handleDisconnect(client: Socket) {
    console.log('Client disconnected:', client.id);
    // Clean up client action on disconnect
    this.clientActions.delete(client.id);
  }

  /**
   * Handle calibration request from client
   */
  @SubscribeMessage('calibrate')
  async handleCalibrate(@ConnectedSocket() client: Socket) {
    console.log(`Calibration request received from client ${client.id}`);
    
    const result = await this.vomasService.calibrateIotDevice();
    
    // Emit acknowledgment back to client
    client.emit('calibration-acknowledged', result);
    
    return result;
  }

  /**
   * Client registers their selected action
   */
  @SubscribeMessage('select-action')
  handleSelectAction(
    @ConnectedSocket() client: Socket,
    @MessageBody() actionName: string,
  ) {
    console.log(`Client ${client.id} selected action: ${actionName}`);
    this.clientActions.set(client.id, actionName);

    // If we have angle data, immediately send filtered data to this client
    if (this.latestAngles) {
      const filteredData = this.filterAnglesForAction(this.latestAngles, actionName);
      if (filteredData) {
        client.emit('angles-update', filteredData);
      }
    }

    return { status: 'action-registered', action: actionName };
  }

  /**
   * Receive full angle data and broadcast filtered data to each client
   */
  receiveAndBroadcastAngles(angles: AnglesDto) {
    this.latestAngles = angles;
    console.log(`\n--- Processing Angle Data ---`);
    console.log(`Total clients with actions: ${this.clientActions.size}`);

    // Broadcast filtered data to each connected client based on their action
    this.clientActions.forEach((actionName, clientId) => {
      const client = this.server.sockets.sockets.get(clientId);
      if (client) {
        const filteredData = this.filterAnglesForAction(angles, actionName);
        if (filteredData) {
          console.log(`-> Emitting to client ${clientId} (Action: ${actionName})`);
          client.emit('angles-update', filteredData);
        } else {
          console.log(`-> Start filtering failed for action: ${actionName}`);
        }
      } else {
        console.log(`-> Client ${clientId} socket object not found in server instance`);
      }
    });
  }

  /**
   * Filter angle data based on action mapping
   */
  private filterAnglesForAction(angles: AnglesDto, actionName: string): FilteredAnglesOutput | null {
    const mapping = getMeasurementsForAction(actionName);
    if (!mapping) {
      console.log(`Invalid action: ${actionName}`);
      return null;
    }

    const getJointMeasurement = (
      joint: 'shoulder' | 'elbow' | 'wrist',
      type: MeasurementType,
    ): FilteredJointMeasurement => {
      const jointData = angles[joint];
      const measurementData = jointData[type];
      return {
        angle: measurementData.angle,
        speed: measurementData.speed ?? 0,
        type: type,
      };
    };

    return {
      shoulder: getJointMeasurement('shoulder', mapping.shoulder),
      elbow: getJointMeasurement('elbow', mapping.elbow),
      wrist: getJointMeasurement('wrist', mapping.wrist),
    };
  }
}

