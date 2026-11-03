// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'component.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Component {

 int get id; String get name; ComponentKind get kind; String? get sizeLabel;// "25 mm", "S", "A5"…
 int get weightG;// peso de uma unidade, conta para os portes
 double get packPrice;// quanto custa o pack
 int get unitsPerPack;// quantas unidades traz o pack
 int get stockQty; int get minStockQty;
/// Create a copy of Component
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComponentCopyWith<Component> get copyWith => _$ComponentCopyWithImpl<Component>(this as Component, _$identity);

  /// Serializes this Component to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Component&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.sizeLabel, sizeLabel) || other.sizeLabel == sizeLabel)&&(identical(other.weightG, weightG) || other.weightG == weightG)&&(identical(other.packPrice, packPrice) || other.packPrice == packPrice)&&(identical(other.unitsPerPack, unitsPerPack) || other.unitsPerPack == unitsPerPack)&&(identical(other.stockQty, stockQty) || other.stockQty == stockQty)&&(identical(other.minStockQty, minStockQty) || other.minStockQty == minStockQty));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,kind,sizeLabel,weightG,packPrice,unitsPerPack,stockQty,minStockQty);

@override
String toString() {
  return 'Component(id: $id, name: $name, kind: $kind, sizeLabel: $sizeLabel, weightG: $weightG, packPrice: $packPrice, unitsPerPack: $unitsPerPack, stockQty: $stockQty, minStockQty: $minStockQty)';
}


}

/// @nodoc
abstract mixin class $ComponentCopyWith<$Res>  {
  factory $ComponentCopyWith(Component value, $Res Function(Component) _then) = _$ComponentCopyWithImpl;
@useResult
$Res call({
 int id, String name, ComponentKind kind, String? sizeLabel, int weightG, double packPrice, int unitsPerPack, int stockQty, int minStockQty
});




}
/// @nodoc
class _$ComponentCopyWithImpl<$Res>
    implements $ComponentCopyWith<$Res> {
  _$ComponentCopyWithImpl(this._self, this._then);

  final Component _self;
  final $Res Function(Component) _then;

/// Create a copy of Component
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? kind = null,Object? sizeLabel = freezed,Object? weightG = null,Object? packPrice = null,Object? unitsPerPack = null,Object? stockQty = null,Object? minStockQty = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ComponentKind,sizeLabel: freezed == sizeLabel ? _self.sizeLabel : sizeLabel // ignore: cast_nullable_to_non_nullable
as String?,weightG: null == weightG ? _self.weightG : weightG // ignore: cast_nullable_to_non_nullable
as int,packPrice: null == packPrice ? _self.packPrice : packPrice // ignore: cast_nullable_to_non_nullable
as double,unitsPerPack: null == unitsPerPack ? _self.unitsPerPack : unitsPerPack // ignore: cast_nullable_to_non_nullable
as int,stockQty: null == stockQty ? _self.stockQty : stockQty // ignore: cast_nullable_to_non_nullable
as int,minStockQty: null == minStockQty ? _self.minStockQty : minStockQty // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Component].
extension ComponentPatterns on Component {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Component value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Component() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Component value)  $default,){
final _that = this;
switch (_that) {
case _Component():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Component value)?  $default,){
final _that = this;
switch (_that) {
case _Component() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  ComponentKind kind,  String? sizeLabel,  int weightG,  double packPrice,  int unitsPerPack,  int stockQty,  int minStockQty)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Component() when $default != null:
return $default(_that.id,_that.name,_that.kind,_that.sizeLabel,_that.weightG,_that.packPrice,_that.unitsPerPack,_that.stockQty,_that.minStockQty);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  ComponentKind kind,  String? sizeLabel,  int weightG,  double packPrice,  int unitsPerPack,  int stockQty,  int minStockQty)  $default,) {final _that = this;
switch (_that) {
case _Component():
return $default(_that.id,_that.name,_that.kind,_that.sizeLabel,_that.weightG,_that.packPrice,_that.unitsPerPack,_that.stockQty,_that.minStockQty);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  ComponentKind kind,  String? sizeLabel,  int weightG,  double packPrice,  int unitsPerPack,  int stockQty,  int minStockQty)?  $default,) {final _that = this;
switch (_that) {
case _Component() when $default != null:
return $default(_that.id,_that.name,_that.kind,_that.sizeLabel,_that.weightG,_that.packPrice,_that.unitsPerPack,_that.stockQty,_that.minStockQty);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Component implements Component {
  const _Component({required this.id, required this.name, required this.kind, this.sizeLabel, this.weightG = 0, required this.packPrice, this.unitsPerPack = 1, this.stockQty = 0, this.minStockQty = 0});
  factory _Component.fromJson(Map<String, dynamic> json) => _$ComponentFromJson(json);

@override final  int id;
@override final  String name;
@override final  ComponentKind kind;
@override final  String? sizeLabel;
// "25 mm", "S", "A5"…
@override@JsonKey() final  int weightG;
// peso de uma unidade, conta para os portes
@override final  double packPrice;
// quanto custa o pack
@override@JsonKey() final  int unitsPerPack;
// quantas unidades traz o pack
@override@JsonKey() final  int stockQty;
@override@JsonKey() final  int minStockQty;

/// Create a copy of Component
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComponentCopyWith<_Component> get copyWith => __$ComponentCopyWithImpl<_Component>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ComponentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Component&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.sizeLabel, sizeLabel) || other.sizeLabel == sizeLabel)&&(identical(other.weightG, weightG) || other.weightG == weightG)&&(identical(other.packPrice, packPrice) || other.packPrice == packPrice)&&(identical(other.unitsPerPack, unitsPerPack) || other.unitsPerPack == unitsPerPack)&&(identical(other.stockQty, stockQty) || other.stockQty == stockQty)&&(identical(other.minStockQty, minStockQty) || other.minStockQty == minStockQty));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,kind,sizeLabel,weightG,packPrice,unitsPerPack,stockQty,minStockQty);

