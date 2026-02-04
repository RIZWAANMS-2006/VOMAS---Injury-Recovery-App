// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vomas_task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AngleRange {

 double get min; double get max;
/// Create a copy of AngleRange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AngleRangeCopyWith<AngleRange> get copyWith => _$AngleRangeCopyWithImpl<AngleRange>(this as AngleRange, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AngleRange&&(identical(other.min, min) || other.min == min)&&(identical(other.max, max) || other.max == max));
}


@override
int get hashCode => Object.hash(runtimeType,min,max);

@override
String toString() {
  return 'AngleRange(min: $min, max: $max)';
}


}

/// @nodoc
abstract mixin class $AngleRangeCopyWith<$Res>  {
  factory $AngleRangeCopyWith(AngleRange value, $Res Function(AngleRange) _then) = _$AngleRangeCopyWithImpl;
@useResult
$Res call({
 double min, double max
});




}
/// @nodoc
class _$AngleRangeCopyWithImpl<$Res>
    implements $AngleRangeCopyWith<$Res> {
  _$AngleRangeCopyWithImpl(this._self, this._then);

  final AngleRange _self;
  final $Res Function(AngleRange) _then;

/// Create a copy of AngleRange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? min = null,Object? max = null,}) {
  return _then(_self.copyWith(
min: null == min ? _self.min : min // ignore: cast_nullable_to_non_nullable
as double,max: null == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [AngleRange].
extension AngleRangePatterns on AngleRange {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AngleRange value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AngleRange() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AngleRange value)  $default,){
final _that = this;
switch (_that) {
case _AngleRange():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AngleRange value)?  $default,){
final _that = this;
switch (_that) {
case _AngleRange() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double min,  double max)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AngleRange() when $default != null:
return $default(_that.min,_that.max);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double min,  double max)  $default,) {final _that = this;
switch (_that) {
case _AngleRange():
return $default(_that.min,_that.max);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double min,  double max)?  $default,) {final _that = this;
switch (_that) {
case _AngleRange() when $default != null:
return $default(_that.min,_that.max);case _:
  return null;

}
}

}

/// @nodoc


class _AngleRange implements AngleRange {
  const _AngleRange({required this.min, required this.max});
  

@override final  double min;
@override final  double max;

/// Create a copy of AngleRange
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AngleRangeCopyWith<_AngleRange> get copyWith => __$AngleRangeCopyWithImpl<_AngleRange>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AngleRange&&(identical(other.min, min) || other.min == min)&&(identical(other.max, max) || other.max == max));
}


@override
int get hashCode => Object.hash(runtimeType,min,max);

@override
String toString() {
  return 'AngleRange(min: $min, max: $max)';
}


}

/// @nodoc
abstract mixin class _$AngleRangeCopyWith<$Res> implements $AngleRangeCopyWith<$Res> {
  factory _$AngleRangeCopyWith(_AngleRange value, $Res Function(_AngleRange) _then) = __$AngleRangeCopyWithImpl;
@override @useResult
$Res call({
 double min, double max
});




}
/// @nodoc
class __$AngleRangeCopyWithImpl<$Res>
    implements _$AngleRangeCopyWith<$Res> {
  __$AngleRangeCopyWithImpl(this._self, this._then);

  final _AngleRange _self;
  final $Res Function(_AngleRange) _then;

/// Create a copy of AngleRange
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? min = null,Object? max = null,}) {
  return _then(_AngleRange(
min: null == min ? _self.min : min // ignore: cast_nullable_to_non_nullable
as double,max: null == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$VomasTask {

 String get name; String get description; String get actionType;// Maps to backend action key
 AngleRange? get shoulder; AngleRange? get elbow; AngleRange? get wrist;
/// Create a copy of VomasTask
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VomasTaskCopyWith<VomasTask> get copyWith => _$VomasTaskCopyWithImpl<VomasTask>(this as VomasTask, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VomasTask&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.actionType, actionType) || other.actionType == actionType)&&(identical(other.shoulder, shoulder) || other.shoulder == shoulder)&&(identical(other.elbow, elbow) || other.elbow == elbow)&&(identical(other.wrist, wrist) || other.wrist == wrist));
}


@override
int get hashCode => Object.hash(runtimeType,name,description,actionType,shoulder,elbow,wrist);

@override
String toString() {
  return 'VomasTask(name: $name, description: $description, actionType: $actionType, shoulder: $shoulder, elbow: $elbow, wrist: $wrist)';
}


}

