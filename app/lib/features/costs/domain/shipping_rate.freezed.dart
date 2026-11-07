// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shipping_rate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShippingRate {

 int get id; int get carrierId;// 1 = CTT Correio Registado (PT); 2 = CTT Correio Azul Internacional
 int get zoneId;// 1 = Portugal; 2 = Europa; 3 = EUA; 4 = Resto do mundo
 int get maxWeightG;// o peso máximo deste escalão, incluído
 double get price;
/// Create a copy of ShippingRate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShippingRateCopyWith<ShippingRate> get copyWith => _$ShippingRateCopyWithImpl<ShippingRate>(this as ShippingRate, _$identity);

  /// Serializes this ShippingRate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShippingRate&&(identical(other.id, id) || other.id == id)&&(identical(other.carrierId, carrierId) || other.carrierId == carrierId)&&(identical(other.zoneId, zoneId) || other.zoneId == zoneId)&&(identical(other.maxWeightG, maxWeightG) || other.maxWeightG == maxWeightG)&&(identical(other.price, price) || other.price == price));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,carrierId,zoneId,maxWeightG,price);

@override
String toString() {
  return 'ShippingRate(id: $id, carrierId: $carrierId, zoneId: $zoneId, maxWeightG: $maxWeightG, price: $price)';
}


}

/// @nodoc
abstract mixin class $ShippingRateCopyWith<$Res>  {
  factory $ShippingRateCopyWith(ShippingRate value, $Res Function(ShippingRate) _then) = _$ShippingRateCopyWithImpl;
@useResult
$Res call({
 int id, int carrierId, int zoneId, int maxWeightG, double price
});




}
/// @nodoc
class _$ShippingRateCopyWithImpl<$Res>
    implements $ShippingRateCopyWith<$Res> {
  _$ShippingRateCopyWithImpl(this._self, this._then);

  final ShippingRate _self;
  final $Res Function(ShippingRate) _then;

/// Create a copy of ShippingRate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? carrierId = null,Object? zoneId = null,Object? maxWeightG = null,Object? price = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,carrierId: null == carrierId ? _self.carrierId : carrierId // ignore: cast_nullable_to_non_nullable
as int,zoneId: null == zoneId ? _self.zoneId : zoneId // ignore: cast_nullable_to_non_nullable
as int,maxWeightG: null == maxWeightG ? _self.maxWeightG : maxWeightG // ignore: cast_nullable_to_non_nullable
as int,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [ShippingRate].
extension ShippingRatePatterns on ShippingRate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShippingRate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShippingRate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShippingRate value)  $default,){
final _that = this;
switch (_that) {
case _ShippingRate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShippingRate value)?  $default,){
final _that = this;
switch (_that) {
case _ShippingRate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int carrierId,  int zoneId,  int maxWeightG,  double price)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShippingRate() when $default != null:
return $default(_that.id,_that.carrierId,_that.zoneId,_that.maxWeightG,_that.price);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int carrierId,  int zoneId,  int maxWeightG,  double price)  $default,) {final _that = this;
switch (_that) {
case _ShippingRate():
return $default(_that.id,_that.carrierId,_that.zoneId,_that.maxWeightG,_that.price);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int carrierId,  int zoneId,  int maxWeightG,  double price)?  $default,) {final _that = this;
switch (_that) {
case _ShippingRate() when $default != null:
return $default(_that.id,_that.carrierId,_that.zoneId,_that.maxWeightG,_that.price);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShippingRate implements ShippingRate {
  const _ShippingRate({required this.id, this.carrierId = 1, this.zoneId = 1, required this.maxWeightG, required this.price});
  factory _ShippingRate.fromJson(Map<String, dynamic> json) => _$ShippingRateFromJson(json);

@override final  int id;
@override@JsonKey() final  int carrierId;
// 1 = CTT Correio Registado (PT); 2 = CTT Correio Azul Internacional
@override@JsonKey() final  int zoneId;
// 1 = Portugal; 2 = Europa; 3 = EUA; 4 = Resto do mundo
@override final  int maxWeightG;
// o peso máximo deste escalão, incluído
@override final  double price;

/// Create a copy of ShippingRate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShippingRateCopyWith<_ShippingRate> get copyWith => __$ShippingRateCopyWithImpl<_ShippingRate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShippingRateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShippingRate&&(identical(other.id, id) || other.id == id)&&(identical(other.carrierId, carrierId) || other.carrierId == carrierId)&&(identical(other.zoneId, zoneId) || other.zoneId == zoneId)&&(identical(other.maxWeightG, maxWeightG) || other.maxWeightG == maxWeightG)&&(identical(other.price, price) || other.price == price));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,carrierId,zoneId,maxWeightG,price);

@override
String toString() {
  return 'ShippingRate(id: $id, carrierId: $carrierId, zoneId: $zoneId, maxWeightG: $maxWeightG, price: $price)';
}


}

/// @nodoc
abstract mixin class _$ShippingRateCopyWith<$Res> implements $ShippingRateCopyWith<$Res> {
  factory _$ShippingRateCopyWith(_ShippingRate value, $Res Function(_ShippingRate) _then) = __$ShippingRateCopyWithImpl;
@override @useResult
$Res call({
 int id, int carrierId, int zoneId, int maxWeightG, double price
});




}
/// @nodoc
class __$ShippingRateCopyWithImpl<$Res>
    implements _$ShippingRateCopyWith<$Res> {
  __$ShippingRateCopyWithImpl(this._self, this._then);

  final _ShippingRate _self;
  final $Res Function(_ShippingRate) _then;

/// Create a copy of ShippingRate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? carrierId = null,Object? zoneId = null,Object? maxWeightG = null,Object? price = null,}) {
  return _then(_ShippingRate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,carrierId: null == carrierId ? _self.carrierId : carrierId // ignore: cast_nullable_to_non_nullable
as int,zoneId: null == zoneId ? _self.zoneId : zoneId // ignore: cast_nullable_to_non_nullable
as int,maxWeightG: null == maxWeightG ? _self.maxWeightG : maxWeightG // ignore: cast_nullable_to_non_nullable
as int,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
