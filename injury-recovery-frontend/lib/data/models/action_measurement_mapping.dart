// lib/data/models/action_measurement_mapping.dart
// Contains the action → measurement mapping as specified

import 'action_type.dart';

/// Measurement type for each joint (Roll, Pitch, or Yaw)
enum MeasurementType { roll, pitch, yaw }

/// Extension for MeasurementType display name
extension MeasurementTypeExtension on MeasurementType {
  String get displayName {
    switch (this) {
      case MeasurementType.roll:
        return 'Roll';
      case MeasurementType.pitch:
        return 'Pitch';
      case MeasurementType.yaw:
        return 'Yaw';
    }
  }
}

/// Model representing the measurement configuration for a specific action
class ActionMeasurement {
  final MeasurementType shoulder;
  final MeasurementType elbow;
  final MeasurementType wrist;

  const ActionMeasurement({
    required this.shoulder,
    required this.elbow,
    required this.wrist,
  });

  /// Converts to a map for display purposes
  Map<String, String> toDisplayMap() {
    return {
      'Shoulder': shoulder.displayName,
      'Elbow': elbow.displayName,
      'Wrist': wrist.displayName,
    };
  }
}

/// The exact mapping provided by the user
/// Maps each ActionType to its corresponding Shoulder, Elbow, Wrist measurements
///
/// **DEPRECATED**: This is now a fallback. The backend is the single source of truth.
/// Use [ActionMappingService] to get mappings from the backend.
/// This local mapping is kept for offline functionality.
@Deprecated('Use ActionMappingService to fetch mappings from backend')
const Map<ActionType, ActionMeasurement> actionMeasurementMapping = {
  // Flexion / Extension
  ActionType.flexionExtension: ActionMeasurement(
    shoulder: MeasurementType.roll,
    elbow: MeasurementType.roll,
    wrist: MeasurementType.pitch,
  ),

  // Abduction
  ActionType.abduction: ActionMeasurement(
    shoulder: MeasurementType.roll,
    elbow: MeasurementType.roll,
    wrist: MeasurementType.pitch,
  ),

  // Internal / External Rotation
  ActionType.internalExternalRotation: ActionMeasurement(
    shoulder: MeasurementType.pitch,
    elbow: MeasurementType.roll,
    wrist: MeasurementType.pitch,
  ),

  // Horizontal Abduction / Adduction
  ActionType.horizontalAbductionAdduction: ActionMeasurement(
    shoulder: MeasurementType.yaw,
    elbow: MeasurementType.roll,
    wrist: MeasurementType.pitch,
  ),

  // Forearm Pronation / Supination
  ActionType.forearmPronationSupination: ActionMeasurement(
    shoulder: MeasurementType.roll,
    elbow: MeasurementType.roll,
    wrist: MeasurementType.roll,
  ),

  // Radial / Ulnar Deviation
  ActionType.radialUlnarDeviation: ActionMeasurement(
    shoulder: MeasurementType.roll,
    elbow: MeasurementType.roll,
    wrist: MeasurementType.yaw,
  ),
};

/// Helper function to get measurement for a specific action
ActionMeasurement getMeasurementForAction(ActionType action) {
  return actionMeasurementMapping[action] ??
      const ActionMeasurement(
        shoulder: MeasurementType.roll,
        elbow: MeasurementType.roll,
        wrist: MeasurementType.roll,
      );
}
