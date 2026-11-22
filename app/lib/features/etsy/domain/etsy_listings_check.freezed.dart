// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'etsy_listings_check.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EtsyVariantRef {

 int get variantId; int? get productId;// para abrir a ficha do produto
 String? get sku; String get label;
/// Create a copy of EtsyVariantRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EtsyVariantRefCopyWith<EtsyVariantRef> get copyWith => _$EtsyVariantRefCopyWithImpl<EtsyVariantRef>(this as EtsyVariantRef, _$identity);

  /// Serializes this EtsyVariantRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EtsyVariantRef&&(identical(other.variantId, variantId) || other.variantId == variantId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,variantId,productId,sku,label);

@override
String toString() {
  return 'EtsyVariantRef(variantId: $variantId, productId: $productId, sku: $sku, label: $label)';
}


}

/// @nodoc
abstract mixin class $EtsyVariantRefCopyWith<$Res>  {
  factory $EtsyVariantRefCopyWith(EtsyVariantRef value, $Res Function(EtsyVariantRef) _then) = _$EtsyVariantRefCopyWithImpl;
@useResult
$Res call({
 int variantId, int? productId, String? sku, String label
});




}
/// @nodoc
class _$EtsyVariantRefCopyWithImpl<$Res>
    implements $EtsyVariantRefCopyWith<$Res> {
  _$EtsyVariantRefCopyWithImpl(this._self, this._then);

  final EtsyVariantRef _self;
  final $Res Function(EtsyVariantRef) _then;

/// Create a copy of EtsyVariantRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? variantId = null,Object? productId = freezed,Object? sku = freezed,Object? label = null,}) {
  return _then(_self.copyWith(
variantId: null == variantId ? _self.variantId : variantId // ignore: cast_nullable_to_non_nullable
as int,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int?,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [EtsyVariantRef].
extension EtsyVariantRefPatterns on EtsyVariantRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EtsyVariantRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EtsyVariantRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EtsyVariantRef value)  $default,){
final _that = this;
switch (_that) {
case _EtsyVariantRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EtsyVariantRef value)?  $default,){
final _that = this;
switch (_that) {
case _EtsyVariantRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int variantId,  int? productId,  String? sku,  String label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EtsyVariantRef() when $default != null:
return $default(_that.variantId,_that.productId,_that.sku,_that.label);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int variantId,  int? productId,  String? sku,  String label)  $default,) {final _that = this;
switch (_that) {
case _EtsyVariantRef():
return $default(_that.variantId,_that.productId,_that.sku,_that.label);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int variantId,  int? productId,  String? sku,  String label)?  $default,) {final _that = this;
switch (_that) {
case _EtsyVariantRef() when $default != null:
return $default(_that.variantId,_that.productId,_that.sku,_that.label);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EtsyVariantRef implements EtsyVariantRef {
  const _EtsyVariantRef({required this.variantId, this.productId, this.sku, required this.label});
  factory _EtsyVariantRef.fromJson(Map<String, dynamic> json) => _$EtsyVariantRefFromJson(json);

@override final  int variantId;
@override final  int? productId;
// para abrir a ficha do produto
@override final  String? sku;
@override final  String label;

/// Create a copy of EtsyVariantRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EtsyVariantRefCopyWith<_EtsyVariantRef> get copyWith => __$EtsyVariantRefCopyWithImpl<_EtsyVariantRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EtsyVariantRefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EtsyVariantRef&&(identical(other.variantId, variantId) || other.variantId == variantId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,variantId,productId,sku,label);

@override
String toString() {
  return 'EtsyVariantRef(variantId: $variantId, productId: $productId, sku: $sku, label: $label)';
}


}

/// @nodoc
abstract mixin class _$EtsyVariantRefCopyWith<$Res> implements $EtsyVariantRefCopyWith<$Res> {
  factory _$EtsyVariantRefCopyWith(_EtsyVariantRef value, $Res Function(_EtsyVariantRef) _then) = __$EtsyVariantRefCopyWithImpl;
@override @useResult
$Res call({
 int variantId, int? productId, String? sku, String label
});




}
/// @nodoc
class __$EtsyVariantRefCopyWithImpl<$Res>
    implements _$EtsyVariantRefCopyWith<$Res> {
  __$EtsyVariantRefCopyWithImpl(this._self, this._then);

  final _EtsyVariantRef _self;
  final $Res Function(_EtsyVariantRef) _then;

/// Create a copy of EtsyVariantRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? variantId = null,Object? productId = freezed,Object? sku = freezed,Object? label = null,}) {
  return _then(_EtsyVariantRef(
variantId: null == variantId ? _self.variantId : variantId // ignore: cast_nullable_to_non_nullable
as int,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int?,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$EtsyProductCheck {

 String? get productId;// o produto do anúncio na Etsy: é por ele que se associa à mão
 bool get linked;// liga porque foi associado à mão (e não pelo SKU)
 String? get sku; String get variation;// "Piloto: Hamilton"
 int get pack;// pack de quantidade: cada venda são N peças (a API reconhece "Quantidade: 10")
 String get status;// ok, unknown_sku, no_sku
 EtsyVariantRef? get variant;
/// Create a copy of EtsyProductCheck
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EtsyProductCheckCopyWith<EtsyProductCheck> get copyWith => _$EtsyProductCheckCopyWithImpl<EtsyProductCheck>(this as EtsyProductCheck, _$identity);

  /// Serializes this EtsyProductCheck to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EtsyProductCheck&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.linked, linked) || other.linked == linked)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.variation, variation) || other.variation == variation)&&(identical(other.pack, pack) || other.pack == pack)&&(identical(other.status, status) || other.status == status)&&(identical(other.variant, variant) || other.variant == variant));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,linked,sku,variation,pack,status,variant);

@override
String toString() {
  return 'EtsyProductCheck(productId: $productId, linked: $linked, sku: $sku, variation: $variation, pack: $pack, status: $status, variant: $variant)';
}


}

/// @nodoc
abstract mixin class $EtsyProductCheckCopyWith<$Res>  {
  factory $EtsyProductCheckCopyWith(EtsyProductCheck value, $Res Function(EtsyProductCheck) _then) = _$EtsyProductCheckCopyWithImpl;
@useResult
$Res call({
 String? productId, bool linked, String? sku, String variation, int pack, String status, EtsyVariantRef? variant
});


$EtsyVariantRefCopyWith<$Res>? get variant;

}
/// @nodoc
class _$EtsyProductCheckCopyWithImpl<$Res>
    implements $EtsyProductCheckCopyWith<$Res> {
  _$EtsyProductCheckCopyWithImpl(this._self, this._then);

  final EtsyProductCheck _self;
  final $Res Function(EtsyProductCheck) _then;

/// Create a copy of EtsyProductCheck
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = freezed,Object? linked = null,Object? sku = freezed,Object? variation = null,Object? pack = null,Object? status = null,Object? variant = freezed,}) {
  return _then(_self.copyWith(
productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,linked: null == linked ? _self.linked : linked // ignore: cast_nullable_to_non_nullable
as bool,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,variation: null == variation ? _self.variation : variation // ignore: cast_nullable_to_non_nullable
as String,pack: null == pack ? _self.pack : pack // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,variant: freezed == variant ? _self.variant : variant // ignore: cast_nullable_to_non_nullable
as EtsyVariantRef?,
  ));
}
/// Create a copy of EtsyProductCheck
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EtsyVariantRefCopyWith<$Res>? get variant {
    if (_self.variant == null) {
    return null;
  }

  return $EtsyVariantRefCopyWith<$Res>(_self.variant!, (value) {
    return _then(_self.copyWith(variant: value));
  });
}
}


/// Adds pattern-matching-related methods to [EtsyProductCheck].
extension EtsyProductCheckPatterns on EtsyProductCheck {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EtsyProductCheck value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EtsyProductCheck() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EtsyProductCheck value)  $default,){
final _that = this;
switch (_that) {
case _EtsyProductCheck():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EtsyProductCheck value)?  $default,){
final _that = this;
switch (_that) {
case _EtsyProductCheck() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? productId,  bool linked,  String? sku,  String variation,  int pack,  String status,  EtsyVariantRef? variant)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EtsyProductCheck() when $default != null:
return $default(_that.productId,_that.linked,_that.sku,_that.variation,_that.pack,_that.status,_that.variant);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? productId,  bool linked,  String? sku,  String variation,  int pack,  String status,  EtsyVariantRef? variant)  $default,) {final _that = this;
switch (_that) {
case _EtsyProductCheck():
return $default(_that.productId,_that.linked,_that.sku,_that.variation,_that.pack,_that.status,_that.variant);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? productId,  bool linked,  String? sku,  String variation,  int pack,  String status,  EtsyVariantRef? variant)?  $default,) {final _that = this;
switch (_that) {
case _EtsyProductCheck() when $default != null:
return $default(_that.productId,_that.linked,_that.sku,_that.variation,_that.pack,_that.status,_that.variant);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EtsyProductCheck extends EtsyProductCheck {
  const _EtsyProductCheck({this.productId, this.linked = false, this.sku, this.variation = "", this.pack = 1, required this.status, this.variant}): super._();
  factory _EtsyProductCheck.fromJson(Map<String, dynamic> json) => _$EtsyProductCheckFromJson(json);

@override final  String? productId;
// o produto do anúncio na Etsy: é por ele que se associa à mão
@override@JsonKey() final  bool linked;
// liga porque foi associado à mão (e não pelo SKU)
@override final  String? sku;
@override@JsonKey() final  String variation;
// "Piloto: Hamilton"
@override@JsonKey() final  int pack;
// pack de quantidade: cada venda são N peças (a API reconhece "Quantidade: 10")
@override final  String status;
// ok, unknown_sku, no_sku
@override final  EtsyVariantRef? variant;

/// Create a copy of EtsyProductCheck
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EtsyProductCheckCopyWith<_EtsyProductCheck> get copyWith => __$EtsyProductCheckCopyWithImpl<_EtsyProductCheck>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EtsyProductCheckToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EtsyProductCheck&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.linked, linked) || other.linked == linked)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.variation, variation) || other.variation == variation)&&(identical(other.pack, pack) || other.pack == pack)&&(identical(other.status, status) || other.status == status)&&(identical(other.variant, variant) || other.variant == variant));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,linked,sku,variation,pack,status,variant);

