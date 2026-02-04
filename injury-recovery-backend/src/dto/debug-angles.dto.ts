import { IsNumber, IsOptional, ValidateNested, IsObject } from 'class-validator';
import { Type } from 'class-transformer';

export class MeasurementData {
    @IsNumber()
    angle: number;

    @IsNumber()
    @IsOptional()
    speed?: number = 0;
}

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

export interface FilteredJointMeasurement {
    angle: number;
    speed: number;
    type: 'roll' | 'pitch' | 'yaw';
}

export interface FilteredAnglesOutput {
    shoulder: FilteredJointMeasurement;
    elbow: FilteredJointMeasurement;
    wrist: FilteredJointMeasurement;
}