@override
String toString() {
  return 'Component(id: $id, name: $name, kind: $kind, sizeLabel: $sizeLabel, weightG: $weightG, packPrice: $packPrice, unitsPerPack: $unitsPerPack, stockQty: $stockQty, minStockQty: $minStockQty)';
}


}

/// @nodoc
abstract mixin class _$ComponentCopyWith<$Res> implements $ComponentCopyWith<$Res> {
  factory _$ComponentCopyWith(_Component value, $Res Function(_Component) _then) = __$ComponentCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, ComponentKind kind, String? sizeLabel, int weightG, double packPrice, int unitsPerPack, int stockQty, int minStockQty
});




}
/// @nodoc
class __$ComponentCopyWithImpl<$Res>
    implements _$ComponentCopyWith<$Res> {
  __$ComponentCopyWithImpl(this._self, this._then);

  final _Component _self;
  final $Res Function(_Component) _then;

/// Create a copy of Component
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? kind = null,Object? sizeLabel = freezed,Object? weightG = null,Object? packPrice = null,Object? unitsPerPack = null,Object? stockQty = null,Object? minStockQty = null,}) {
  return _then(_Component(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ComponentKind,sizeLabel: freezed == sizeLabel ? _self.sizeLabel : sizeLabel // ignore: cast_nullable_to_non_nullable
as String?,weightG: null == weightG ? _self.weightG : weightG // ignore: cast_nullable_to_non_nullable
as int,packPrice: null == packPrice ? _self.packPrice : packPrice // ignore: cast_nullable_to_non_nullable
as double,unitsPerPack: null == unitsPerPack ? _self.unitsPerPack : unitsPerPack // ignore: cast_nullable_to_non_nullable
as int,stockQty: null == stockQty ? _self.stockQty : stockQty // ignore: cast_nullable_to_non_nullable
as int,minStockQty: null == minStockQty ? _self.minStockQty : minStockQty // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
