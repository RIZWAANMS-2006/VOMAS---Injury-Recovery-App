import { Controller, Post, Body, Inject } from '@nestjs/common';
import { VOMASGateway } from './injury-recovery.gateway';
import { AnglesDto } from './dto/debug-angles.dto';

@Controller('VOMAS')
export class VOMASController {
  constructor(
    @Inject(VOMASGateway)
    private readonly gateway: VOMASGateway,
  ) { }

  @Post('angles')
  async receiveAngles(@Body() angles: AnglesDto) {
    // Broadcast filtered data to all connected clients based on their selected action
    this.gateway.receiveAndBroadcastAngles(angles);
    return { status: 'received', message: 'Angles broadcasted to connected clients' };
  }
}


