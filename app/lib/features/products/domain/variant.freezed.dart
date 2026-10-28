// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'variant.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Variant {

 int get id; int get productId; String get name; String get sku; double get salePrice; int? get printerId; String? get modelFile; String? get etsyListingId;// o valor por omissao vive aqui: o JSON pode nao trazer o campo
 int get printTimeMin;// se nao vier, assume este valor
 int get plateCount;// se nao vier, assume este valor
 int get weightG;// se nao vier, assume este valor
 bool get isActive;
/// Create a copy of Variant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VariantCopyWith<Variant> get copyWith => _$VariantCopyWithImpl<Variant>(this as Variant, _$identity);

  /// Serializes this Variant to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Variant&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.salePrice, salePrice) || other.salePrice == salePrice)&&(identical(other.printerId, printerId) || other.printerId == printerId)&&(identical(other.modelFile, modelFile) || other.modelFile == modelFile)&&(identical(other.etsyListingId, etsyListingId) || other.etsyListingId == etsyListingId)&&(identical(other.printTimeMin, printTimeMin) || other.printTimeMin == printTimeMin)&&(identical(other.plateCount, plateCount) || other.plateCount == plateCount)&&(identical(other.weightG, weightG) || other.weightG == weightG)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productId,name,sku,salePrice,printerId,modelFile,etsyListingId,printTimeMin,plateCount,weightG,isActive);