@override
String toString() {
  return 'EtsyProductCheck(productId: $productId, linked: $linked, sku: $sku, variation: $variation, pack: $pack, status: $status, variant: $variant)';
}


}

/// @nodoc
abstract mixin class _$EtsyProductCheckCopyWith<$Res> implements $EtsyProductCheckCopyWith<$Res> {
  factory _$EtsyProductCheckCopyWith(_EtsyProductCheck value, $Res Function(_EtsyProductCheck) _then) = __$EtsyProductCheckCopyWithImpl;
@override @useResult
$Res call({
 String? productId, bool linked, String? sku, String variation, int pack, String status, EtsyVariantRef? variant
});


@override $EtsyVariantRefCopyWith<$Res>? get variant;

}
/// @nodoc
class __$EtsyProductCheckCopyWithImpl<$Res>
    implements _$EtsyProductCheckCopyWith<$Res> {
  __$EtsyProductCheckCopyWithImpl(this._self, this._then);

  final _EtsyProductCheck _self;
  final $Res Function(_EtsyProductCheck) _then;

/// Create a copy of EtsyProductCheck
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = freezed,Object? linked = null,Object? sku = freezed,Object? variation = null,Object? pack = null,Object? status = null,Object? variant = freezed,}) {
  return _then(_EtsyProductCheck(
productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,linked: null == linked ? _self.linked : linked // ignore: cast_nullable_to_non_nullable
as bool,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,variation: null == variation ? _self.variation : variation // ignore: cast_nullable_to_non_nullable
as String,pack: null == pack ? _self.pack : pack // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,variant: freezed == variant ? _self.variant : variant // ignore: cast_nullable_to_non_nullable
as EtsyVariantRef?,
  ));
}

