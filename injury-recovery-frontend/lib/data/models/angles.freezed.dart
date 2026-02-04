// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'angles.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$JointMeasurement {

@JsonKey(name: 'angle') double get angle;@JsonKey(name: 'speed') double get speed;@JsonKey(name: 'type') String get type;
/// Create a copy of JointMeasurement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JointMeasurementCopyWith<JointMeasurement> get copyWith => _$JointMeasurementCopyWithImpl<JointMeasurement>(this as JointMeasurement, _$identity);

  /// Serializes this JointMeasurement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JointMeasurement&&(identical(other.angle, angle) || other.angle == angle)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,angle,speed,type);

@override
String toString() {
  return 'JointMeasurement(angle: $angle, speed: $speed, type: $type)';
}


}

/// @nodoc
abstract mixin class $JointMeasurementCopyWith<$Res>  {
  factory $JointMeasurementCopyWith(JointMeasurement value, $Res Function(JointMeasurement) _then) = _$JointMeasurementCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'angle') double angle,@JsonKey(name: 'speed') double speed,@JsonKey(name: 'type') String type
});




}
/// @nodoc
class _$JointMeasurementCopyWithImpl<$Res>
    implements $JointMeasurementCopyWith<$Res> {
  _$JointMeasurementCopyWithImpl(this._self, this._then);

  final JointMeasurement _self;
  final $Res Function(JointMeasurement) _then;

/// Create a copy of JointMeasurement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? angle = null,Object? speed = null,Object? type = null,}) {
  return _then(_self.copyWith(
angle: null == angle ? _self.angle : angle // ignore: cast_nullable_to_non_nullable
as double,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [JointMeasurement].
extension JointMeasurementPatterns on JointMeasurement {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JointMeasurement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JointMeasurement() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JointMeasurement value)  $default,){
final _that = this;
switch (_that) {
case _JointMeasurement():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JointMeasurement value)?  $default,){
final _that = this;
switch (_that) {
case _JointMeasurement() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'angle')  double angle, @JsonKey(name: 'speed')  double speed, @JsonKey(name: 'type')  String type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JointMeasurement() when $default != null:
return $default(_that.angle,_that.speed,_that.type);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'angle')  double angle, @JsonKey(name: 'speed')  double speed, @JsonKey(name: 'type')  String type)  $default,) {final _that = this;
switch (_that) {
case _JointMeasurement():
return $default(_that.angle,_that.speed,_that.type);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'angle')  double angle, @JsonKey(name: 'speed')  double speed, @JsonKey(name: 'type')  String type)?  $default,) {final _that = this;
switch (_that) {
case _JointMeasurement() when $default != null:
return $default(_that.angle,_that.speed,_that.type);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _JointMeasurement implements JointMeasurement {
  const _JointMeasurement({@JsonKey(name: 'angle') required this.angle, @JsonKey(name: 'speed') this.speed = 0, @JsonKey(name: 'type') required this.type});
  factory _JointMeasurement.fromJson(Map<String, dynamic> json) => _$JointMeasurementFromJson(json);

@override@JsonKey(name: 'angle') final  double angle;
@override@JsonKey(name: 'speed') final  double speed;
@override@JsonKey(name: 'type') final  String type;

/// Create a copy of JointMeasurement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JointMeasurementCopyWith<_JointMeasurement> get copyWith => __$JointMeasurementCopyWithImpl<_JointMeasurement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JointMeasurementToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JointMeasurement&&(identical(other.angle, angle) || other.angle == angle)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,angle,speed,type);

@override
String toString() {
  return 'JointMeasurement(angle: $angle, speed: $speed, type: $type)';
}


}

/// @nodoc
abstract mixin class _$JointMeasurementCopyWith<$Res> implements $JointMeasurementCopyWith<$Res> {
  factory _$JointMeasurementCopyWith(_JointMeasurement value, $Res Function(_JointMeasurement) _then) = __$JointMeasurementCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'angle') double angle,@JsonKey(name: 'speed') double speed,@JsonKey(name: 'type') String type
});




}
/// @nodoc
class __$JointMeasurementCopyWithImpl<$Res>
    implements _$JointMeasurementCopyWith<$Res> {
  __$JointMeasurementCopyWithImpl(this._self, this._then);

  final _JointMeasurement _self;
  final $Res Function(_JointMeasurement) _then;

/// Create a copy of JointMeasurement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? angle = null,Object? speed = null,Object? type = null,}) {
  return _then(_JointMeasurement(
angle: null == angle ? _self.angle : angle // ignore: cast_nullable_to_non_nullable
as double,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Angles {

@JsonKey(name: 'shoulder') JointMeasurement get shoulder;@JsonKey(name: 'elbow') JointMeasurement get elbow;@JsonKey(name: 'wrist') JointMeasurement get wrist;
/// Create a copy of Angles
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnglesCopyWith<Angles> get copyWith => _$AnglesCopyWithImpl<Angles>(this as Angles, _$identity);

  /// Serializes this Angles to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Angles&&(identical(other.shoulder, shoulder) || other.shoulder == shoulder)&&(identical(other.elbow, elbow) || other.elbow == elbow)&&(identical(other.wrist, wrist) || other.wrist == wrist));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,shoulder,elbow,wrist);

@override
String toString() {
  return 'Angles(shoulder: $shoulder, elbow: $elbow, wrist: $wrist)';
}


}

/// @nodoc
abstract mixin class $AnglesCopyWith<$Res>  {
  factory $AnglesCopyWith(Angles value, $Res Function(Angles) _then) = _$AnglesCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'shoulder') JointMeasurement shoulder,@JsonKey(name: 'elbow') JointMeasurement elbow,@JsonKey(name: 'wrist') JointMeasurement wrist
});


$JointMeasurementCopyWith<$Res> get shoulder;$JointMeasurementCopyWith<$Res> get elbow;$JointMeasurementCopyWith<$Res> get wrist;

}
/// @nodoc
class _$AnglesCopyWithImpl<$Res>
    implements $AnglesCopyWith<$Res> {
  _$AnglesCopyWithImpl(this._self, this._then);

  final Angles _self;
  final $Res Function(Angles) _then;

/// Create a copy of Angles
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? shoulder = null,Object? elbow = null,Object? wrist = null,}) {
  return _then(_self.copyWith(
shoulder: null == shoulder ? _self.shoulder : shoulder // ignore: cast_nullable_to_non_nullable
as JointMeasurement,elbow: null == elbow ? _self.elbow : elbow // ignore: cast_nullable_to_non_nullable
as JointMeasurement,wrist: null == wrist ? _self.wrist : wrist // ignore: cast_nullable_to_non_nullable
as JointMeasurement,
  ));
}
/// Create a copy of Angles
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$JointMeasurementCopyWith<$Res> get shoulder {
  
  return $JointMeasurementCopyWith<$Res>(_self.shoulder, (value) {
    return _then(_self.copyWith(shoulder: value));
  });
}/// Create a copy of Angles
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$JointMeasurementCopyWith<$Res> get elbow {
  
  return $JointMeasurementCopyWith<$Res>(_self.elbow, (value) {
    return _then(_self.copyWith(elbow: value));
  });
}/// Create a copy of Angles
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$JointMeasurementCopyWith<$Res> get wrist {
  
  return $JointMeasurementCopyWith<$Res>(_self.wrist, (value) {
    return _then(_self.copyWith(wrist: value));
  });
}
}


