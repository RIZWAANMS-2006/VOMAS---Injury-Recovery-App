import { Injectable, Logger } from '@nestjs/common';

@Injectable()
export class VOMASService {
  private readonly logger = new Logger(VOMASService.name);
  private calibrationRequested = false;

  /**
   * Records a calibration request from the client
   */
  requestCalibration(): { success: boolean; message: string } {
    this.logger.log(
      'Calibration requested by client. Waiting for IoT polling...',
    );
    this.calibrationRequested = true;

    return {
      success: true,
      message: 'Calibration request queued for IoT device',
    };
  }

  /**
   * Called by IoT device polling to check if calibration is needed
   * Returns "true" if requested (and resets flag), "none" otherwise.
   */
  checkCalibrationStatus(): { calibrate: string } {
    if (this.calibrationRequested) {
      this.logger.log('IoT device polled: Sending calibration signal.');
      this.calibrationRequested = false; // "Ack" - reset after sending
      return { calibrate: 'true' };
    }

    return { calibrate: 'none' };
  }
}
