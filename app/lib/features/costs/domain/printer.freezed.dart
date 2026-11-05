// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'printer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Printer {

 int get id; String get name; int get powerW;// consumo médio a imprimir
 double get purchasePrice; int get lifespanHours;// horas até precisar de outra
 double get yearlyMaintenance; int get yearlyHours;// horas de impressão por ano
 bool get isDefault;
/// Create a copy of Printer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrinterCopyWith<Printer> get copyWith => _$PrinterCopyWithImpl<Printer>(this as Printer, _$identity);

  /// Serializes this Printer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Printer&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.powerW, powerW) || other.powerW == powerW)&&(identical(other.purchasePrice, purchasePrice) || other.purchasePrice == purchasePrice)&&(identical(other.lifespanHours, lifespanHours) || other.lifespanHours == lifespanHours)&&(identical(other.yearlyMaintenance, yearlyMaintenance) || other.yearlyMaintenance == yearlyMaintenance)&&(identical(other.yearlyHours, yearlyHours) || other.yearlyHours == yearlyHours)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,powerW,purchasePrice,lifespanHours,yearlyMaintenance,yearlyHours,isDefault);

@override
String toString() {
  return 'Printer(id: $id, name: $name, powerW: $powerW, purchasePrice: $purchasePrice, lifespanHours: $lifespanHours, yearlyMaintenance: $yearlyMaintenance, yearlyHours: $yearlyHours, isDefault: $isDefault)';
}


}

/// @nodoc
abstract mixin class $PrinterCopyWith<$Res>  {
  factory $PrinterCopyWith(Printer value, $Res Function(Printer) _then) = _$PrinterCopyWithImpl;
@useResult
$Res call({
 int id, String name, int powerW, double purchasePrice, int lifespanHours, double yearlyMaintenance, int yearlyHours, bool isDefault
});




}
/// @nodoc
class _$PrinterCopyWithImpl<$Res>
    implements $PrinterCopyWith<$Res> {
  _$PrinterCopyWithImpl(this._self, this._then);

  final Printer _self;
  final $Res Function(Printer) _then;

/// Create a copy of Printer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? powerW = null,Object? purchasePrice = null,Object? lifespanHours = null,Object? yearlyMaintenance = null,Object? yearlyHours = null,Object? isDefault = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,powerW: null == powerW ? _self.powerW : powerW // ignore: cast_nullable_to_non_nullable
as int,purchasePrice: null == purchasePrice ? _self.purchasePrice : purchasePrice // ignore: cast_nullable_to_non_nullable
as double,lifespanHours: null == lifespanHours ? _self.lifespanHours : lifespanHours // ignore: cast_nullable_to_non_nullable
as int,yearlyMaintenance: null == yearlyMaintenance ? _self.yearlyMaintenance : yearlyMaintenance // ignore: cast_nullable_to_non_nullable
as double,yearlyHours: null == yearlyHours ? _self.yearlyHours : yearlyHours // ignore: cast_nullable_to_non_nullable
as int,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Printer].
extension PrinterPatterns on Printer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Printer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Printer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Printer value)  $default,){
final _that = this;
switch (_that) {
case _Printer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Printer value)?  $default,){
final _that = this;
switch (_that) {
case _Printer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  int powerW,  double purchasePrice,  int lifespanHours,  double yearlyMaintenance,  int yearlyHours,  bool isDefault)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Printer() when $default != null:
return $default(_that.id,_that.name,_that.powerW,_that.purchasePrice,_that.lifespanHours,_that.yearlyMaintenance,_that.yearlyHours,_that.isDefault);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  int powerW,  double purchasePrice,  int lifespanHours,  double yearlyMaintenance,  int yearlyHours,  bool isDefault)  $default,) {final _that = this;
switch (_that) {
case _Printer():
return $default(_that.id,_that.name,_that.powerW,_that.purchasePrice,_that.lifespanHours,_that.yearlyMaintenance,_that.yearlyHours,_that.isDefault);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  int powerW,  double purchasePrice,  int lifespanHours,  double yearlyMaintenance,  int yearlyHours,  bool isDefault)?  $default,) {final _that = this;
switch (_that) {
case _Printer() when $default != null:
return $default(_that.id,_that.name,_that.powerW,_that.purchasePrice,_that.lifespanHours,_that.yearlyMaintenance,_that.yearlyHours,_that.isDefault);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Printer implements Printer {
  const _Printer({required this.id, required this.name, required this.powerW, required this.purchasePrice, required this.lifespanHours, this.yearlyMaintenance = 0, this.yearlyHours = 1000, this.isDefault = false});
  factory _Printer.fromJson(Map<String, dynamic> json) => _$PrinterFromJson(json);

@override final  int id;
@override final  String name;
@override final  int powerW;
// consumo médio a imprimir
@override final  double purchasePrice;
@override final  int lifespanHours;
// horas até precisar de outra
@override@JsonKey() final  double yearlyMaintenance;
@override@JsonKey() final  int yearlyHours;
// horas de impressão por ano
@override@JsonKey() final  bool isDefault;

/// Create a copy of Printer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrinterCopyWith<_Printer> get copyWith => __$PrinterCopyWithImpl<_Printer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PrinterToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Printer&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.powerW, powerW) || other.powerW == powerW)&&(identical(other.purchasePrice, purchasePrice) || other.purchasePrice == purchasePrice)&&(identical(other.lifespanHours, lifespanHours) || other.lifespanHours == lifespanHours)&&(identical(other.yearlyMaintenance, yearlyMaintenance) || other.yearlyMaintenance == yearlyMaintenance)&&(identical(other.yearlyHours, yearlyHours) || other.yearlyHours == yearlyHours)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,powerW,purchasePrice,lifespanHours,yearlyMaintenance,yearlyHours,isDefault);

@override
String toString() {
  return 'Printer(id: $id, name: $name, powerW: $powerW, purchasePrice: $purchasePrice, lifespanHours: $lifespanHours, yearlyMaintenance: $yearlyMaintenance, yearlyHours: $yearlyHours, isDefault: $isDefault)';
}


}

/// @nodoc
abstract mixin class _$PrinterCopyWith<$Res> implements $PrinterCopyWith<$Res> {
  factory _$PrinterCopyWith(_Printer value, $Res Function(_Printer) _then) = __$PrinterCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, int powerW, double purchasePrice, int lifespanHours, double yearlyMaintenance, int yearlyHours, bool isDefault
});




}
/// @nodoc
class __$PrinterCopyWithImpl<$Res>
    implements _$PrinterCopyWith<$Res> {
  __$PrinterCopyWithImpl(this._self, this._then);

  final _Printer _self;
  final $Res Function(_Printer) _then;

/// Create a copy of Printer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? powerW = null,Object? purchasePrice = null,Object? lifespanHours = null,Object? yearlyMaintenance = null,Object? yearlyHours = null,Object? isDefault = null,}) {
  return _then(_Printer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,powerW: null == powerW ? _self.powerW : powerW // ignore: cast_nullable_to_non_nullable
as int,purchasePrice: null == purchasePrice ? _self.purchasePrice : purchasePrice // ignore: cast_nullable_to_non_nullable
as double,lifespanHours: null == lifespanHours ? _self.lifespanHours : lifespanHours // ignore: cast_nullable_to_non_nullable
as int,yearlyMaintenance: null == yearlyMaintenance ? _self.yearlyMaintenance : yearlyMaintenance // ignore: cast_nullable_to_non_nullable
as double,yearlyHours: null == yearlyHours ? _self.yearlyHours : yearlyHours // ignore: cast_nullable_to_non_nullable
as int,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