/// @nodoc
abstract mixin class $VomasTaskCopyWith<$Res>  {
  factory $VomasTaskCopyWith(VomasTask value, $Res Function(VomasTask) _then) = _$VomasTaskCopyWithImpl;
@useResult
$Res call({
 String name, String description, String actionType, AngleRange? shoulder, AngleRange? elbow, AngleRange? wrist
});


$AngleRangeCopyWith<$Res>? get shoulder;$AngleRangeCopyWith<$Res>? get elbow;$AngleRangeCopyWith<$Res>? get wrist;

}
/// @nodoc
class _$VomasTaskCopyWithImpl<$Res>
    implements $VomasTaskCopyWith<$Res> {
  _$VomasTaskCopyWithImpl(this._self, this._then);

  final VomasTask _self;
  final $Res Function(VomasTask) _then;

/// Create a copy of VomasTask
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? description = null,Object? actionType = null,Object? shoulder = freezed,Object? elbow = freezed,Object? wrist = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,actionType: null == actionType ? _self.actionType : actionType // ignore: cast_nullable_to_non_nullable
as String,shoulder: freezed == shoulder ? _self.shoulder : shoulder // ignore: cast_nullable_to_non_nullable
as AngleRange?,elbow: freezed == elbow ? _self.elbow : elbow // ignore: cast_nullable_to_non_nullable
as AngleRange?,wrist: freezed == wrist ? _self.wrist : wrist // ignore: cast_nullable_to_non_nullable
as AngleRange?,
  ));
}
/// Create a copy of VomasTask
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AngleRangeCopyWith<$Res>? get shoulder {
    if (_self.shoulder == null) {
    return null;
  }

  return $AngleRangeCopyWith<$Res>(_self.shoulder!, (value) {
    return _then(_self.copyWith(shoulder: value));
  });
}/// Create a copy of VomasTask
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AngleRangeCopyWith<$Res>? get elbow {
    if (_self.elbow == null) {
    return null;
  }

  return $AngleRangeCopyWith<$Res>(_self.elbow!, (value) {
    return _then(_self.copyWith(elbow: value));
  });
}/// Create a copy of VomasTask
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AngleRangeCopyWith<$Res>? get wrist {
    if (_self.wrist == null) {
    return null;
  }

  return $AngleRangeCopyWith<$Res>(_self.wrist!, (value) {
    return _then(_self.copyWith(wrist: value));
  });
}
}


/// Adds pattern-matching-related methods to [VomasTask].
extension VomasTaskPatterns on VomasTask {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VomasTask value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VomasTask() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VomasTask value)  $default,){
final _that = this;
switch (_that) {
case _VomasTask():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VomasTask value)?  $default,){
final _that = this;
switch (_that) {
case _VomasTask() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String description,  String actionType,  AngleRange? shoulder,  AngleRange? elbow,  AngleRange? wrist)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VomasTask() when $default != null:
return $default(_that.name,_that.description,_that.actionType,_that.shoulder,_that.elbow,_that.wrist);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String description,  String actionType,  AngleRange? shoulder,  AngleRange? elbow,  AngleRange? wrist)  $default,) {final _that = this;
switch (_that) {
case _VomasTask():
return $default(_that.name,_that.description,_that.actionType,_that.shoulder,_that.elbow,_that.wrist);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String description,  String actionType,  AngleRange? shoulder,  AngleRange? elbow,  AngleRange? wrist)?  $default,) {final _that = this;
switch (_that) {
case _VomasTask() when $default != null:
return $default(_that.name,_that.description,_that.actionType,_that.shoulder,_that.elbow,_that.wrist);case _:
  return null;

}
}

}

