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
 bool get isActive; List<VariantFilament> get filaments;// que filamentos e quantas gramas
 List<VariantComponent> get components;
/// Create a copy of Variant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VariantCopyWith<Variant> get copyWith => _$VariantCopyWithImpl<Variant>(this as Variant, _$identity);

  /// Serializes this Variant to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Variant&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.salePrice, salePrice) || other.salePrice == salePrice)&&(identical(other.printerId, printerId) || other.printerId == printerId)&&(identical(other.modelFile, modelFile) || other.modelFile == modelFile)&&(identical(other.etsyListingId, etsyListingId) || other.etsyListingId == etsyListingId)&&(identical(other.printTimeMin, printTimeMin) || other.printTimeMin == printTimeMin)&&(identical(other.plateCount, plateCount) || other.plateCount == plateCount)&&(identical(other.weightG, weightG) || other.weightG == weightG)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&const DeepCollectionEquality().equals(other.filaments, filaments)&&const DeepCollectionEquality().equals(other.components, components));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productId,name,sku,salePrice,printerId,modelFile,etsyListingId,printTimeMin,plateCount,weightG,isActive,const DeepCollectionEquality().hash(filaments),const DeepCollectionEquality().hash(components));

@override
String toString() {
  return 'Variant(id: $id, productId: $productId, name: $name, sku: $sku, salePrice: $salePrice, printerId: $printerId, modelFile: $modelFile, etsyListingId: $etsyListingId, printTimeMin: $printTimeMin, plateCount: $plateCount, weightG: $weightG, isActive: $isActive, filaments: $filaments, components: $components)';
}


}

/// @nodoc
abstract mixin class $VariantCopyWith<$Res>  {
  factory $VariantCopyWith(Variant value, $Res Function(Variant) _then) = _$VariantCopyWithImpl;
@useResult
$Res call({
 int id, int productId, String name, String sku, double salePrice, int? printerId, String? modelFile, String? etsyListingId, int printTimeMin, int plateCount, int weightG, bool isActive, List<VariantFilament> filaments, List<VariantComponent> components
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? productId = null,Object? name = null,Object? sku = null,Object? salePrice = null,Object? printerId = freezed,Object? modelFile = freezed,Object? etsyListingId = freezed,Object? printTimeMin = null,Object? plateCount = null,Object? weightG = null,Object? isActive = null,Object? filaments = null,Object? components = null,}) {
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
as bool,filaments: null == filaments ? _self.filaments : filaments // ignore: cast_nullable_to_non_nullable
as List<VariantFilament>,components: null == components ? _self.components : components // ignore: cast_nullable_to_non_nullable
as List<VariantComponent>,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int productId,  String name,  String sku,  double salePrice,  int? printerId,  String? modelFile,  String? etsyListingId,  int printTimeMin,  int plateCount,  int weightG,  bool isActive,  List<VariantFilament> filaments,  List<VariantComponent> components)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Variant() when $default != null:
return $default(_that.id,_that.productId,_that.name,_that.sku,_that.salePrice,_that.printerId,_that.modelFile,_that.etsyListingId,_that.printTimeMin,_that.plateCount,_that.weightG,_that.isActive,_that.filaments,_that.components);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int productId,  String name,  String sku,  double salePrice,  int? printerId,  String? modelFile,  String? etsyListingId,  int printTimeMin,  int plateCount,  int weightG,  bool isActive,  List<VariantFilament> filaments,  List<VariantComponent> components)  $default,) {final _that = this;
switch (_that) {
case _Variant():
return $default(_that.id,_that.productId,_that.name,_that.sku,_that.salePrice,_that.printerId,_that.modelFile,_that.etsyListingId,_that.printTimeMin,_that.plateCount,_that.weightG,_that.isActive,_that.filaments,_that.components);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int productId,  String name,  String sku,  double salePrice,  int? printerId,  String? modelFile,  String? etsyListingId,  int printTimeMin,  int plateCount,  int weightG,  bool isActive,  List<VariantFilament> filaments,  List<VariantComponent> components)?  $default,) {final _that = this;
switch (_that) {
case _Variant() when $default != null:
return $default(_that.id,_that.productId,_that.name,_that.sku,_that.salePrice,_that.printerId,_that.modelFile,_that.etsyListingId,_that.printTimeMin,_that.plateCount,_that.weightG,_that.isActive,_that.filaments,_that.components);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Variant implements Variant {
  const _Variant({required this.id, required this.productId, required this.name, required this.sku, required this.salePrice, this.printerId, this.modelFile, this.etsyListingId, this.printTimeMin = 0, this.plateCount = 1, this.weightG = 0, this.isActive = true, final  List<VariantFilament> filaments = const [], final  List<VariantComponent> components = const []}): _filaments = filaments,_components = components;
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
 final  List<VariantFilament> _filaments;
@override@JsonKey() List<VariantFilament> get filaments {
  if (_filaments is EqualUnmodifiableListView) return _filaments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_filaments);
}

// que filamentos e quantas gramas
 final  List<VariantComponent> _components;
// que filamentos e quantas gramas
@override@JsonKey() List<VariantComponent> get components {
  if (_components is EqualUnmodifiableListView) return _components;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_components);
}


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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Variant&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.salePrice, salePrice) || other.salePrice == salePrice)&&(identical(other.printerId, printerId) || other.printerId == printerId)&&(identical(other.modelFile, modelFile) || other.modelFile == modelFile)&&(identical(other.etsyListingId, etsyListingId) || other.etsyListingId == etsyListingId)&&(identical(other.printTimeMin, printTimeMin) || other.printTimeMin == printTimeMin)&&(identical(other.plateCount, plateCount) || other.plateCount == plateCount)&&(identical(other.weightG, weightG) || other.weightG == weightG)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&const DeepCollectionEquality().equals(other._filaments, _filaments)&&const DeepCollectionEquality().equals(other._components, _components));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productId,name,sku,salePrice,printerId,modelFile,etsyListingId,printTimeMin,plateCount,weightG,isActive,const DeepCollectionEquality().hash(_filaments),const DeepCollectionEquality().hash(_components));

