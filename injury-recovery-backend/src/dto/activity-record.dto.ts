// src/dto/activity-record.dto.ts
// DTO representing an activity record

import { JointMeasurements } from '../config/action-mapping.config';

/**
 * Represents a stored activity record
 */
export class ActivityRecordDto {
    /** Unique identifier */
    id: string;

    /** The action name that was performed */
    actionName: string;

    /** Measurement configuration for each joint */
    measurements: JointMeasurements;

    /** ISO 8601 timestamp when the activity was recorded */
    timestamp: string;

    constructor(
        id: string,
        actionName: string,
        measurements: JointMeasurements,
        timestamp: string,
    ) {
        this.id = id;
        this.actionName = actionName;
        this.measurements = measurements;
        this.timestamp = timestamp;
    }
}
