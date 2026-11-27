// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'filament_stock.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FilamentStock {

 int get filamentId; double get stockG; double get spools; int get minStockG;
/// Create a copy of FilamentStock
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FilamentStockCopyWith<FilamentStock> get copyWith => _$FilamentStockCopyWithImpl<FilamentStock>(this as FilamentStock, _$identity);

  /// Serializes this FilamentStock to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FilamentStock&&(identical(other.filamentId, filamentId) || other.filamentId == filamentId)&&(identical(other.stockG, stockG) || other.stockG == stockG)&&(identical(other.spools, spools) || other.spools == spools)&&(identical(other.minStockG, minStockG) || other.minStockG == minStockG));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,filamentId,stockG,spools,minStockG);

@override
String toString() {
  return 'FilamentStock(filamentId: $filamentId, stockG: $stockG, spools: $spools, minStockG: $minStockG)';
}


}

/// @nodoc
abstract mixin class $FilamentStockCopyWith<$Res>  {
  factory $FilamentStockCopyWith(FilamentStock value, $Res Function(FilamentStock) _then) = _$FilamentStockCopyWithImpl;
@useResult
$Res call({
 int filamentId, double stockG, double spools, int minStockG
});




}
/// @nodoc
class _$FilamentStockCopyWithImpl<$Res>
    implements $FilamentStockCopyWith<$Res> {
  _$FilamentStockCopyWithImpl(this._self, this._then);

  final FilamentStock _self;
  final $Res Function(FilamentStock) _then;

/// Create a copy of FilamentStock
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? filamentId = null,Object? stockG = null,Object? spools = null,Object? minStockG = null,}) {
  return _then(_self.copyWith(
filamentId: null == filamentId ? _self.filamentId : filamentId // ignore: cast_nullable_to_non_nullable
as int,stockG: null == stockG ? _self.stockG : stockG // ignore: cast_nullable_to_non_nullable
as double,spools: null == spools ? _self.spools : spools // ignore: cast_nullable_to_non_nullable
as double,minStockG: null == minStockG ? _self.minStockG : minStockG // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [FilamentStock].
extension FilamentStockPatterns on FilamentStock {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FilamentStock value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FilamentStock() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FilamentStock value)  $default,){
final _that = this;
switch (_that) {
case _FilamentStock():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FilamentStock value)?  $default,){
final _that = this;
switch (_that) {
case _FilamentStock() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int filamentId,  double stockG,  double spools,  int minStockG)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FilamentStock() when $default != null:
return $default(_that.filamentId,_that.stockG,_that.spools,_that.minStockG);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int filamentId,  double stockG,  double spools,  int minStockG)  $default,) {final _that = this;
switch (_that) {
case _FilamentStock():
return $default(_that.filamentId,_that.stockG,_that.spools,_that.minStockG);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int filamentId,  double stockG,  double spools,  int minStockG)?  $default,) {final _that = this;
switch (_that) {
case _FilamentStock() when $default != null:
return $default(_that.filamentId,_that.stockG,_that.spools,_that.minStockG);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FilamentStock implements FilamentStock {
  const _FilamentStock({required this.filamentId, required this.stockG, required this.spools, required this.minStockG});
  factory _FilamentStock.fromJson(Map<String, dynamic> json) => _$FilamentStockFromJson(json);

@override final  int filamentId;
@override final  double stockG;
@override final  double spools;
@override final  int minStockG;

/// Create a copy of FilamentStock
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilamentStockCopyWith<_FilamentStock> get copyWith => __$FilamentStockCopyWithImpl<_FilamentStock>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FilamentStockToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilamentStock&&(identical(other.filamentId, filamentId) || other.filamentId == filamentId)&&(identical(other.stockG, stockG) || other.stockG == stockG)&&(identical(other.spools, spools) || other.spools == spools)&&(identical(other.minStockG, minStockG) || other.minStockG == minStockG));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,filamentId,stockG,spools,minStockG);

@override
String toString() {
  return 'FilamentStock(filamentId: $filamentId, stockG: $stockG, spools: $spools, minStockG: $minStockG)';
}


}

/// @nodoc
abstract mixin class _$FilamentStockCopyWith<$Res> implements $FilamentStockCopyWith<$Res> {
  factory _$FilamentStockCopyWith(_FilamentStock value, $Res Function(_FilamentStock) _then) = __$FilamentStockCopyWithImpl;
@override @useResult
$Res call({
 int filamentId, double stockG, double spools, int minStockG
});




}
/// @nodoc
class __$FilamentStockCopyWithImpl<$Res>
    implements _$FilamentStockCopyWith<$Res> {
  __$FilamentStockCopyWithImpl(this._self, this._then);

  final _FilamentStock _self;
  final $Res Function(_FilamentStock) _then;

/// Create a copy of FilamentStock
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? filamentId = null,Object? stockG = null,Object? spools = null,Object? minStockG = null,}) {
  return _then(_FilamentStock(
filamentId: null == filamentId ? _self.filamentId : filamentId // ignore: cast_nullable_to_non_nullable
as int,stockG: null == stockG ? _self.stockG : stockG // ignore: cast_nullable_to_non_nullable
as double,spools: null == spools ? _self.spools : spools // ignore: cast_nullable_to_non_nullable
as double,minStockG: null == minStockG ? _self.minStockG : minStockG // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