/// Create a copy of EtsyProductCheck
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EtsyVariantRefCopyWith<$Res>? get variant {
    if (_self.variant == null) {
    return null;
  }

  return $EtsyVariantRefCopyWith<$Res>(_self.variant!, (value) {
    return _then(_self.copyWith(variant: value));
  });
}
}


/// @nodoc
mixin _$EtsyListingCheck {

 String get listingId; String get title; String get url; List<EtsyProductCheck> get products;
/// Create a copy of EtsyListingCheck
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EtsyListingCheckCopyWith<EtsyListingCheck> get copyWith => _$EtsyListingCheckCopyWithImpl<EtsyListingCheck>(this as EtsyListingCheck, _$identity);

  /// Serializes this EtsyListingCheck to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EtsyListingCheck&&(identical(other.listingId, listingId) || other.listingId == listingId)&&(identical(other.title, title) || other.title == title)&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other.products, products));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,listingId,title,url,const DeepCollectionEquality().hash(products));

@override
String toString() {
  return 'EtsyListingCheck(listingId: $listingId, title: $title, url: $url, products: $products)';
}


}

/// @nodoc
abstract mixin class $EtsyListingCheckCopyWith<$Res>  {
  factory $EtsyListingCheckCopyWith(EtsyListingCheck value, $Res Function(EtsyListingCheck) _then) = _$EtsyListingCheckCopyWithImpl;
@useResult
$Res call({
 String listingId, String title, String url, List<EtsyProductCheck> products
});




}
/// @nodoc
class _$EtsyListingCheckCopyWithImpl<$Res>
    implements $EtsyListingCheckCopyWith<$Res> {
  _$EtsyListingCheckCopyWithImpl(this._self, this._then);

  final EtsyListingCheck _self;
  final $Res Function(EtsyListingCheck) _then;

/// Create a copy of EtsyListingCheck
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? listingId = null,Object? title = null,Object? url = null,Object? products = null,}) {
  return _then(_self.copyWith(
listingId: null == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,products: null == products ? _self.products : products // ignore: cast_nullable_to_non_nullable
as List<EtsyProductCheck>,
  ));
}

}


