// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'filament.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Filament {

 int get id; String get material; String? get brand; String get colorName; String? get colorHex; double get listPrice; double get paidPrice;// o valor por omissao vive aqui: o JSON pode nao trazer o campo
 int get spoolWeightG;// se nao vier, assume este valor
 double get shippingCost;// se nao vier, assume este valor
 int get spoolsInOrder;// se nao vier, assume este valor
 int get minStockG;// se nao vier, assume este valor
 bool get isActive;
/// Create a copy of Filament
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FilamentCopyWith<Filament> get copyWith => _$FilamentCopyWithImpl<Filament>(this as Filament, _$identity);

  /// Serializes this Filament to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Filament&&(identical(other.id, id) || other.id == id)&&(identical(other.material, material) || other.material == material)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.colorName, colorName) || other.colorName == colorName)&&(identical(other.colorHex, colorHex) || other.colorHex == colorHex)&&(identical(other.listPrice, listPrice) || other.listPrice == listPrice)&&(identical(other.paidPrice, paidPrice) || other.paidPrice == paidPrice)&&(identical(other.spoolWeightG, spoolWeightG) || other.spoolWeightG == spoolWeightG)&&(identical(other.shippingCost, shippingCost) || other.shippingCost == shippingCost)&&(identical(other.spoolsInOrder, spoolsInOrder) || other.spoolsInOrder == spoolsInOrder)&&(identical(other.minStockG, minStockG) || other.minStockG == minStockG)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,material,brand,colorName,colorHex,listPrice,paidPrice,spoolWeightG,shippingCost,spoolsInOrder,minStockG,isActive);

