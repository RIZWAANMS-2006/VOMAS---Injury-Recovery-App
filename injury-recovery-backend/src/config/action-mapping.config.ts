// src/config/action-mapping.config.ts
// Single source of truth for action → measurement mappings

/**
 * Valid action names that the API accepts
 */
export const VALID_ACTIONS = [
    'Flexion / Extension',
    'Abduction',
    'Internal / External Rotation',
    'Horizontal Abduction / Adduction',
    'Forearm Pronation / Supination',
    'Radial / Ulnar Deviation',
] as const;

export type ActionName = (typeof VALID_ACTIONS)[number];

/**
 * Measurement types for each joint (lowercase to match JSON keys)
 */
export type MeasurementType = 'roll' | 'pitch' | 'yaw';

/**
 * Joint measurement configuration
 */
export interface JointMeasurements {
    shoulder: MeasurementType;
    elbow: MeasurementType;
    wrist: MeasurementType;
}

/**
 * The action → measurement mapping as specified in the requirements
 */
export const ACTION_MEASUREMENT_MAPPING: Record<ActionName, JointMeasurements> =
{
    'Flexion / Extension': {
        shoulder: 'roll',
        elbow: 'roll',
        wrist: 'pitch',
    },
    Abduction: {
        shoulder: 'roll',
        elbow: 'roll',
        wrist: 'pitch',
    },
    'Internal / External Rotation': {
        shoulder: 'pitch',
        elbow: 'roll',
        wrist: 'pitch',
    },
    'Horizontal Abduction / Adduction': {
        shoulder: 'yaw',
        elbow: 'roll',
        wrist: 'pitch',
    },
    'Forearm Pronation / Supination': {
        shoulder: 'roll',
        elbow: 'roll',
        wrist: 'roll',
    },
    'Radial / Ulnar Deviation': {
        shoulder: 'roll',
        elbow: 'roll',
        wrist: 'yaw',
    },
};

/**
 * Validates if an action name is valid
 */
export function isValidAction(actionName: string): actionName is ActionName {
    return VALID_ACTIONS.includes(actionName as ActionName);
}

/**
 * Gets the measurement configuration for an action
 * Returns undefined if action is invalid
 */
export function getMeasurementsForAction(
    actionName: string,
): JointMeasurements | undefined {
    if (!isValidAction(actionName)) {
        return undefined;
    }
    return ACTION_MEASUREMENT_MAPPING[actionName];
}

