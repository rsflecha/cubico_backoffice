// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'filament_movement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FilamentMovement {

 int get id;@JsonKey(name: "movement_type") MovementType get type; double get grams; int? get spools;// só vêm para quem pode ver custos: podem faltar no JSON
 double? get paidPrice; double? get shippingCost; String? get note; String? get userName; int? get printJobId; DateTime get createdAt;
/// Create a copy of FilamentMovement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FilamentMovementCopyWith<FilamentMovement> get copyWith => _$FilamentMovementCopyWithImpl<FilamentMovement>(this as FilamentMovement, _$identity);

  /// Serializes this FilamentMovement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FilamentMovement&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.grams, grams) || other.grams == grams)&&(identical(other.spools, spools) || other.spools == spools)&&(identical(other.paidPrice, paidPrice) || other.paidPrice == paidPrice)&&(identical(other.shippingCost, shippingCost) || other.shippingCost == shippingCost)&&(identical(other.note, note) || other.note == note)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.printJobId, printJobId) || other.printJobId == printJobId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,grams,spools,paidPrice,shippingCost,note,userName,printJobId,createdAt);

@override
String toString() {
  return 'FilamentMovement(id: $id, type: $type, grams: $grams, spools: $spools, paidPrice: $paidPrice, shippingCost: $shippingCost, note: $note, userName: $userName, printJobId: $printJobId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $FilamentMovementCopyWith<$Res>  {
  factory $FilamentMovementCopyWith(FilamentMovement value, $Res Function(FilamentMovement) _then) = _$FilamentMovementCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: "movement_type") MovementType type, double grams, int? spools, double? paidPrice, double? shippingCost, String? note, String? userName, int? printJobId, DateTime createdAt
});




}
/// @nodoc
class _$FilamentMovementCopyWithImpl<$Res>
    implements $FilamentMovementCopyWith<$Res> {
  _$FilamentMovementCopyWithImpl(this._self, this._then);

  final FilamentMovement _self;
  final $Res Function(FilamentMovement) _then;

/// Create a copy of FilamentMovement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? grams = null,Object? spools = freezed,Object? paidPrice = freezed,Object? shippingCost = freezed,Object? note = freezed,Object? userName = freezed,Object? printJobId = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MovementType,grams: null == grams ? _self.grams : grams // ignore: cast_nullable_to_non_nullable
as double,spools: freezed == spools ? _self.spools : spools // ignore: cast_nullable_to_non_nullable
as int?,paidPrice: freezed == paidPrice ? _self.paidPrice : paidPrice // ignore: cast_nullable_to_non_nullable
as double?,shippingCost: freezed == shippingCost ? _self.shippingCost : shippingCost // ignore: cast_nullable_to_non_nullable
as double?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,printJobId: freezed == printJobId ? _self.printJobId : printJobId // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FilamentMovement].
extension FilamentMovementPatterns on FilamentMovement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FilamentMovement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FilamentMovement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FilamentMovement value)  $default,){
final _that = this;
switch (_that) {
case _FilamentMovement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FilamentMovement value)?  $default,){
final _that = this;
switch (_that) {
case _FilamentMovement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: "movement_type")  MovementType type,  double grams,  int? spools,  double? paidPrice,  double? shippingCost,  String? note,  String? userName,  int? printJobId,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FilamentMovement() when $default != null:
return $default(_that.id,_that.type,_that.grams,_that.spools,_that.paidPrice,_that.shippingCost,_that.note,_that.userName,_that.printJobId,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: "movement_type")  MovementType type,  double grams,  int? spools,  double? paidPrice,  double? shippingCost,  String? note,  String? userName,  int? printJobId,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _FilamentMovement():
return $default(_that.id,_that.type,_that.grams,_that.spools,_that.paidPrice,_that.shippingCost,_that.note,_that.userName,_that.printJobId,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: "movement_type")  MovementType type,  double grams,  int? spools,  double? paidPrice,  double? shippingCost,  String? note,  String? userName,  int? printJobId,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _FilamentMovement() when $default != null:
return $default(_that.id,_that.type,_that.grams,_that.spools,_that.paidPrice,_that.shippingCost,_that.note,_that.userName,_that.printJobId,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FilamentMovement implements FilamentMovement {
  const _FilamentMovement({required this.id, @JsonKey(name: "movement_type") required this.type, required this.grams, this.spools, this.paidPrice, this.shippingCost, this.note, this.userName, this.printJobId, required this.createdAt});
  factory _FilamentMovement.fromJson(Map<String, dynamic> json) => _$FilamentMovementFromJson(json);

@override final  int id;
@override@JsonKey(name: "movement_type") final  MovementType type;
@override final  double grams;
@override final  int? spools;
// só vêm para quem pode ver custos: podem faltar no JSON
@override final  double? paidPrice;
@override final  double? shippingCost;
@override final  String? note;
@override final  String? userName;
@override final  int? printJobId;
@override final  DateTime createdAt;

/// Create a copy of FilamentMovement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilamentMovementCopyWith<_FilamentMovement> get copyWith => __$FilamentMovementCopyWithImpl<_FilamentMovement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FilamentMovementToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilamentMovement&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.grams, grams) || other.grams == grams)&&(identical(other.spools, spools) || other.spools == spools)&&(identical(other.paidPrice, paidPrice) || other.paidPrice == paidPrice)&&(identical(other.shippingCost, shippingCost) || other.shippingCost == shippingCost)&&(identical(other.note, note) || other.note == note)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.printJobId, printJobId) || other.printJobId == printJobId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,grams,spools,paidPrice,shippingCost,note,userName,printJobId,createdAt);

@override
String toString() {
  return 'FilamentMovement(id: $id, type: $type, grams: $grams, spools: $spools, paidPrice: $paidPrice, shippingCost: $shippingCost, note: $note, userName: $userName, printJobId: $printJobId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$FilamentMovementCopyWith<$Res> implements $FilamentMovementCopyWith<$Res> {
  factory _$FilamentMovementCopyWith(_FilamentMovement value, $Res Function(_FilamentMovement) _then) = __$FilamentMovementCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: "movement_type") MovementType type, double grams, int? spools, double? paidPrice, double? shippingCost, String? note, String? userName, int? printJobId, DateTime createdAt
});




}
/// @nodoc
class __$FilamentMovementCopyWithImpl<$Res>
    implements _$FilamentMovementCopyWith<$Res> {
  __$FilamentMovementCopyWithImpl(this._self, this._then);

  final _FilamentMovement _self;
  final $Res Function(_FilamentMovement) _then;

/// Create a copy of FilamentMovement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? grams = null,Object? spools = freezed,Object? paidPrice = freezed,Object? shippingCost = freezed,Object? note = freezed,Object? userName = freezed,Object? printJobId = freezed,Object? createdAt = null,}) {
  return _then(_FilamentMovement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MovementType,grams: null == grams ? _self.grams : grams // ignore: cast_nullable_to_non_nullable
as double,spools: freezed == spools ? _self.spools : spools // ignore: cast_nullable_to_non_nullable
as int?,paidPrice: freezed == paidPrice ? _self.paidPrice : paidPrice // ignore: cast_nullable_to_non_nullable
as double?,shippingCost: freezed == shippingCost ? _self.shippingCost : shippingCost // ignore: cast_nullable_to_non_nullable
as double?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,printJobId: freezed == printJobId ? _self.printJobId : printJobId // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