/// Adds pattern-matching-related methods to [EtsyListingCheck].
extension EtsyListingCheckPatterns on EtsyListingCheck {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EtsyListingCheck value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EtsyListingCheck() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EtsyListingCheck value)  $default,){
final _that = this;
switch (_that) {
case _EtsyListingCheck():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EtsyListingCheck value)?  $default,){
final _that = this;
switch (_that) {
case _EtsyListingCheck() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String listingId,  String title,  String url,  List<EtsyProductCheck> products)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EtsyListingCheck() when $default != null:
return $default(_that.listingId,_that.title,_that.url,_that.products);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String listingId,  String title,  String url,  List<EtsyProductCheck> products)  $default,) {final _that = this;
switch (_that) {
case _EtsyListingCheck():
return $default(_that.listingId,_that.title,_that.url,_that.products);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String listingId,  String title,  String url,  List<EtsyProductCheck> products)?  $default,) {final _that = this;
switch (_that) {
case _EtsyListingCheck() when $default != null:
return $default(_that.listingId,_that.title,_that.url,_that.products);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EtsyListingCheck extends EtsyListingCheck {
  const _EtsyListingCheck({required this.listingId, required this.title, this.url = "", final  List<EtsyProductCheck> products = const []}): _products = products,super._();
  factory _EtsyListingCheck.fromJson(Map<String, dynamic> json) => _$EtsyListingCheckFromJson(json);

@override final  String listingId;
@override final  String title;
@override@JsonKey() final  String url;
 final  List<EtsyProductCheck> _products;
@override@JsonKey() List<EtsyProductCheck> get products {
  if (_products is EqualUnmodifiableListView) return _products;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_products);
}


/// Create a copy of EtsyListingCheck
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EtsyListingCheckCopyWith<_EtsyListingCheck> get copyWith => __$EtsyListingCheckCopyWithImpl<_EtsyListingCheck>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EtsyListingCheckToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EtsyListingCheck&&(identical(other.listingId, listingId) || other.listingId == listingId)&&(identical(other.title, title) || other.title == title)&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other._products, _products));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,listingId,title,url,const DeepCollectionEquality().hash(_products));