/// Adds pattern-matching-related methods to [Angles].
extension AnglesPatterns on Angles {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Angles value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Angles() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Angles value)  $default,){
final _that = this;
switch (_that) {
case _Angles():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Angles value)?  $default,){
final _that = this;
switch (_that) {
case _Angles() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'shoulder')  JointMeasurement shoulder, @JsonKey(name: 'elbow')  JointMeasurement elbow, @JsonKey(name: 'wrist')  JointMeasurement wrist)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Angles() when $default != null:
return $default(_that.shoulder,_that.elbow,_that.wrist);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'shoulder')  JointMeasurement shoulder, @JsonKey(name: 'elbow')  JointMeasurement elbow, @JsonKey(name: 'wrist')  JointMeasurement wrist)  $default,) {final _that = this;
switch (_that) {
case _Angles():
return $default(_that.shoulder,_that.elbow,_that.wrist);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'shoulder')  JointMeasurement shoulder, @JsonKey(name: 'elbow')  JointMeasurement elbow, @JsonKey(name: 'wrist')  JointMeasurement wrist)?  $default,) {final _that = this;
switch (_that) {
case _Angles() when $default != null:
return $default(_that.shoulder,_that.elbow,_that.wrist);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Angles implements Angles {
  const _Angles({@JsonKey(name: 'shoulder') required this.shoulder, @JsonKey(name: 'elbow') required this.elbow, @JsonKey(name: 'wrist') required this.wrist});
  factory _Angles.fromJson(Map<String, dynamic> json) => _$AnglesFromJson(json);

@override@JsonKey(name: 'shoulder') final  JointMeasurement shoulder;
@override@JsonKey(name: 'elbow') final  JointMeasurement elbow;
@override@JsonKey(name: 'wrist') final  JointMeasurement wrist;

/// Create a copy of Angles
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnglesCopyWith<_Angles> get copyWith => __$AnglesCopyWithImpl<_Angles>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnglesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Angles&&(identical(other.shoulder, shoulder) || other.shoulder == shoulder)&&(identical(other.elbow, elbow) || other.elbow == elbow)&&(identical(other.wrist, wrist) || other.wrist == wrist));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,shoulder,elbow,wrist);

@override
String toString() {
  return 'Angles(shoulder: $shoulder, elbow: $elbow, wrist: $wrist)';
}


}

