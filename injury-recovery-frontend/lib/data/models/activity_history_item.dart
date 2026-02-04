// lib/data/models/activity_history_item.dart
// Model for storing activity history entries

import 'dart:convert';

import 'action_type.dart';
import 'action_measurement_mapping.dart';

/// Represents a single activity history entry
class ActivityHistoryItem {
  /// Unique identifier for this history item
  final String id;

  /// The action type that was selected (for UI/local use)
  final ActionType actionType;

  /// The action name string (for API compatibility)
  final String actionName;

  /// The measurement configuration for this action
  final Map<String, String> measurements;

  /// When this activity was recorded
  final DateTime timestamp;

  ActivityHistoryItem({
    required this.id,
    required this.actionType,
    String? actionName,
    required this.measurements,
    required this.timestamp,
  }) : actionName = actionName ?? actionType.displayName;

  /// Factory constructor to create from ActionType (local creation)
  factory ActivityHistoryItem.fromAction(ActionType action) {
    final measurement = getMeasurementForAction(action);
    return ActivityHistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      actionType: action,
      actionName: action.displayName,
      measurements: measurement.toDisplayMap(),
      timestamp: DateTime.now(),
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
    return 'ActivityHistoryItem(action: ${actionType.displayName}, time: $formattedDateTime)';
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
