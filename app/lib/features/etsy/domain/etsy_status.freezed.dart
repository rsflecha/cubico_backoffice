// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'etsy_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EtsyStatus {

/// A chave da app Etsy está no .env do servidor?
 bool get configured;/// A loja já foi autorizada?
 bool get connected; String? get shopName; DateTime? get connectedAt;/// Depois disto (90 dias sem sincronizar) é preciso ligar outra vez.
 DateTime? get refreshExpiresAt;
/// Create a copy of EtsyStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EtsyStatusCopyWith<EtsyStatus> get copyWith => _$EtsyStatusCopyWithImpl<EtsyStatus>(this as EtsyStatus, _$identity);

  /// Serializes this EtsyStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EtsyStatus&&(identical(other.configured, configured) || other.configured == configured)&&(identical(other.connected, connected) || other.connected == connected)&&(identical(other.shopName, shopName) || other.shopName == shopName)&&(identical(other.connectedAt, connectedAt) || other.connectedAt == connectedAt)&&(identical(other.refreshExpiresAt, refreshExpiresAt) || other.refreshExpiresAt == refreshExpiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,configured,connected,shopName,connectedAt,refreshExpiresAt);

@override
String toString() {
  return 'EtsyStatus(configured: $configured, connected: $connected, shopName: $shopName, connectedAt: $connectedAt, refreshExpiresAt: $refreshExpiresAt)';
}


}

/// @nodoc
abstract mixin class $EtsyStatusCopyWith<$Res>  {
  factory $EtsyStatusCopyWith(EtsyStatus value, $Res Function(EtsyStatus) _then) = _$EtsyStatusCopyWithImpl;
@useResult
$Res call({
 bool configured, bool connected, String? shopName, DateTime? connectedAt, DateTime? refreshExpiresAt
});




}
/// @nodoc
class _$EtsyStatusCopyWithImpl<$Res>
    implements $EtsyStatusCopyWith<$Res> {
  _$EtsyStatusCopyWithImpl(this._self, this._then);

  final EtsyStatus _self;
  final $Res Function(EtsyStatus) _then;

/// Create a copy of EtsyStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? configured = null,Object? connected = null,Object? shopName = freezed,Object? connectedAt = freezed,Object? refreshExpiresAt = freezed,}) {
  return _then(_self.copyWith(
configured: null == configured ? _self.configured : configured // ignore: cast_nullable_to_non_nullable
as bool,connected: null == connected ? _self.connected : connected // ignore: cast_nullable_to_non_nullable
as bool,shopName: freezed == shopName ? _self.shopName : shopName // ignore: cast_nullable_to_non_nullable
as String?,connectedAt: freezed == connectedAt ? _self.connectedAt : connectedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,refreshExpiresAt: freezed == refreshExpiresAt ? _self.refreshExpiresAt : refreshExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [EtsyStatus].
extension EtsyStatusPatterns on EtsyStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EtsyStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EtsyStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EtsyStatus value)  $default,){
final _that = this;
switch (_that) {
case _EtsyStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EtsyStatus value)?  $default,){
final _that = this;
switch (_that) {
case _EtsyStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool configured,  bool connected,  String? shopName,  DateTime? connectedAt,  DateTime? refreshExpiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EtsyStatus() when $default != null:
return $default(_that.configured,_that.connected,_that.shopName,_that.connectedAt,_that.refreshExpiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool configured,  bool connected,  String? shopName,  DateTime? connectedAt,  DateTime? refreshExpiresAt)  $default,) {final _that = this;
switch (_that) {
case _EtsyStatus():
return $default(_that.configured,_that.connected,_that.shopName,_that.connectedAt,_that.refreshExpiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool configured,  bool connected,  String? shopName,  DateTime? connectedAt,  DateTime? refreshExpiresAt)?  $default,) {final _that = this;
switch (_that) {
case _EtsyStatus() when $default != null:
return $default(_that.configured,_that.connected,_that.shopName,_that.connectedAt,_that.refreshExpiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EtsyStatus extends EtsyStatus {
  const _EtsyStatus({this.configured = false, this.connected = false, this.shopName, this.connectedAt, this.refreshExpiresAt}): super._();
  factory _EtsyStatus.fromJson(Map<String, dynamic> json) => _$EtsyStatusFromJson(json);

/// A chave da app Etsy está no .env do servidor?
@override@JsonKey() final  bool configured;
/// A loja já foi autorizada?
@override@JsonKey() final  bool connected;
@override final  String? shopName;
@override final  DateTime? connectedAt;
/// Depois disto (90 dias sem sincronizar) é preciso ligar outra vez.
@override final  DateTime? refreshExpiresAt;

/// Create a copy of EtsyStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EtsyStatusCopyWith<_EtsyStatus> get copyWith => __$EtsyStatusCopyWithImpl<_EtsyStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EtsyStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EtsyStatus&&(identical(other.configured, configured) || other.configured == configured)&&(identical(other.connected, connected) || other.connected == connected)&&(identical(other.shopName, shopName) || other.shopName == shopName)&&(identical(other.connectedAt, connectedAt) || other.connectedAt == connectedAt)&&(identical(other.refreshExpiresAt, refreshExpiresAt) || other.refreshExpiresAt == refreshExpiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,configured,connected,shopName,connectedAt,refreshExpiresAt);

@override
String toString() {
  return 'EtsyStatus(configured: $configured, connected: $connected, shopName: $shopName, connectedAt: $connectedAt, refreshExpiresAt: $refreshExpiresAt)';
}


}

/// @nodoc
abstract mixin class _$EtsyStatusCopyWith<$Res> implements $EtsyStatusCopyWith<$Res> {
  factory _$EtsyStatusCopyWith(_EtsyStatus value, $Res Function(_EtsyStatus) _then) = __$EtsyStatusCopyWithImpl;
@override @useResult
$Res call({
 bool configured, bool connected, String? shopName, DateTime? connectedAt, DateTime? refreshExpiresAt
});




}
/// @nodoc
class __$EtsyStatusCopyWithImpl<$Res>
    implements _$EtsyStatusCopyWith<$Res> {
  __$EtsyStatusCopyWithImpl(this._self, this._then);

  final _EtsyStatus _self;
  final $Res Function(_EtsyStatus) _then;

/// Create a copy of EtsyStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? configured = null,Object? connected = null,Object? shopName = freezed,Object? connectedAt = freezed,Object? refreshExpiresAt = freezed,}) {
  return _then(_EtsyStatus(
configured: null == configured ? _self.configured : configured // ignore: cast_nullable_to_non_nullable
as bool,connected: null == connected ? _self.connected : connected // ignore: cast_nullable_to_non_nullable
as bool,shopName: freezed == shopName ? _self.shopName : shopName // ignore: cast_nullable_to_non_nullable
as String?,connectedAt: freezed == connectedAt ? _self.connectedAt : connectedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,refreshExpiresAt: freezed == refreshExpiresAt ? _self.refreshExpiresAt : refreshExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
