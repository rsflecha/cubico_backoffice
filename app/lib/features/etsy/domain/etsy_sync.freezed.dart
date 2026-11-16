// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'etsy_sync.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EtsySyncRun {

 String get status;// running, ok, error
 DateTime get startedAt; DateTime? get finishedAt; int get createdCount; int get updatedCount; int get skippedCount;// por associar: um SKU que não existe no backoffice
 String? get errorMessage; String? get notes;
/// Create a copy of EtsySyncRun
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EtsySyncRunCopyWith<EtsySyncRun> get copyWith => _$EtsySyncRunCopyWithImpl<EtsySyncRun>(this as EtsySyncRun, _$identity);

  /// Serializes this EtsySyncRun to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EtsySyncRun&&(identical(other.status, status) || other.status == status)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.finishedAt, finishedAt) || other.finishedAt == finishedAt)&&(identical(other.createdCount, createdCount) || other.createdCount == createdCount)&&(identical(other.updatedCount, updatedCount) || other.updatedCount == updatedCount)&&(identical(other.skippedCount, skippedCount) || other.skippedCount == skippedCount)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,startedAt,finishedAt,createdCount,updatedCount,skippedCount,errorMessage,notes);

@override
String toString() {
  return 'EtsySyncRun(status: $status, startedAt: $startedAt, finishedAt: $finishedAt, createdCount: $createdCount, updatedCount: $updatedCount, skippedCount: $skippedCount, errorMessage: $errorMessage, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $EtsySyncRunCopyWith<$Res>  {
  factory $EtsySyncRunCopyWith(EtsySyncRun value, $Res Function(EtsySyncRun) _then) = _$EtsySyncRunCopyWithImpl;
@useResult
$Res call({
 String status, DateTime startedAt, DateTime? finishedAt, int createdCount, int updatedCount, int skippedCount, String? errorMessage, String? notes
});




}
/// @nodoc
class _$EtsySyncRunCopyWithImpl<$Res>
    implements $EtsySyncRunCopyWith<$Res> {
  _$EtsySyncRunCopyWithImpl(this._self, this._then);

  final EtsySyncRun _self;
  final $Res Function(EtsySyncRun) _then;

/// Create a copy of EtsySyncRun
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? startedAt = null,Object? finishedAt = freezed,Object? createdCount = null,Object? updatedCount = null,Object? skippedCount = null,Object? errorMessage = freezed,Object? notes = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,finishedAt: freezed == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdCount: null == createdCount ? _self.createdCount : createdCount // ignore: cast_nullable_to_non_nullable
as int,updatedCount: null == updatedCount ? _self.updatedCount : updatedCount // ignore: cast_nullable_to_non_nullable
as int,skippedCount: null == skippedCount ? _self.skippedCount : skippedCount // ignore: cast_nullable_to_non_nullable
as int,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EtsySyncRun].
extension EtsySyncRunPatterns on EtsySyncRun {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EtsySyncRun value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EtsySyncRun() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EtsySyncRun value)  $default,){
final _that = this;
switch (_that) {
case _EtsySyncRun():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EtsySyncRun value)?  $default,){
final _that = this;
switch (_that) {
case _EtsySyncRun() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String status,  DateTime startedAt,  DateTime? finishedAt,  int createdCount,  int updatedCount,  int skippedCount,  String? errorMessage,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EtsySyncRun() when $default != null:
return $default(_that.status,_that.startedAt,_that.finishedAt,_that.createdCount,_that.updatedCount,_that.skippedCount,_that.errorMessage,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String status,  DateTime startedAt,  DateTime? finishedAt,  int createdCount,  int updatedCount,  int skippedCount,  String? errorMessage,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _EtsySyncRun():
return $default(_that.status,_that.startedAt,_that.finishedAt,_that.createdCount,_that.updatedCount,_that.skippedCount,_that.errorMessage,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String status,  DateTime startedAt,  DateTime? finishedAt,  int createdCount,  int updatedCount,  int skippedCount,  String? errorMessage,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _EtsySyncRun() when $default != null:
return $default(_that.status,_that.startedAt,_that.finishedAt,_that.createdCount,_that.updatedCount,_that.skippedCount,_that.errorMessage,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EtsySyncRun implements EtsySyncRun {
  const _EtsySyncRun({required this.status, required this.startedAt, this.finishedAt, this.createdCount = 0, this.updatedCount = 0, this.skippedCount = 0, this.errorMessage, this.notes});
  factory _EtsySyncRun.fromJson(Map<String, dynamic> json) => _$EtsySyncRunFromJson(json);

@override final  String status;
// running, ok, error
@override final  DateTime startedAt;
@override final  DateTime? finishedAt;
@override@JsonKey() final  int createdCount;
@override@JsonKey() final  int updatedCount;
@override@JsonKey() final  int skippedCount;
// por associar: um SKU que não existe no backoffice
@override final  String? errorMessage;
@override final  String? notes;

/// Create a copy of EtsySyncRun
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EtsySyncRunCopyWith<_EtsySyncRun> get copyWith => __$EtsySyncRunCopyWithImpl<_EtsySyncRun>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EtsySyncRunToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EtsySyncRun&&(identical(other.status, status) || other.status == status)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.finishedAt, finishedAt) || other.finishedAt == finishedAt)&&(identical(other.createdCount, createdCount) || other.createdCount == createdCount)&&(identical(other.updatedCount, updatedCount) || other.updatedCount == updatedCount)&&(identical(other.skippedCount, skippedCount) || other.skippedCount == skippedCount)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,startedAt,finishedAt,createdCount,updatedCount,skippedCount,errorMessage,notes);

@override
String toString() {
  return 'EtsySyncRun(status: $status, startedAt: $startedAt, finishedAt: $finishedAt, createdCount: $createdCount, updatedCount: $updatedCount, skippedCount: $skippedCount, errorMessage: $errorMessage, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$EtsySyncRunCopyWith<$Res> implements $EtsySyncRunCopyWith<$Res> {
  factory _$EtsySyncRunCopyWith(_EtsySyncRun value, $Res Function(_EtsySyncRun) _then) = __$EtsySyncRunCopyWithImpl;
@override @useResult
$Res call({
 String status, DateTime startedAt, DateTime? finishedAt, int createdCount, int updatedCount, int skippedCount, String? errorMessage, String? notes
});




}
/// @nodoc
class __$EtsySyncRunCopyWithImpl<$Res>
    implements _$EtsySyncRunCopyWith<$Res> {
  __$EtsySyncRunCopyWithImpl(this._self, this._then);

  final _EtsySyncRun _self;
  final $Res Function(_EtsySyncRun) _then;

/// Create a copy of EtsySyncRun
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? startedAt = null,Object? finishedAt = freezed,Object? createdCount = null,Object? updatedCount = null,Object? skippedCount = null,Object? errorMessage = freezed,Object? notes = freezed,}) {
  return _then(_EtsySyncRun(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,finishedAt: freezed == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdCount: null == createdCount ? _self.createdCount : createdCount // ignore: cast_nullable_to_non_nullable
as int,updatedCount: null == updatedCount ? _self.updatedCount : updatedCount // ignore: cast_nullable_to_non_nullable
as int,skippedCount: null == skippedCount ? _self.skippedCount : skippedCount // ignore: cast_nullable_to_non_nullable
as int,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$EtsySyncInfo {

 bool get connected; EtsySyncRun? get last;
/// Create a copy of EtsySyncInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EtsySyncInfoCopyWith<EtsySyncInfo> get copyWith => _$EtsySyncInfoCopyWithImpl<EtsySyncInfo>(this as EtsySyncInfo, _$identity);

  /// Serializes this EtsySyncInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EtsySyncInfo&&(identical(other.connected, connected) || other.connected == connected)&&(identical(other.last, last) || other.last == last));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,connected,last);

@override
String toString() {
  return 'EtsySyncInfo(connected: $connected, last: $last)';
}


}

/// @nodoc
abstract mixin class $EtsySyncInfoCopyWith<$Res>  {
  factory $EtsySyncInfoCopyWith(EtsySyncInfo value, $Res Function(EtsySyncInfo) _then) = _$EtsySyncInfoCopyWithImpl;
@useResult
$Res call({
 bool connected, EtsySyncRun? last
});


$EtsySyncRunCopyWith<$Res>? get last;

}
/// @nodoc
class _$EtsySyncInfoCopyWithImpl<$Res>
    implements $EtsySyncInfoCopyWith<$Res> {
  _$EtsySyncInfoCopyWithImpl(this._self, this._then);

  final EtsySyncInfo _self;
  final $Res Function(EtsySyncInfo) _then;

/// Create a copy of EtsySyncInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? connected = null,Object? last = freezed,}) {
  return _then(_self.copyWith(
connected: null == connected ? _self.connected : connected // ignore: cast_nullable_to_non_nullable
as bool,last: freezed == last ? _self.last : last // ignore: cast_nullable_to_non_nullable
as EtsySyncRun?,
  ));
}
/// Create a copy of EtsySyncInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EtsySyncRunCopyWith<$Res>? get last {
    if (_self.last == null) {
    return null;
  }

  return $EtsySyncRunCopyWith<$Res>(_self.last!, (value) {
    return _then(_self.copyWith(last: value));
  });
}
}


/// Adds pattern-matching-related methods to [EtsySyncInfo].
extension EtsySyncInfoPatterns on EtsySyncInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EtsySyncInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EtsySyncInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EtsySyncInfo value)  $default,){
final _that = this;
switch (_that) {
case _EtsySyncInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EtsySyncInfo value)?  $default,){
final _that = this;
switch (_that) {
case _EtsySyncInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool connected,  EtsySyncRun? last)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EtsySyncInfo() when $default != null:
return $default(_that.connected,_that.last);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool connected,  EtsySyncRun? last)  $default,) {final _that = this;
switch (_that) {
case _EtsySyncInfo():
return $default(_that.connected,_that.last);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool connected,  EtsySyncRun? last)?  $default,) {final _that = this;
switch (_that) {
case _EtsySyncInfo() when $default != null:
return $default(_that.connected,_that.last);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EtsySyncInfo implements EtsySyncInfo {
  const _EtsySyncInfo({this.connected = false, this.last});
  factory _EtsySyncInfo.fromJson(Map<String, dynamic> json) => _$EtsySyncInfoFromJson(json);

@override@JsonKey() final  bool connected;
@override final  EtsySyncRun? last;

/// Create a copy of EtsySyncInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EtsySyncInfoCopyWith<_EtsySyncInfo> get copyWith => __$EtsySyncInfoCopyWithImpl<_EtsySyncInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EtsySyncInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EtsySyncInfo&&(identical(other.connected, connected) || other.connected == connected)&&(identical(other.last, last) || other.last == last));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,connected,last);

@override
String toString() {
  return 'EtsySyncInfo(connected: $connected, last: $last)';
}


}

/// @nodoc
abstract mixin class _$EtsySyncInfoCopyWith<$Res> implements $EtsySyncInfoCopyWith<$Res> {
  factory _$EtsySyncInfoCopyWith(_EtsySyncInfo value, $Res Function(_EtsySyncInfo) _then) = __$EtsySyncInfoCopyWithImpl;
@override @useResult
$Res call({
 bool connected, EtsySyncRun? last
});


@override $EtsySyncRunCopyWith<$Res>? get last;

}
/// @nodoc
class __$EtsySyncInfoCopyWithImpl<$Res>
    implements _$EtsySyncInfoCopyWith<$Res> {
  __$EtsySyncInfoCopyWithImpl(this._self, this._then);

  final _EtsySyncInfo _self;
  final $Res Function(_EtsySyncInfo) _then;

/// Create a copy of EtsySyncInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? connected = null,Object? last = freezed,}) {
  return _then(_EtsySyncInfo(
connected: null == connected ? _self.connected : connected // ignore: cast_nullable_to_non_nullable
as bool,last: freezed == last ? _self.last : last // ignore: cast_nullable_to_non_nullable
as EtsySyncRun?,
  ));
}

/// Create a copy of EtsySyncInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EtsySyncRunCopyWith<$Res>? get last {
    if (_self.last == null) {
    return null;
  }

  return $EtsySyncRunCopyWith<$Res>(_self.last!, (value) {
    return _then(_self.copyWith(last: value));
  });
}
}

// dart format on