@override
String toString() {
  return 'Variant(id: $id, productId: $productId, name: $name, sku: $sku, salePrice: $salePrice, printerId: $printerId, modelFile: $modelFile, etsyListingId: $etsyListingId, printTimeMin: $printTimeMin, plateCount: $plateCount, weightG: $weightG, isActive: $isActive, filaments: $filaments, components: $components)';
}


}

/// @nodoc
abstract mixin class _$VariantCopyWith<$Res> implements $VariantCopyWith<$Res> {
  factory _$VariantCopyWith(_Variant value, $Res Function(_Variant) _then) = __$VariantCopyWithImpl;
@override @useResult
$Res call({
 int id, int productId, String name, String sku, double salePrice, int? printerId, String? modelFile, String? etsyListingId, int printTimeMin, int plateCount, int weightG, bool isActive, List<VariantFilament> filaments, List<VariantComponent> components
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? productId = null,Object? name = null,Object? sku = null,Object? salePrice = null,Object? printerId = freezed,Object? modelFile = freezed,Object? etsyListingId = freezed,Object? printTimeMin = null,Object? plateCount = null,Object? weightG = null,Object? isActive = null,Object? filaments = null,Object? components = null,}) {
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
as bool,filaments: null == filaments ? _self._filaments : filaments // ignore: cast_nullable_to_non_nullable
as List<VariantFilament>,components: null == components ? _self._components : components // ignore: cast_nullable_to_non_nullable
as List<VariantComponent>,
  ));
}


}


/// @nodoc
mixin _$VariantFilament {

 int get filamentId; int get grams;
/// Create a copy of VariantFilament
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VariantFilamentCopyWith<VariantFilament> get copyWith => _$VariantFilamentCopyWithImpl<VariantFilament>(this as VariantFilament, _$identity);

  /// Serializes this VariantFilament to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VariantFilament&&(identical(other.filamentId, filamentId) || other.filamentId == filamentId)&&(identical(other.grams, grams) || other.grams == grams));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,filamentId,grams);

@override
String toString() {
  return 'VariantFilament(filamentId: $filamentId, grams: $grams)';
}


}

