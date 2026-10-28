// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Product {

 int get id; String get name; String get baseSku; String? get description; int? get categoryId; DateTime get createdAt; DateTime get updatedAt;// o valor por omissao vive aqui: o JSON pode nao trazer o campo
 ProductStatus get status;// se nao vier, assume este valor
 bool get isCustomizable;// se nao vier, assume este valor
 bool get isPack;
/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductCopyWith<Product> get copyWith => _$ProductCopyWithImpl<Product>(this as Product, _$identity);

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Product&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.baseSku, baseSku) || other.baseSku == baseSku)&&(identical(other.description, description) || other.description == description)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.isCustomizable, isCustomizable) || other.isCustomizable == isCustomizable)&&(identical(other.isPack, isPack) || other.isPack == isPack));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,baseSku,description,categoryId,createdAt,updatedAt,status,isCustomizable,isPack);

@override
String toString() {
  return 'Product(id: $id, name: $name, baseSku: $baseSku, description: $description, categoryId: $categoryId, createdAt: $createdAt, updatedAt: $updatedAt, status: $status, isCustomizable: $isCustomizable, isPack: $isPack)';
}


}

/// @nodoc
abstract mixin class $ProductCopyWith<$Res>  {
  factory $ProductCopyWith(Product value, $Res Function(Product) _then) = _$ProductCopyWithImpl;
@useResult
$Res call({
 int id, String name, String baseSku, String? description, int? categoryId, DateTime createdAt, DateTime updatedAt, ProductStatus status, bool isCustomizable, bool isPack
});




}
/// @nodoc
class _$ProductCopyWithImpl<$Res>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._self, this._then);

  final Product _self;
  final $Res Function(Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? baseSku = null,Object? description = freezed,Object? categoryId = freezed,Object? createdAt = null,Object? updatedAt = null,Object? status = null,Object? isCustomizable = null,Object? isPack = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,baseSku: null == baseSku ? _self.baseSku : baseSku // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProductStatus,isCustomizable: null == isCustomizable ? _self.isCustomizable : isCustomizable // ignore: cast_nullable_to_non_nullable
as bool,isPack: null == isPack ? _self.isPack : isPack // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Product].
extension ProductPatterns on Product {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Product value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Product value)  $default,){
final _that = this;
switch (_that) {
case _Product():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Product value)?  $default,){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String baseSku,  String? description,  int? categoryId,  DateTime createdAt,  DateTime updatedAt,  ProductStatus status,  bool isCustomizable,  bool isPack)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.name,_that.baseSku,_that.description,_that.categoryId,_that.createdAt,_that.updatedAt,_that.status,_that.isCustomizable,_that.isPack);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String baseSku,  String? description,  int? categoryId,  DateTime createdAt,  DateTime updatedAt,  ProductStatus status,  bool isCustomizable,  bool isPack)  $default,) {final _that = this;
switch (_that) {
case _Product():
return $default(_that.id,_that.name,_that.baseSku,_that.description,_that.categoryId,_that.createdAt,_that.updatedAt,_that.status,_that.isCustomizable,_that.isPack);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String baseSku,  String? description,  int? categoryId,  DateTime createdAt,  DateTime updatedAt,  ProductStatus status,  bool isCustomizable,  bool isPack)?  $default,) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.name,_that.baseSku,_that.description,_that.categoryId,_that.createdAt,_that.updatedAt,_that.status,_that.isCustomizable,_that.isPack);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Product implements Product {
  const _Product({required this.id, required this.name, required this.baseSku, this.description, this.categoryId, required this.createdAt, required this.updatedAt, this.status = ProductStatus.draft, this.isCustomizable = false, this.isPack = false});
  factory _Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

@override final  int id;
@override final  String name;
@override final  String baseSku;
@override final  String? description;
@override final  int? categoryId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
// o valor por omissao vive aqui: o JSON pode nao trazer o campo
@override@JsonKey() final  ProductStatus status;
// se nao vier, assume este valor
@override@JsonKey() final  bool isCustomizable;
// se nao vier, assume este valor
@override@JsonKey() final  bool isPack;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductCopyWith<_Product> get copyWith => __$ProductCopyWithImpl<_Product>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Product&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.baseSku, baseSku) || other.baseSku == baseSku)&&(identical(other.description, description) || other.description == description)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.isCustomizable, isCustomizable) || other.isCustomizable == isCustomizable)&&(identical(other.isPack, isPack) || other.isPack == isPack));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,baseSku,description,categoryId,createdAt,updatedAt,status,isCustomizable,isPack);

@override
String toString() {
  return 'Product(id: $id, name: $name, baseSku: $baseSku, description: $description, categoryId: $categoryId, createdAt: $createdAt, updatedAt: $updatedAt, status: $status, isCustomizable: $isCustomizable, isPack: $isPack)';
}


}

/// @nodoc
abstract mixin class _$ProductCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$ProductCopyWith(_Product value, $Res Function(_Product) _then) = __$ProductCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String baseSku, String? description, int? categoryId, DateTime createdAt, DateTime updatedAt, ProductStatus status, bool isCustomizable, bool isPack
});




}
/// @nodoc
class __$ProductCopyWithImpl<$Res>
    implements _$ProductCopyWith<$Res> {
  __$ProductCopyWithImpl(this._self, this._then);

  final _Product _self;
  final $Res Function(_Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? baseSku = null,Object? description = freezed,Object? categoryId = freezed,Object? createdAt = null,Object? updatedAt = null,Object? status = null,Object? isCustomizable = null,Object? isPack = null,}) {
  return _then(_Product(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,baseSku: null == baseSku ? _self.baseSku : baseSku // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProductStatus,isCustomizable: null == isCustomizable ? _self.isCustomizable : isCustomizable // ignore: cast_nullable_to_non_nullable
as bool,isPack: null == isPack ? _self.isPack : isPack // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