@override
String toString() {
  return 'Filament(id: $id, material: $material, brand: $brand, colorName: $colorName, colorHex: $colorHex, listPrice: $listPrice, paidPrice: $paidPrice, spoolWeightG: $spoolWeightG, shippingCost: $shippingCost, spoolsInOrder: $spoolsInOrder, minStockG: $minStockG, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $FilamentCopyWith<$Res>  {
  factory $FilamentCopyWith(Filament value, $Res Function(Filament) _then) = _$FilamentCopyWithImpl;
@useResult
$Res call({
 int id, String material, String? brand, String colorName, String? colorHex, double listPrice, double paidPrice, int spoolWeightG, double shippingCost, int spoolsInOrder, int minStockG, bool isActive
});




}
/// @nodoc
class _$FilamentCopyWithImpl<$Res>
    implements $FilamentCopyWith<$Res> {
  _$FilamentCopyWithImpl(this._self, this._then);

  final Filament _self;
  final $Res Function(Filament) _then;

/// Create a copy of Filament
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? material = null,Object? brand = freezed,Object? colorName = null,Object? colorHex = freezed,Object? listPrice = null,Object? paidPrice = null,Object? spoolWeightG = null,Object? shippingCost = null,Object? spoolsInOrder = null,Object? minStockG = null,Object? isActive = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,material: null == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,colorName: null == colorName ? _self.colorName : colorName // ignore: cast_nullable_to_non_nullable
as String,colorHex: freezed == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String?,listPrice: null == listPrice ? _self.listPrice : listPrice // ignore: cast_nullable_to_non_nullable
as double,paidPrice: null == paidPrice ? _self.paidPrice : paidPrice // ignore: cast_nullable_to_non_nullable
as double,spoolWeightG: null == spoolWeightG ? _self.spoolWeightG : spoolWeightG // ignore: cast_nullable_to_non_nullable
as int,shippingCost: null == shippingCost ? _self.shippingCost : shippingCost // ignore: cast_nullable_to_non_nullable
as double,spoolsInOrder: null == spoolsInOrder ? _self.spoolsInOrder : spoolsInOrder // ignore: cast_nullable_to_non_nullable
as int,minStockG: null == minStockG ? _self.minStockG : minStockG // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Filament].
extension FilamentPatterns on Filament {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Filament value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Filament() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Filament value)  $default,){
final _that = this;
switch (_that) {
case _Filament():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Filament value)?  $default,){
final _that = this;
switch (_that) {
case _Filament() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String material,  String? brand,  String colorName,  String? colorHex,  double listPrice,  double paidPrice,  int spoolWeightG,  double shippingCost,  int spoolsInOrder,  int minStockG,  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Filament() when $default != null:
return $default(_that.id,_that.material,_that.brand,_that.colorName,_that.colorHex,_that.listPrice,_that.paidPrice,_that.spoolWeightG,_that.shippingCost,_that.spoolsInOrder,_that.minStockG,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String material,  String? brand,  String colorName,  String? colorHex,  double listPrice,  double paidPrice,  int spoolWeightG,  double shippingCost,  int spoolsInOrder,  int minStockG,  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _Filament():
return $default(_that.id,_that.material,_that.brand,_that.colorName,_that.colorHex,_that.listPrice,_that.paidPrice,_that.spoolWeightG,_that.shippingCost,_that.spoolsInOrder,_that.minStockG,_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String material,  String? brand,  String colorName,  String? colorHex,  double listPrice,  double paidPrice,  int spoolWeightG,  double shippingCost,  int spoolsInOrder,  int minStockG,  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _Filament() when $default != null:
return $default(_that.id,_that.material,_that.brand,_that.colorName,_that.colorHex,_that.listPrice,_that.paidPrice,_that.spoolWeightG,_that.shippingCost,_that.spoolsInOrder,_that.minStockG,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Filament implements Filament {
  const _Filament({required this.id, required this.material, this.brand, required this.colorName, this.colorHex, required this.listPrice, required this.paidPrice, this.spoolWeightG = 1000, this.shippingCost = 0, this.spoolsInOrder = 1, this.minStockG = 250, this.isActive = true});
  factory _Filament.fromJson(Map<String, dynamic> json) => _$FilamentFromJson(json);

@override final  int id;
@override final  String material;
@override final  String? brand;
@override final  String colorName;
@override final  String? colorHex;
@override final  double listPrice;
@override final  double paidPrice;
// o valor por omissao vive aqui: o JSON pode nao trazer o campo
@override@JsonKey() final  int spoolWeightG;
// se nao vier, assume este valor
@override@JsonKey() final  double shippingCost;
// se nao vier, assume este valor
@override@JsonKey() final  int spoolsInOrder;
// se nao vier, assume este valor
@override@JsonKey() final  int minStockG;
// se nao vier, assume este valor
@override@JsonKey() final  bool isActive;

/// Create a copy of Filament
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilamentCopyWith<_Filament> get copyWith => __$FilamentCopyWithImpl<_Filament>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FilamentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Filament&&(identical(other.id, id) || other.id == id)&&(identical(other.material, material) || other.material == material)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.colorName, colorName) || other.colorName == colorName)&&(identical(other.colorHex, colorHex) || other.colorHex == colorHex)&&(identical(other.listPrice, listPrice) || other.listPrice == listPrice)&&(identical(other.paidPrice, paidPrice) || other.paidPrice == paidPrice)&&(identical(other.spoolWeightG, spoolWeightG) || other.spoolWeightG == spoolWeightG)&&(identical(other.shippingCost, shippingCost) || other.shippingCost == shippingCost)&&(identical(other.spoolsInOrder, spoolsInOrder) || other.spoolsInOrder == spoolsInOrder)&&(identical(other.minStockG, minStockG) || other.minStockG == minStockG)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,material,brand,colorName,colorHex,listPrice,paidPrice,spoolWeightG,shippingCost,spoolsInOrder,minStockG,isActive);

@override
String toString() {
  return 'Filament(id: $id, material: $material, brand: $brand, colorName: $colorName, colorHex: $colorHex, listPrice: $listPrice, paidPrice: $paidPrice, spoolWeightG: $spoolWeightG, shippingCost: $shippingCost, spoolsInOrder: $spoolsInOrder, minStockG: $minStockG, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$FilamentCopyWith<$Res> implements $FilamentCopyWith<$Res> {
  factory _$FilamentCopyWith(_Filament value, $Res Function(_Filament) _then) = __$FilamentCopyWithImpl;
@override @useResult
$Res call({
 int id, String material, String? brand, String colorName, String? colorHex, double listPrice, double paidPrice, int spoolWeightG, double shippingCost, int spoolsInOrder, int minStockG, bool isActive
});




}
/// @nodoc
class __$FilamentCopyWithImpl<$Res>
    implements _$FilamentCopyWith<$Res> {
  __$FilamentCopyWithImpl(this._self, this._then);

  final _Filament _self;
  final $Res Function(_Filament) _then;

/// Create a copy of Filament
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? material = null,Object? brand = freezed,Object? colorName = null,Object? colorHex = freezed,Object? listPrice = null,Object? paidPrice = null,Object? spoolWeightG = null,Object? shippingCost = null,Object? spoolsInOrder = null,Object? minStockG = null,Object? isActive = null,}) {
  return _then(_Filament(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,material: null == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,colorName: null == colorName ? _self.colorName : colorName // ignore: cast_nullable_to_non_nullable
as String,colorHex: freezed == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String?,listPrice: null == listPrice ? _self.listPrice : listPrice // ignore: cast_nullable_to_non_nullable
as double,paidPrice: null == paidPrice ? _self.paidPrice : paidPrice // ignore: cast_nullable_to_non_nullable
as double,spoolWeightG: null == spoolWeightG ? _self.spoolWeightG : spoolWeightG // ignore: cast_nullable_to_non_nullable
as int,shippingCost: null == shippingCost ? _self.shippingCost : shippingCost // ignore: cast_nullable_to_non_nullable
as double,spoolsInOrder: null == spoolsInOrder ? _self.spoolsInOrder : spoolsInOrder // ignore: cast_nullable_to_non_nullable
as int,minStockG: null == minStockG ? _self.minStockG : minStockG // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