/// @nodoc


class _VomasTask extends VomasTask {
  const _VomasTask({required this.name, required this.description, required this.actionType, this.shoulder, this.elbow, this.wrist}): super._();
  

@override final  String name;
@override final  String description;
@override final  String actionType;
// Maps to backend action key
@override final  AngleRange? shoulder;
@override final  AngleRange? elbow;
@override final  AngleRange? wrist;

/// Create a copy of VomasTask
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VomasTaskCopyWith<_VomasTask> get copyWith => __$VomasTaskCopyWithImpl<_VomasTask>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VomasTask&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.actionType, actionType) || other.actionType == actionType)&&(identical(other.shoulder, shoulder) || other.shoulder == shoulder)&&(identical(other.elbow, elbow) || other.elbow == elbow)&&(identical(other.wrist, wrist) || other.wrist == wrist));
}


@override
int get hashCode => Object.hash(runtimeType,name,description,actionType,shoulder,elbow,wrist);

@override
String toString() {
  return 'VomasTask(name: $name, description: $description, actionType: $actionType, shoulder: $shoulder, elbow: $elbow, wrist: $wrist)';
}


}

/// @nodoc
abstract mixin class _$VomasTaskCopyWith<$Res> implements $VomasTaskCopyWith<$Res> {
  factory _$VomasTaskCopyWith(_VomasTask value, $Res Function(_VomasTask) _then) = __$VomasTaskCopyWithImpl;
@override @useResult
$Res call({
 String name, String description, String actionType, AngleRange? shoulder, AngleRange? elbow, AngleRange? wrist
});


@override $AngleRangeCopyWith<$Res>? get shoulder;@override $AngleRangeCopyWith<$Res>? get elbow;@override $AngleRangeCopyWith<$Res>? get wrist;

}
/// @nodoc
class __$VomasTaskCopyWithImpl<$Res>
    implements _$VomasTaskCopyWith<$Res> {
  __$VomasTaskCopyWithImpl(this._self, this._then);

  final _VomasTask _self;
  final $Res Function(_VomasTask) _then;

/// Create a copy of VomasTask
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? description = null,Object? actionType = null,Object? shoulder = freezed,Object? elbow = freezed,Object? wrist = freezed,}) {
  return _then(_VomasTask(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,actionType: null == actionType ? _self.actionType : actionType // ignore: cast_nullable_to_non_nullable
as String,shoulder: freezed == shoulder ? _self.shoulder : shoulder // ignore: cast_nullable_to_non_nullable
as AngleRange?,elbow: freezed == elbow ? _self.elbow : elbow // ignore: cast_nullable_to_non_nullable
as AngleRange?,wrist: freezed == wrist ? _self.wrist : wrist // ignore: cast_nullable_to_non_nullable
as AngleRange?,
  ));
}

/// Create a copy of VomasTask
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AngleRangeCopyWith<$Res>? get shoulder {
    if (_self.shoulder == null) {
    return null;
  }

  return $AngleRangeCopyWith<$Res>(_self.shoulder!, (value) {
    return _then(_self.copyWith(shoulder: value));
  });
}/// Create a copy of VomasTask
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AngleRangeCopyWith<$Res>? get elbow {
    if (_self.elbow == null) {
    return null;
  }

  return $AngleRangeCopyWith<$Res>(_self.elbow!, (value) {
    return _then(_self.copyWith(elbow: value));
  });
}/// Create a copy of VomasTask
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AngleRangeCopyWith<$Res>? get wrist {
    if (_self.wrist == null) {
    return null;
  }

  return $AngleRangeCopyWith<$Res>(_self.wrist!, (value) {
    return _then(_self.copyWith(wrist: value));
  });
}
}

// dart format on
