import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { VOMASModule } from './injury-recovery.module';
import { ActivitiesModule } from './activities/activities.module';

@Module({
  imports: [VOMASModule, ActivitiesModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule { }

