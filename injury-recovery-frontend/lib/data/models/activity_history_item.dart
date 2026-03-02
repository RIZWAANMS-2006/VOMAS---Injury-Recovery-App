// lib/data/models/activity_history_item.dart
// Model for storing activity history entries with session data

import 'dart:convert';

import 'action_type.dart';
import 'action_measurement_mapping.dart';

/// A single data point recorded during a session
class SessionDataPoint {
  /// Angle values for each joint
  final double shoulderAngle;
  final double elbowAngle;
  final double wristAngle;

  /// Speed values for each joint
  final double shoulderSpeed;
  final double elbowSpeed;
  final double wristSpeed;

  /// When this data point was recorded
  final DateTime recordedAt;

  const SessionDataPoint({
    required this.shoulderAngle,
    required this.shoulderSpeed,
    required this.elbowAngle,
    required this.elbowSpeed,
    required this.wristAngle,
    required this.wristSpeed,
    required this.recordedAt,
  });

  /// Create from JSON
  factory SessionDataPoint.fromJson(Map<String, dynamic> json) {
    return SessionDataPoint(
      shoulderAngle: (json['shoulderAngle'] as num).toDouble(),
      shoulderSpeed: (json['shoulderSpeed'] as num).toDouble(),
      elbowAngle: (json['elbowAngle'] as num).toDouble(),
      elbowSpeed: (json['elbowSpeed'] as num).toDouble(),
      wristAngle: (json['wristAngle'] as num).toDouble(),
      wristSpeed: (json['wristSpeed'] as num).toDouble(),
      recordedAt: DateTime.parse(json['recordedAt'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'shoulderAngle': shoulderAngle,
      'shoulderSpeed': shoulderSpeed,
      'elbowAngle': elbowAngle,
      'elbowSpeed': elbowSpeed,
      'wristAngle': wristAngle,
      'wristSpeed': wristSpeed,
      'recordedAt': recordedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'SessionDataPoint(sh:$shoulderAngle/$shoulderSpeed, el:$elbowAngle/$elbowSpeed, wr:$wristAngle/$wristSpeed)';
  }
}

/// Represents a single activity history entry (session-based)
class ActivityHistoryItem {
  /// Unique identifier for this history item
  final String id;

  /// The action type that was selected (for UI/local use)
  final ActionType actionType;

  /// The action name string (for API compatibility)
  final String actionName;

  /// The measurement configuration for this action
  final Map<String, String> measurements;

  /// When the session started (Connect pressed)
  final DateTime timestamp;

  /// When the session ended (Stop/Back pressed), null if still active
  final DateTime? endTime;

  /// All data points recorded during this session
  final List<SessionDataPoint> dataPoints;

  ActivityHistoryItem({
    required this.id,
    required this.actionType,
    String? actionName,
    required this.measurements,
    required this.timestamp,
    this.endTime,
    List<SessionDataPoint>? dataPoints,
  }) : actionName = actionName ?? actionType.displayName,
       dataPoints = dataPoints ?? [];

  /// Session duration (null if session not finalized)
  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(timestamp);
  }

  /// Formatted duration string (e.g., "2m 30s")
  String get formattedDuration {
    final d = duration;
    if (d == null) return 'In progress';
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  /// Number of data points recorded
  int get readingsCount => dataPoints.length;

  /// Whether this session has been finalized
  bool get isFinalized => endTime != null;

  /// Factory constructor to create from ActionType (session start)
  factory ActivityHistoryItem.startSession(ActionType action) {
    final measurement = getMeasurementForAction(action);
    return ActivityHistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      actionType: action,
      actionName: action.displayName,
      measurements: measurement.toDisplayMap(),
      timestamp: DateTime.now(),
      dataPoints: [],
    );
  }

  /// Legacy factory for backward compatibility
  factory ActivityHistoryItem.fromAction(ActionType action) {
    return ActivityHistoryItem.startSession(action);
  }

  /// Creates a finalized copy with endTime set
  ActivityHistoryItem finalize() {
    return ActivityHistoryItem(
      id: id,
      actionType: actionType,
      actionName: actionName,
      measurements: measurements,
      timestamp: timestamp,
      endTime: DateTime.now(),
      dataPoints: dataPoints,
    );
  }

  /// Creates an ActivityHistoryItem from local storage JSON
  factory ActivityHistoryItem.fromJson(Map<String, dynamic> json) {
    return ActivityHistoryItem(
      id: json['id'] as String,
      actionType: ActionTypeExtension.fromStorageKey(
        json['actionType'] as String,
      ),
      actionName:
          json['actionName'] as String? ??
          ActionTypeExtension.fromStorageKey(
            json['actionType'] as String,
          ).displayName,
      measurements: Map<String, String>.from(json['measurements'] as Map),
      timestamp: DateTime.parse(json['timestamp'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      dataPoints: json['dataPoints'] != null
          ? (json['dataPoints'] as List)
                .map(
                  (e) => SessionDataPoint.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : [],
    );
  }

  /// Creates an ActivityHistoryItem from backend API JSON response
  /// Backend uses actionName string, not actionType enum
  factory ActivityHistoryItem.fromApiJson(Map<String, dynamic> json) {
    final actionName = json['actionName'] as String;
    final measurements = json['measurements'] as Map<String, dynamic>;

    // Convert actionName to ActionType
    final actionType = ActionTypeExtension.fromDisplayName(actionName);

    return ActivityHistoryItem(
      id: json['id'] as String,
      actionType: actionType,
      actionName: actionName,
      measurements: Map<String, String>.from(measurements),
      timestamp: DateTime.parse(json['timestamp'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      dataPoints: json['dataPoints'] != null
          ? (json['dataPoints'] as List)
                .map(
                  (e) => SessionDataPoint.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : [],
    );
  }

  /// Converts to JSON map for local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'actionType': actionType.storageKey,
      'actionName': actionName,
      'measurements': measurements,
      'timestamp': timestamp.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'dataPoints': dataPoints.map((e) => e.toJson()).toList(),
    };
  }

  /// Formatted date string for display (e.g., "Feb 1, 2026")
  String get formattedDate {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[timestamp.month - 1]} ${timestamp.day}, ${timestamp.year}';
  }

  /// Formatted time string for display (e.g., "6:30 PM")
  String get formattedTime {
    final hour = timestamp.hour > 12 ? timestamp.hour - 12 : timestamp.hour;
    final displayHour = hour == 0 ? 12 : hour;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = timestamp.hour >= 12 ? 'PM' : 'AM';
    return '$displayHour:$minute $period';
  }

  /// Full formatted date and time
  String get formattedDateTime => '$formattedDate at $formattedTime';

  @override
  String toString() {
    return 'ActivityHistoryItem(action: ${actionType.displayName}, time: $formattedDateTime, readings: $readingsCount, duration: $formattedDuration)';
  }
}

/// Helper to encode list of ActivityHistoryItem to JSON string
String encodeHistoryList(List<ActivityHistoryItem> items) {
  return jsonEncode(items.map((e) => e.toJson()).toList());
}

/// Helper to decode JSON string to list of ActivityHistoryItem
List<ActivityHistoryItem> decodeHistoryList(String jsonString) {
  if (jsonString.isEmpty) return [];
  final List<dynamic> jsonList = jsonDecode(jsonString);
  return jsonList.map((e) => ActivityHistoryItem.fromJson(e)).toList();
}