/// @nodoc
abstract mixin class _$AnglesCopyWith<$Res> implements $AnglesCopyWith<$Res> {
  factory _$AnglesCopyWith(_Angles value, $Res Function(_Angles) _then) = __$AnglesCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'shoulder') JointMeasurement shoulder,@JsonKey(name: 'elbow') JointMeasurement elbow,@JsonKey(name: 'wrist') JointMeasurement wrist
});


@override $JointMeasurementCopyWith<$Res> get shoulder;@override $JointMeasurementCopyWith<$Res> get elbow;@override $JointMeasurementCopyWith<$Res> get wrist;

}
/// @nodoc
class __$AnglesCopyWithImpl<$Res>
    implements _$AnglesCopyWith<$Res> {
  __$AnglesCopyWithImpl(this._self, this._then);

  final _Angles _self;
  final $Res Function(_Angles) _then;

/// Create a copy of Angles
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? shoulder = null,Object? elbow = null,Object? wrist = null,}) {
  return _then(_Angles(
shoulder: null == shoulder ? _self.shoulder : shoulder // ignore: cast_nullable_to_non_nullable
as JointMeasurement,elbow: null == elbow ? _self.elbow : elbow // ignore: cast_nullable_to_non_nullable
as JointMeasurement,wrist: null == wrist ? _self.wrist : wrist // ignore: cast_nullable_to_non_nullable
as JointMeasurement,
  ));
}

/// Create a copy of Angles
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$JointMeasurementCopyWith<$Res> get shoulder {
  
  return $JointMeasurementCopyWith<$Res>(_self.shoulder, (value) {
    return _then(_self.copyWith(shoulder: value));
  });
}/// Create a copy of Angles
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$JointMeasurementCopyWith<$Res> get elbow {
  
  return $JointMeasurementCopyWith<$Res>(_self.elbow, (value) {
    return _then(_self.copyWith(elbow: value));
  });
}/// Create a copy of Angles
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$JointMeasurementCopyWith<$Res> get wrist {
  
  return $JointMeasurementCopyWith<$Res>(_self.wrist, (value) {
    return _then(_self.copyWith(wrist: value));
  });
}
}

// dart format on
