// lib/data/models/activity_history_item.dart
// Model for storing activity history entries with session data

import 'dart:convert';

/// Joint data with angle and speed
class JointData {
  final double angle;
  final double speed;

  const JointData({required this.angle, required this.speed});

  factory JointData.fromJson(Map<String, dynamic> json) {
    return JointData(
      angle: (json['angle'] as num).toDouble(),
      speed: (json['speed'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'angle': angle,
      'speed': speed,
    };
  }
}

/// A single data point recorded during a session
class SessionDataPoint {
  final JointData shoulder;
  final JointData elbow;
  final JointData wrist;
  final DateTime recordedAt;

  const SessionDataPoint({
    required this.shoulder,
    required this.elbow,
    required this.wrist,
    required this.recordedAt,
  });

  /// Create from JSON (supports legacy flat fields)
  factory SessionDataPoint.fromJson(Map<String, dynamic> json) {
    if (json['shoulder'] is Map && json['elbow'] is Map && json['wrist'] is Map) {
      return SessionDataPoint(
        shoulder: JointData.fromJson(
          Map<String, dynamic>.from(json['shoulder'] as Map),
        ),
        elbow: JointData.fromJson(
          Map<String, dynamic>.from(json['elbow'] as Map),
        ),
        wrist: JointData.fromJson(
          Map<String, dynamic>.from(json['wrist'] as Map),
        ),
        recordedAt: DateTime.parse(json['recordedAt'] as String),
      );
    }

    return SessionDataPoint(
      shoulder: JointData(
        angle: (json['shoulderAngle'] as num).toDouble(),
        speed: (json['shoulderSpeed'] as num).toDouble(),
      ),
      elbow: JointData(
        angle: (json['elbowAngle'] as num).toDouble(),
        speed: (json['elbowSpeed'] as num).toDouble(),
      ),
      wrist: JointData(
        angle: (json['wristAngle'] as num).toDouble(),
        speed: (json['wristSpeed'] as num).toDouble(),
      ),
      recordedAt: DateTime.parse(json['recordedAt'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'shoulder': shoulder.toJson(),
      'elbow': elbow.toJson(),
      'wrist': wrist.toJson(),
      'recordedAt': recordedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'SessionDataPoint(sh:${shoulder.angle}/${shoulder.speed}, el:${elbow.angle}/${elbow.speed}, wr:${wrist.angle}/${wrist.speed})';
  }
}

/// Represents a single activity history entry (session-based)
class ActivityHistoryItem {
  /// Unique identifier for this history item
  final String id;

  /// User-friendly session name
  final String name;

  /// When the session started (Connect pressed)
  final DateTime timestamp;

  /// When the session ended (Stop/Back pressed), null if still active
  final DateTime? endTime;

  /// All data points recorded during this session, grouped by action name
  final Map<String, List<SessionDataPoint>> dataPoints;

  ActivityHistoryItem({
    required this.id,
    required this.name,
    required this.timestamp,
    this.endTime,
    Map<String, List<SessionDataPoint>>? dataPoints,
  }) : dataPoints = dataPoints ?? {};

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
  int get readingsCount => dataPoints.values.fold(
    0,
    (total, list) => total + list.length,
  );

  /// Whether this session has been finalized
  bool get isFinalized => endTime != null;

  /// Factory constructor to create a new session
  factory ActivityHistoryItem.startSession({required String name}) {
    return ActivityHistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      timestamp: DateTime.now(),
      dataPoints: {},
    );
  }

  /// Creates a finalized copy with endTime set
  ActivityHistoryItem finalize() {
    return ActivityHistoryItem(
      id: id,
      name: name,
      timestamp: timestamp,
      endTime: DateTime.now(),
      dataPoints: dataPoints,
    );
  }

  /// Creates an ActivityHistoryItem from local storage JSON
  factory ActivityHistoryItem.fromJson(Map<String, dynamic> json) {
    return ActivityHistoryItem(
      id: json['id'] as String,
      name:
          json['name'] as String? ??
          json['actionName'] as String? ??
          (json['actionType'] as String? ?? 'Session'),
      timestamp: DateTime.parse(json['timestamp'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      dataPoints: _parseDataPoints(json['dataPoints'], json),
    );
  }

  /// Creates an ActivityHistoryItem from backend API JSON response
  factory ActivityHistoryItem.fromApiJson(Map<String, dynamic> json) {
    return ActivityHistoryItem(
      id: json['id'] as String,
      name:
          json['name'] as String? ??
          json['actionName'] as String? ??
          'Session',
      timestamp: DateTime.parse(json['timestamp'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      dataPoints: _parseDataPoints(json['dataPoints'], json),
    );
  }

  /// Converts to JSON map for local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'timestamp': timestamp.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'dataPoints': dataPoints.map(
        (key, list) => MapEntry(key, list.map((e) => e.toJson()).toList()),
      ),
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
    return 'ActivityHistoryItem(name: $name, time: $formattedDateTime, readings: $readingsCount, duration: $formattedDuration)';
  }
}

Map<String, List<SessionDataPoint>> _parseDataPoints(
  dynamic rawDataPoints,
  Map<String, dynamic> json,
) {
  if (rawDataPoints is Map) {
    final map = Map<String, dynamic>.from(rawDataPoints as Map);
    return map.map(
      (key, value) => MapEntry(
        key,
        (value as List)
            .map((e) => SessionDataPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    );
  }

  if (rawDataPoints is List) {
    final name =
        json['name'] as String? ??
        json['actionName'] as String? ??
        (json['actionType'] as String? ?? 'Session');
    return {
      name: rawDataPoints
          .map((e) => SessionDataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    };
  }

  return {};
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
