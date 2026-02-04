// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'angles.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_JointMeasurement _$JointMeasurementFromJson(Map<String, dynamic> json) =>
    _JointMeasurement(
      angle: (json['angle'] as num).toDouble(),
      speed: (json['speed'] as num?)?.toDouble() ?? 0,
      type: json['type'] as String,
    );

Map<String, dynamic> _$JointMeasurementToJson(_JointMeasurement instance) =>
    <String, dynamic>{
      'angle': instance.angle,
      'speed': instance.speed,
      'type': instance.type,
    };

_Angles _$AnglesFromJson(Map<String, dynamic> json) => _Angles(
  shoulder: JointMeasurement.fromJson(json['shoulder'] as Map<String, dynamic>),
  elbow: JointMeasurement.fromJson(json['elbow'] as Map<String, dynamic>),
  wrist: JointMeasurement.fromJson(json['wrist'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AnglesToJson(_Angles instance) => <String, dynamic>{
  'shoulder': instance.shoulder,
  'elbow': instance.elbow,
  'wrist': instance.wrist,
};
