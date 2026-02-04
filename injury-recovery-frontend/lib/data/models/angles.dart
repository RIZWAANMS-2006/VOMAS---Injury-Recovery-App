// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'angles.freezed.dart';
part 'angles.g.dart';

/// Single joint measurement with angle, speed, and measurement type
@freezed
abstract class JointMeasurement with _$JointMeasurement {
  const factory JointMeasurement({
    @JsonKey(name: 'angle') required double angle,
    @JsonKey(name: 'speed') @Default(0) double speed,
    @JsonKey(name: 'type') required String type, // 'roll', 'pitch', 'yaw'
  }) = _JointMeasurement;

  factory JointMeasurement.fromJson(Map<String, dynamic> json) =>
      _$JointMeasurementFromJson(json);
}

/// Filtered angles received from backend (per action)
@freezed
abstract class Angles with _$Angles {
  const factory Angles({
    @JsonKey(name: 'shoulder') required JointMeasurement shoulder,
    @JsonKey(name: 'elbow') required JointMeasurement elbow,
    @JsonKey(name: 'wrist') required JointMeasurement wrist,
  }) = _Angles;

  factory Angles.fromJson(Map<String, dynamic> json) => _$AnglesFromJson(json);
}
