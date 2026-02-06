import { Injectable, Logger } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class VOMASService {
  private readonly logger = new Logger(VOMASService.name);
  private readonly iotDeviceUrl = `${process.env.IOT_ADDRESS}/calibrate`; // Placeholder - Configure actual IP

  constructor(private readonly httpService: HttpService) {}

  /**
   * Sends a POST request to the IoT device to trigger calibration
   */
  async calibrateIotDevice(): Promise<{ success: boolean; message: string }> {
    try {
      this.logger.log('Sending calibration request to IoT device...');
      
      const response: any = await firstValueFrom(
        this.httpService.post(this.iotDeviceUrl, {
          command: 'calibrate',
        }),
      );

      this.logger.log(`IoT device responded: ${JSON.stringify(response.data)}`);
      
      return {
        success: true,
        message: 'Calibration request sent successfully',
      };
    } catch (error) {
      this.logger.error(`Failed to calibrate IoT device: ${error.message}`);
      
      return {
        success: false,
        message: `Calibration failed: ${error.message}`,
      };
    }
  }
}