/// @nodoc
abstract mixin class $VariantFilamentCopyWith<$Res>  {
  factory $VariantFilamentCopyWith(VariantFilament value, $Res Function(VariantFilament) _then) = _$VariantFilamentCopyWithImpl;
@useResult
$Res call({
 int filamentId, int grams
});




}
/// @nodoc
class _$VariantFilamentCopyWithImpl<$Res>
    implements $VariantFilamentCopyWith<$Res> {
  _$VariantFilamentCopyWithImpl(this._self, this._then);

  final VariantFilament _self;
  final $Res Function(VariantFilament) _then;

/// Create a copy of VariantFilament
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? filamentId = null,Object? grams = null,}) {
  return _then(_self.copyWith(
filamentId: null == filamentId ? _self.filamentId : filamentId // ignore: cast_nullable_to_non_nullable
as int,grams: null == grams ? _self.grams : grams // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [VariantFilament].
extension VariantFilamentPatterns on VariantFilament {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VariantFilament value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VariantFilament() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VariantFilament value)  $default,){
final _that = this;
switch (_that) {
case _VariantFilament():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VariantFilament value)?  $default,){
final _that = this;
switch (_that) {
case _VariantFilament() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int filamentId,  int grams)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VariantFilament() when $default != null:
return $default(_that.filamentId,_that.grams);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int filamentId,  int grams)  $default,) {final _that = this;
switch (_that) {
case _VariantFilament():
return $default(_that.filamentId,_that.grams);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int filamentId,  int grams)?  $default,) {final _that = this;
switch (_that) {
case _VariantFilament() when $default != null:
return $default(_that.filamentId,_that.grams);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VariantFilament implements VariantFilament {
  const _VariantFilament({required this.filamentId, required this.grams});
  factory _VariantFilament.fromJson(Map<String, dynamic> json) => _$VariantFilamentFromJson(json);

@override final  int filamentId;
@override final  int grams;

/// Create a copy of VariantFilament
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VariantFilamentCopyWith<_VariantFilament> get copyWith => __$VariantFilamentCopyWithImpl<_VariantFilament>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VariantFilamentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VariantFilament&&(identical(other.filamentId, filamentId) || other.filamentId == filamentId)&&(identical(other.grams, grams) || other.grams == grams));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,filamentId,grams);

@override
String toString() {
  return 'VariantFilament(filamentId: $filamentId, grams: $grams)';
}


}

/// @nodoc
abstract mixin class _$VariantFilamentCopyWith<$Res> implements $VariantFilamentCopyWith<$Res> {
  factory _$VariantFilamentCopyWith(_VariantFilament value, $Res Function(_VariantFilament) _then) = __$VariantFilamentCopyWithImpl;
@override @useResult
$Res call({
 int filamentId, int grams
});




}
/// @nodoc
class __$VariantFilamentCopyWithImpl<$Res>
    implements _$VariantFilamentCopyWith<$Res> {
  __$VariantFilamentCopyWithImpl(this._self, this._then);

  final _VariantFilament _self;
  final $Res Function(_VariantFilament) _then;

/// Create a copy of VariantFilament
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? filamentId = null,Object? grams = null,}) {
  return _then(_VariantFilament(
filamentId: null == filamentId ? _self.filamentId : filamentId // ignore: cast_nullable_to_non_nullable
as int,grams: null == grams ? _self.grams : grams // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$VariantComponent {

 int get componentId; int get quantity;
/// Create a copy of VariantComponent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VariantComponentCopyWith<VariantComponent> get copyWith => _$VariantComponentCopyWithImpl<VariantComponent>(this as VariantComponent, _$identity);

  /// Serializes this VariantComponent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VariantComponent&&(identical(other.componentId, componentId) || other.componentId == componentId)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,componentId,quantity);

@override
String toString() {
  return 'VariantComponent(componentId: $componentId, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class $VariantComponentCopyWith<$Res>  {
  factory $VariantComponentCopyWith(VariantComponent value, $Res Function(VariantComponent) _then) = _$VariantComponentCopyWithImpl;
@useResult
$Res call({
 int componentId, int quantity
});




}
/// @nodoc
class _$VariantComponentCopyWithImpl<$Res>
    implements $VariantComponentCopyWith<$Res> {
  _$VariantComponentCopyWithImpl(this._self, this._then);

  final VariantComponent _self;
  final $Res Function(VariantComponent) _then;

/// Create a copy of VariantComponent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? componentId = null,Object? quantity = null,}) {
  return _then(_self.copyWith(
componentId: null == componentId ? _self.componentId : componentId // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [VariantComponent].
extension VariantComponentPatterns on VariantComponent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VariantComponent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VariantComponent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VariantComponent value)  $default,){
final _that = this;
switch (_that) {
case _VariantComponent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VariantComponent value)?  $default,){
final _that = this;
switch (_that) {
case _VariantComponent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int componentId,  int quantity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VariantComponent() when $default != null:
return $default(_that.componentId,_that.quantity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int componentId,  int quantity)  $default,) {final _that = this;
switch (_that) {
case _VariantComponent():
return $default(_that.componentId,_that.quantity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int componentId,  int quantity)?  $default,) {final _that = this;
switch (_that) {
case _VariantComponent() when $default != null:
return $default(_that.componentId,_that.quantity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VariantComponent implements VariantComponent {
  const _VariantComponent({required this.componentId, this.quantity = 1});
  factory _VariantComponent.fromJson(Map<String, dynamic> json) => _$VariantComponentFromJson(json);

@override final  int componentId;
@override@JsonKey() final  int quantity;

/// Create a copy of VariantComponent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VariantComponentCopyWith<_VariantComponent> get copyWith => __$VariantComponentCopyWithImpl<_VariantComponent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VariantComponentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VariantComponent&&(identical(other.componentId, componentId) || other.componentId == componentId)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,componentId,quantity);

@override
String toString() {
  return 'VariantComponent(componentId: $componentId, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class _$VariantComponentCopyWith<$Res> implements $VariantComponentCopyWith<$Res> {
  factory _$VariantComponentCopyWith(_VariantComponent value, $Res Function(_VariantComponent) _then) = __$VariantComponentCopyWithImpl;
@override @useResult
$Res call({
 int componentId, int quantity
});




}
/// @nodoc
class __$VariantComponentCopyWithImpl<$Res>
    implements _$VariantComponentCopyWith<$Res> {
  __$VariantComponentCopyWithImpl(this._self, this._then);

  final _VariantComponent _self;
  final $Res Function(_VariantComponent) _then;

/// Create a copy of VariantComponent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? componentId = null,Object? quantity = null,}) {
  return _then(_VariantComponent(
componentId: null == componentId ? _self.componentId : componentId // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