@override
String toString() {
  return 'EtsyListingCheck(listingId: $listingId, title: $title, url: $url, products: $products)';
}


}

/// @nodoc
abstract mixin class _$EtsyListingCheckCopyWith<$Res> implements $EtsyListingCheckCopyWith<$Res> {
  factory _$EtsyListingCheckCopyWith(_EtsyListingCheck value, $Res Function(_EtsyListingCheck) _then) = __$EtsyListingCheckCopyWithImpl;
@override @useResult
$Res call({
 String listingId, String title, String url, List<EtsyProductCheck> products
});




}
/// @nodoc
class __$EtsyListingCheckCopyWithImpl<$Res>
    implements _$EtsyListingCheckCopyWith<$Res> {
  __$EtsyListingCheckCopyWithImpl(this._self, this._then);

  final _EtsyListingCheck _self;
  final $Res Function(_EtsyListingCheck) _then;

/// Create a copy of EtsyListingCheck
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? listingId = null,Object? title = null,Object? url = null,Object? products = null,}) {
  return _then(_EtsyListingCheck(
listingId: null == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,products: null == products ? _self._products : products // ignore: cast_nullable_to_non_nullable
as List<EtsyProductCheck>,
  ));
}


}


/// @nodoc
mixin _$EtsyListingsCheck {

 DateTime get checkedAt; int get ok; int get problems;/// Anúncios digitais (downloads) que não se conferem: não entram na app.
 int get digitalSkipped; List<EtsyListingCheck> get listings;/// Variantes da app que nenhum anúncio usa (não é erro: podem não estar à venda na Etsy).
 List<EtsyVariantRef> get unlistedVariants;/// Todas as variantes ativas da app, para escolher uma ao associar à mão.
 List<EtsyVariantRef> get variants;
/// Create a copy of EtsyListingsCheck
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EtsyListingsCheckCopyWith<EtsyListingsCheck> get copyWith => _$EtsyListingsCheckCopyWithImpl<EtsyListingsCheck>(this as EtsyListingsCheck, _$identity);

  /// Serializes this EtsyListingsCheck to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EtsyListingsCheck&&(identical(other.checkedAt, checkedAt) || other.checkedAt == checkedAt)&&(identical(other.ok, ok) || other.ok == ok)&&(identical(other.problems, problems) || other.problems == problems)&&(identical(other.digitalSkipped, digitalSkipped) || other.digitalSkipped == digitalSkipped)&&const DeepCollectionEquality().equals(other.listings, listings)&&const DeepCollectionEquality().equals(other.unlistedVariants, unlistedVariants)&&const DeepCollectionEquality().equals(other.variants, variants));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,checkedAt,ok,problems,digitalSkipped,const DeepCollectionEquality().hash(listings),const DeepCollectionEquality().hash(unlistedVariants),const DeepCollectionEquality().hash(variants));

@override
String toString() {
  return 'EtsyListingsCheck(checkedAt: $checkedAt, ok: $ok, problems: $problems, digitalSkipped: $digitalSkipped, listings: $listings, unlistedVariants: $unlistedVariants, variants: $variants)';
}


}

