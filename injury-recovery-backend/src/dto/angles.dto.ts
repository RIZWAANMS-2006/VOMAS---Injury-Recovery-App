import { IsNumber, IsOptional, ValidateNested, IsObject } from 'class-validator';
import { Type } from 'class-transformer';

/**
 * Single measurement data (angle + speed)
 */
export class MeasurementData {
  @IsNumber()
  angle: number;

  @IsNumber()
  @IsOptional()
  speed?: number = 0;
}

/**
 * Joint data with roll, pitch, yaw measurements
 */
export class JointData {
  @ValidateNested()
  @Type(() => MeasurementData)
  @IsObject()
  roll: MeasurementData;

  @ValidateNested()
  @Type(() => MeasurementData)
  @IsObject()
  pitch: MeasurementData;

  @ValidateNested()
  @Type(() => MeasurementData)
  @IsObject()
  yaw: MeasurementData;
}

/**
 * Full angle data from sensor (input format)
 */
export class AnglesDto {
  @ValidateNested()
  @Type(() => JointData)
  @IsObject()
  shoulder: JointData;

  @ValidateNested()
  @Type(() => JointData)
  @IsObject()
  elbow: JointData;

  @ValidateNested()
  @Type(() => JointData)
  @IsObject()
  wrist: JointData;
}

/**
 * Filtered measurement output per joint
 */
export interface FilteredJointMeasurement {
  angle: number;
  speed: number;
  type: 'roll' | 'pitch' | 'yaw';
}

/**
 * Filtered angles output (sent to clients)
 */
export interface FilteredAnglesOutput {
  shoulder: FilteredJointMeasurement;
  elbow: FilteredJointMeasurement;
  wrist: FilteredJointMeasurement;
}

