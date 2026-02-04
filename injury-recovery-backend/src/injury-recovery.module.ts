import { Module } from '@nestjs/common';
import { VOMASController } from './injury-recovery.controller';
import { VOMASGateway } from './injury-recovery.gateway';

@Module({
  controllers: [VOMASController],
  providers: [VOMASGateway],
})
export class VOMASModule { }