/// @nodoc
abstract mixin class $EtsyListingsCheckCopyWith<$Res>  {
  factory $EtsyListingsCheckCopyWith(EtsyListingsCheck value, $Res Function(EtsyListingsCheck) _then) = _$EtsyListingsCheckCopyWithImpl;
@useResult
$Res call({
 DateTime checkedAt, int ok, int problems, int digitalSkipped, List<EtsyListingCheck> listings, List<EtsyVariantRef> unlistedVariants, List<EtsyVariantRef> variants
});




}
/// @nodoc
class _$EtsyListingsCheckCopyWithImpl<$Res>
    implements $EtsyListingsCheckCopyWith<$Res> {
  _$EtsyListingsCheckCopyWithImpl(this._self, this._then);

  final EtsyListingsCheck _self;
  final $Res Function(EtsyListingsCheck) _then;

/// Create a copy of EtsyListingsCheck
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? checkedAt = null,Object? ok = null,Object? problems = null,Object? digitalSkipped = null,Object? listings = null,Object? unlistedVariants = null,Object? variants = null,}) {
  return _then(_self.copyWith(
checkedAt: null == checkedAt ? _self.checkedAt : checkedAt // ignore: cast_nullable_to_non_nullable
as DateTime,ok: null == ok ? _self.ok : ok // ignore: cast_nullable_to_non_nullable
as int,problems: null == problems ? _self.problems : problems // ignore: cast_nullable_to_non_nullable
as int,digitalSkipped: null == digitalSkipped ? _self.digitalSkipped : digitalSkipped // ignore: cast_nullable_to_non_nullable
as int,listings: null == listings ? _self.listings : listings // ignore: cast_nullable_to_non_nullable
as List<EtsyListingCheck>,unlistedVariants: null == unlistedVariants ? _self.unlistedVariants : unlistedVariants // ignore: cast_nullable_to_non_nullable
as List<EtsyVariantRef>,variants: null == variants ? _self.variants : variants // ignore: cast_nullable_to_non_nullable
as List<EtsyVariantRef>,
  ));
}

}


/// Adds pattern-matching-related methods to [EtsyListingsCheck].
extension EtsyListingsCheckPatterns on EtsyListingsCheck {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EtsyListingsCheck value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EtsyListingsCheck() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EtsyListingsCheck value)  $default,){
final _that = this;
switch (_that) {
case _EtsyListingsCheck():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EtsyListingsCheck value)?  $default,){
final _that = this;
switch (_that) {
case _EtsyListingsCheck() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime checkedAt,  int ok,  int problems,  int digitalSkipped,  List<EtsyListingCheck> listings,  List<EtsyVariantRef> unlistedVariants,  List<EtsyVariantRef> variants)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EtsyListingsCheck() when $default != null:
return $default(_that.checkedAt,_that.ok,_that.problems,_that.digitalSkipped,_that.listings,_that.unlistedVariants,_that.variants);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime checkedAt,  int ok,  int problems,  int digitalSkipped,  List<EtsyListingCheck> listings,  List<EtsyVariantRef> unlistedVariants,  List<EtsyVariantRef> variants)  $default,) {final _that = this;
switch (_that) {
case _EtsyListingsCheck():
return $default(_that.checkedAt,_that.ok,_that.problems,_that.digitalSkipped,_that.listings,_that.unlistedVariants,_that.variants);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime checkedAt,  int ok,  int problems,  int digitalSkipped,  List<EtsyListingCheck> listings,  List<EtsyVariantRef> unlistedVariants,  List<EtsyVariantRef> variants)?  $default,) {final _that = this;
switch (_that) {
case _EtsyListingsCheck() when $default != null:
return $default(_that.checkedAt,_that.ok,_that.problems,_that.digitalSkipped,_that.listings,_that.unlistedVariants,_that.variants);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EtsyListingsCheck extends EtsyListingsCheck {
  const _EtsyListingsCheck({required this.checkedAt, this.ok = 0, this.problems = 0, this.digitalSkipped = 0, final  List<EtsyListingCheck> listings = const [], final  List<EtsyVariantRef> unlistedVariants = const [], final  List<EtsyVariantRef> variants = const []}): _listings = listings,_unlistedVariants = unlistedVariants,_variants = variants,super._();
  factory _EtsyListingsCheck.fromJson(Map<String, dynamic> json) => _$EtsyListingsCheckFromJson(json);

@override final  DateTime checkedAt;
@override@JsonKey() final  int ok;
@override@JsonKey() final  int problems;
/// Anúncios digitais (downloads) que não se conferem: não entram na app.
@override@JsonKey() final  int digitalSkipped;
 final  List<EtsyListingCheck> _listings;
@override@JsonKey() List<EtsyListingCheck> get listings {
  if (_listings is EqualUnmodifiableListView) return _listings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_listings);
}

/// Variantes da app que nenhum anúncio usa (não é erro: podem não estar à venda na Etsy).
 final  List<EtsyVariantRef> _unlistedVariants;
/// Variantes da app que nenhum anúncio usa (não é erro: podem não estar à venda na Etsy).
@override@JsonKey() List<EtsyVariantRef> get unlistedVariants {
  if (_unlistedVariants is EqualUnmodifiableListView) return _unlistedVariants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_unlistedVariants);
}

/// Todas as variantes ativas da app, para escolher uma ao associar à mão.
 final  List<EtsyVariantRef> _variants;
/// Todas as variantes ativas da app, para escolher uma ao associar à mão.
@override@JsonKey() List<EtsyVariantRef> get variants {
  if (_variants is EqualUnmodifiableListView) return _variants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_variants);
}