@override
String toString() {
  return 'Variant(id: $id, productId: $productId, name: $name, sku: $sku, salePrice: $salePrice, printerId: $printerId, modelFile: $modelFile, etsyListingId: $etsyListingId, printTimeMin: $printTimeMin, plateCount: $plateCount, weightG: $weightG, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $VariantCopyWith<$Res>  {
  factory $VariantCopyWith(Variant value, $Res Function(Variant) _then) = _$VariantCopyWithImpl;
@useResult
$Res call({
 int id, int productId, String name, String sku, double salePrice, int? printerId, String? modelFile, String? etsyListingId, int printTimeMin, int plateCount, int weightG, bool isActive
});




}
/// @nodoc
class _$VariantCopyWithImpl<$Res>
    implements $VariantCopyWith<$Res> {
  _$VariantCopyWithImpl(this._self, this._then);

  final Variant _self;
  final $Res Function(Variant) _then;

/// Create a copy of Variant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? productId = null,Object? name = null,Object? sku = null,Object? salePrice = null,Object? printerId = freezed,Object? modelFile = freezed,Object? etsyListingId = freezed,Object? printTimeMin = null,Object? plateCount = null,Object? weightG = null,Object? isActive = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sku: null == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String,salePrice: null == salePrice ? _self.salePrice : salePrice // ignore: cast_nullable_to_non_nullable
as double,printerId: freezed == printerId ? _self.printerId : printerId // ignore: cast_nullable_to_non_nullable
as int?,modelFile: freezed == modelFile ? _self.modelFile : modelFile // ignore: cast_nullable_to_non_nullable
as String?,etsyListingId: freezed == etsyListingId ? _self.etsyListingId : etsyListingId // ignore: cast_nullable_to_non_nullable
as String?,printTimeMin: null == printTimeMin ? _self.printTimeMin : printTimeMin // ignore: cast_nullable_to_non_nullable
as int,plateCount: null == plateCount ? _self.plateCount : plateCount // ignore: cast_nullable_to_non_nullable
as int,weightG: null == weightG ? _self.weightG : weightG // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Variant].
extension VariantPatterns on Variant {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Variant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Variant() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Variant value)  $default,){
final _that = this;
switch (_that) {
case _Variant():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Variant value)?  $default,){
final _that = this;
switch (_that) {
case _Variant() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int productId,  String name,  String sku,  double salePrice,  int? printerId,  String? modelFile,  String? etsyListingId,  int printTimeMin,  int plateCount,  int weightG,  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Variant() when $default != null:
return $default(_that.id,_that.productId,_that.name,_that.sku,_that.salePrice,_that.printerId,_that.modelFile,_that.etsyListingId,_that.printTimeMin,_that.plateCount,_that.weightG,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int productId,  String name,  String sku,  double salePrice,  int? printerId,  String? modelFile,  String? etsyListingId,  int printTimeMin,  int plateCount,  int weightG,  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _Variant():
return $default(_that.id,_that.productId,_that.name,_that.sku,_that.salePrice,_that.printerId,_that.modelFile,_that.etsyListingId,_that.printTimeMin,_that.plateCount,_that.weightG,_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int productId,  String name,  String sku,  double salePrice,  int? printerId,  String? modelFile,  String? etsyListingId,  int printTimeMin,  int plateCount,  int weightG,  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _Variant() when $default != null:
return $default(_that.id,_that.productId,_that.name,_that.sku,_that.salePrice,_that.printerId,_that.modelFile,_that.etsyListingId,_that.printTimeMin,_that.plateCount,_that.weightG,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Variant implements Variant {
  const _Variant({required this.id, required this.productId, required this.name, required this.sku, required this.salePrice, this.printerId, this.modelFile, this.etsyListingId, this.printTimeMin = 0, this.plateCount = 1, this.weightG = 0, this.isActive = true});
  factory _Variant.fromJson(Map<String, dynamic> json) => _$VariantFromJson(json);

@override final  int id;
@override final  int productId;
@override final  String name;
@override final  String sku;
@override final  double salePrice;
@override final  int? printerId;
@override final  String? modelFile;
@override final  String? etsyListingId;
// o valor por omissao vive aqui: o JSON pode nao trazer o campo
@override@JsonKey() final  int printTimeMin;
// se nao vier, assume este valor
@override@JsonKey() final  int plateCount;
// se nao vier, assume este valor
@override@JsonKey() final  int weightG;
// se nao vier, assume este valor
@override@JsonKey() final  bool isActive;

/// Create a copy of Variant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VariantCopyWith<_Variant> get copyWith => __$VariantCopyWithImpl<_Variant>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VariantToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Variant&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.salePrice, salePrice) || other.salePrice == salePrice)&&(identical(other.printerId, printerId) || other.printerId == printerId)&&(identical(other.modelFile, modelFile) || other.modelFile == modelFile)&&(identical(other.etsyListingId, etsyListingId) || other.etsyListingId == etsyListingId)&&(identical(other.printTimeMin, printTimeMin) || other.printTimeMin == printTimeMin)&&(identical(other.plateCount, plateCount) || other.plateCount == plateCount)&&(identical(other.weightG, weightG) || other.weightG == weightG)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productId,name,sku,salePrice,printerId,modelFile,etsyListingId,printTimeMin,plateCount,weightG,isActive);

@override
String toString() {
  return 'Variant(id: $id, productId: $productId, name: $name, sku: $sku, salePrice: $salePrice, printerId: $printerId, modelFile: $modelFile, etsyListingId: $etsyListingId, printTimeMin: $printTimeMin, plateCount: $plateCount, weightG: $weightG, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$VariantCopyWith<$Res> implements $VariantCopyWith<$Res> {
  factory _$VariantCopyWith(_Variant value, $Res Function(_Variant) _then) = __$VariantCopyWithImpl;
@override @useResult
$Res call({
 int id, int productId, String name, String sku, double salePrice, int? printerId, String? modelFile, String? etsyListingId, int printTimeMin, int plateCount, int weightG, bool isActive
});




}
/// @nodoc
class __$VariantCopyWithImpl<$Res>
    implements _$VariantCopyWith<$Res> {
  __$VariantCopyWithImpl(this._self, this._then);

  final _Variant _self;
  final $Res Function(_Variant) _then;

/// Create a copy of Variant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? productId = null,Object? name = null,Object? sku = null,Object? salePrice = null,Object? printerId = freezed,Object? modelFile = freezed,Object? etsyListingId = freezed,Object? printTimeMin = null,Object? plateCount = null,Object? weightG = null,Object? isActive = null,}) {
  return _then(_Variant(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sku: null == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String,salePrice: null == salePrice ? _self.salePrice : salePrice // ignore: cast_nullable_to_non_nullable
as double,printerId: freezed == printerId ? _self.printerId : printerId // ignore: cast_nullable_to_non_nullable
as int?,modelFile: freezed == modelFile ? _self.modelFile : modelFile // ignore: cast_nullable_to_non_nullable
as String?,etsyListingId: freezed == etsyListingId ? _self.etsyListingId : etsyListingId // ignore: cast_nullable_to_non_nullable
as String?,printTimeMin: null == printTimeMin ? _self.printTimeMin : printTimeMin // ignore: cast_nullable_to_non_nullable
as int,plateCount: null == plateCount ? _self.plateCount : plateCount // ignore: cast_nullable_to_non_nullable
as int,weightG: null == weightG ? _self.weightG : weightG // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
