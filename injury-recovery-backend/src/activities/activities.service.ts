// src/activities/activities.service.ts
// Service layer for activity management

import { Injectable } from '@nestjs/common';
import { ActivityRecordDto } from '../dto/activity-record.dto';
import {
    ACTION_MEASUREMENT_MAPPING,
    isValidAction,
    getMeasurementsForAction,
    ActionName,
} from '../config/action-mapping.config';

/**
 * Service for managing activities
 * Uses in-memory storage for demo purposes
 */
@Injectable()
export class ActivitiesService {
    // In-memory storage for activities
    private activities: ActivityRecordDto[] = [];

    /**
     * Create a new activity from an action name
     * @param actionName - The name of the action
     * @returns The created activity record, or null if action is invalid
     */
    createActivity(actionName: string): ActivityRecordDto | null {
        // Validate action name
        if (!isValidAction(actionName)) {
            return null;
        }

        // Get measurements for this action
        const measurements = getMeasurementsForAction(actionName);
        if (!measurements) {
            return null;
        }

        // Generate unique ID and timestamp
        const id = this.generateId();
        const timestamp = new Date().toISOString();

        // Create the activity record
        const activity = new ActivityRecordDto(
            id,
            actionName,
            measurements,
            timestamp,
        );

        // Store the activity
        this.activities.unshift(activity); // Add to beginning (most recent first)

        return activity;
    }

    /**
     * Get all activities, sorted by most recent first
     */
    findAll(): ActivityRecordDto[] {
        return [...this.activities];
    }

    /**
     * Get the action → measurement mapping
     */
    getActionMappings(): Record<string, { shoulder: string; elbow: string; wrist: string }> {
        return { ...ACTION_MEASUREMENT_MAPPING };
    }

    /**
     * Get list of valid action names
     */
    getValidActions(): ActionName[] {
        return Object.keys(ACTION_MEASUREMENT_MAPPING) as ActionName[];
    }

    /**
     * Generate a unique ID for an activity
     */
    private generateId(): string {
        return `${Date.now()}-${Math.random().toString(36).substring(2, 9)}`;
    }

    /**
     * Clear all activities (useful for testing)
     */
    clearActivities(): void {
        this.activities = [];
    }
}