/// Create a copy of EtsyListingsCheck
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EtsyListingsCheckCopyWith<_EtsyListingsCheck> get copyWith => __$EtsyListingsCheckCopyWithImpl<_EtsyListingsCheck>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EtsyListingsCheckToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EtsyListingsCheck&&(identical(other.checkedAt, checkedAt) || other.checkedAt == checkedAt)&&(identical(other.ok, ok) || other.ok == ok)&&(identical(other.problems, problems) || other.problems == problems)&&(identical(other.digitalSkipped, digitalSkipped) || other.digitalSkipped == digitalSkipped)&&const DeepCollectionEquality().equals(other._listings, _listings)&&const DeepCollectionEquality().equals(other._unlistedVariants, _unlistedVariants)&&const DeepCollectionEquality().equals(other._variants, _variants));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,checkedAt,ok,problems,digitalSkipped,const DeepCollectionEquality().hash(_listings),const DeepCollectionEquality().hash(_unlistedVariants),const DeepCollectionEquality().hash(_variants));

@override
String toString() {
  return 'EtsyListingsCheck(checkedAt: $checkedAt, ok: $ok, problems: $problems, digitalSkipped: $digitalSkipped, listings: $listings, unlistedVariants: $unlistedVariants, variants: $variants)';
}


}

/// @nodoc
abstract mixin class _$EtsyListingsCheckCopyWith<$Res> implements $EtsyListingsCheckCopyWith<$Res> {
  factory _$EtsyListingsCheckCopyWith(_EtsyListingsCheck value, $Res Function(_EtsyListingsCheck) _then) = __$EtsyListingsCheckCopyWithImpl;
@override @useResult
$Res call({
 DateTime checkedAt, int ok, int problems, int digitalSkipped, List<EtsyListingCheck> listings, List<EtsyVariantRef> unlistedVariants, List<EtsyVariantRef> variants
});




}
/// @nodoc
class __$EtsyListingsCheckCopyWithImpl<$Res>
    implements _$EtsyListingsCheckCopyWith<$Res> {
  __$EtsyListingsCheckCopyWithImpl(this._self, this._then);

  final _EtsyListingsCheck _self;
  final $Res Function(_EtsyListingsCheck) _then;

/// Create a copy of EtsyListingsCheck
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? checkedAt = null,Object? ok = null,Object? problems = null,Object? digitalSkipped = null,Object? listings = null,Object? unlistedVariants = null,Object? variants = null,}) {
  return _then(_EtsyListingsCheck(
checkedAt: null == checkedAt ? _self.checkedAt : checkedAt // ignore: cast_nullable_to_non_nullable
as DateTime,ok: null == ok ? _self.ok : ok // ignore: cast_nullable_to_non_nullable
as int,problems: null == problems ? _self.problems : problems // ignore: cast_nullable_to_non_nullable
as int,digitalSkipped: null == digitalSkipped ? _self.digitalSkipped : digitalSkipped // ignore: cast_nullable_to_non_nullable
as int,listings: null == listings ? _self._listings : listings // ignore: cast_nullable_to_non_nullable
as List<EtsyListingCheck>,unlistedVariants: null == unlistedVariants ? _self._unlistedVariants : unlistedVariants // ignore: cast_nullable_to_non_nullable
as List<EtsyVariantRef>,variants: null == variants ? _self._variants : variants // ignore: cast_nullable_to_non_nullable
as List<EtsyVariantRef>,
  ));
}


}

// dart format on
