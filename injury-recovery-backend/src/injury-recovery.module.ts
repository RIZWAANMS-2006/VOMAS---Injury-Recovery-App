import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { VOMASController } from './injury-recovery.controller';
import { VOMASGateway } from './injury-recovery.gateway';
import { VOMASService } from './injury-recovery.service';

@Module({
  imports: [HttpModule],
  controllers: [VOMASController],
  providers: [VOMASGateway, VOMASService],
})
export class VOMASModule { }
