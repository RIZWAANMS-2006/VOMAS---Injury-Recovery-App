import { Controller, Post, Body, Inject, Get } from '@nestjs/common';
import { VOMASGateway } from './injury-recovery.gateway';
import { VOMASService } from './injury-recovery.service';
import { AnglesDto } from './dto/debug-angles.dto';

@Controller('VOMAS')
export class VOMASController {
  constructor(
    private readonly gateway: VOMASGateway,
    private readonly vomasService: VOMASService,
  ) {}

  @Get('calibration-check')
  checkCalibration() {
    return this.vomasService.checkCalibrationStatus();
  }

  @Post('angles')
  async receiveAngles(@Body() angles: AnglesDto) {
    // Broadcast filtered data to all connected clients based on their selected action
    this.gateway.receiveAndBroadcastAngles(angles);
    return {
      status: 'received',
      message: 'Angles broadcasted to connected clients',
    };
  }
}
