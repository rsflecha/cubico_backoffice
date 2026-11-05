// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cost_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CostSettings {

 double get kwhPrice;// € por kWh, com IVA
 double get targetMarginPct;// margem alvo para o preço sugerido
 double get minMarginPct;// abaixo disto, a app avisa
 double get rounding;// preços sugeridos arredondados a isto
 double get hourlyRate;// valor da tua hora (0 = não conta)
 bool get includeFixedCosts;
/// Create a copy of CostSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CostSettingsCopyWith<CostSettings> get copyWith => _$CostSettingsCopyWithImpl<CostSettings>(this as CostSettings, _$identity);

  /// Serializes this CostSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CostSettings&&(identical(other.kwhPrice, kwhPrice) || other.kwhPrice == kwhPrice)&&(identical(other.targetMarginPct, targetMarginPct) || other.targetMarginPct == targetMarginPct)&&(identical(other.minMarginPct, minMarginPct) || other.minMarginPct == minMarginPct)&&(identical(other.rounding, rounding) || other.rounding == rounding)&&(identical(other.hourlyRate, hourlyRate) || other.hourlyRate == hourlyRate)&&(identical(other.includeFixedCosts, includeFixedCosts) || other.includeFixedCosts == includeFixedCosts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kwhPrice,targetMarginPct,minMarginPct,rounding,hourlyRate,includeFixedCosts);

@override
String toString() {
  return 'CostSettings(kwhPrice: $kwhPrice, targetMarginPct: $targetMarginPct, minMarginPct: $minMarginPct, rounding: $rounding, hourlyRate: $hourlyRate, includeFixedCosts: $includeFixedCosts)';
}


}

/// @nodoc
abstract mixin class $CostSettingsCopyWith<$Res>  {
  factory $CostSettingsCopyWith(CostSettings value, $Res Function(CostSettings) _then) = _$CostSettingsCopyWithImpl;
@useResult
$Res call({
 double kwhPrice, double targetMarginPct, double minMarginPct, double rounding, double hourlyRate, bool includeFixedCosts
});




}
/// @nodoc
class _$CostSettingsCopyWithImpl<$Res>
    implements $CostSettingsCopyWith<$Res> {
  _$CostSettingsCopyWithImpl(this._self, this._then);

  final CostSettings _self;
  final $Res Function(CostSettings) _then;

/// Create a copy of CostSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kwhPrice = null,Object? targetMarginPct = null,Object? minMarginPct = null,Object? rounding = null,Object? hourlyRate = null,Object? includeFixedCosts = null,}) {
  return _then(_self.copyWith(
kwhPrice: null == kwhPrice ? _self.kwhPrice : kwhPrice // ignore: cast_nullable_to_non_nullable
as double,targetMarginPct: null == targetMarginPct ? _self.targetMarginPct : targetMarginPct // ignore: cast_nullable_to_non_nullable
as double,minMarginPct: null == minMarginPct ? _self.minMarginPct : minMarginPct // ignore: cast_nullable_to_non_nullable
as double,rounding: null == rounding ? _self.rounding : rounding // ignore: cast_nullable_to_non_nullable
as double,hourlyRate: null == hourlyRate ? _self.hourlyRate : hourlyRate // ignore: cast_nullable_to_non_nullable
as double,includeFixedCosts: null == includeFixedCosts ? _self.includeFixedCosts : includeFixedCosts // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CostSettings].
extension CostSettingsPatterns on CostSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CostSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CostSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CostSettings value)  $default,){
final _that = this;
switch (_that) {
case _CostSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CostSettings value)?  $default,){
final _that = this;
switch (_that) {
case _CostSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double kwhPrice,  double targetMarginPct,  double minMarginPct,  double rounding,  double hourlyRate,  bool includeFixedCosts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CostSettings() when $default != null:
return $default(_that.kwhPrice,_that.targetMarginPct,_that.minMarginPct,_that.rounding,_that.hourlyRate,_that.includeFixedCosts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double kwhPrice,  double targetMarginPct,  double minMarginPct,  double rounding,  double hourlyRate,  bool includeFixedCosts)  $default,) {final _that = this;
switch (_that) {
case _CostSettings():
return $default(_that.kwhPrice,_that.targetMarginPct,_that.minMarginPct,_that.rounding,_that.hourlyRate,_that.includeFixedCosts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double kwhPrice,  double targetMarginPct,  double minMarginPct,  double rounding,  double hourlyRate,  bool includeFixedCosts)?  $default,) {final _that = this;
switch (_that) {
case _CostSettings() when $default != null:
return $default(_that.kwhPrice,_that.targetMarginPct,_that.minMarginPct,_that.rounding,_that.hourlyRate,_that.includeFixedCosts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CostSettings implements CostSettings {
  const _CostSettings({required this.kwhPrice, this.targetMarginPct = 60, this.minMarginPct = 35, this.rounding = 0.50, this.hourlyRate = 0, this.includeFixedCosts = false});
  factory _CostSettings.fromJson(Map<String, dynamic> json) => _$CostSettingsFromJson(json);

@override final  double kwhPrice;
// € por kWh, com IVA
@override@JsonKey() final  double targetMarginPct;
// margem alvo para o preço sugerido
@override@JsonKey() final  double minMarginPct;
// abaixo disto, a app avisa
@override@JsonKey() final  double rounding;
// preços sugeridos arredondados a isto
@override@JsonKey() final  double hourlyRate;
// valor da tua hora (0 = não conta)
@override@JsonKey() final  bool includeFixedCosts;

/// Create a copy of CostSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CostSettingsCopyWith<_CostSettings> get copyWith => __$CostSettingsCopyWithImpl<_CostSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CostSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CostSettings&&(identical(other.kwhPrice, kwhPrice) || other.kwhPrice == kwhPrice)&&(identical(other.targetMarginPct, targetMarginPct) || other.targetMarginPct == targetMarginPct)&&(identical(other.minMarginPct, minMarginPct) || other.minMarginPct == minMarginPct)&&(identical(other.rounding, rounding) || other.rounding == rounding)&&(identical(other.hourlyRate, hourlyRate) || other.hourlyRate == hourlyRate)&&(identical(other.includeFixedCosts, includeFixedCosts) || other.includeFixedCosts == includeFixedCosts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kwhPrice,targetMarginPct,minMarginPct,rounding,hourlyRate,includeFixedCosts);

@override
String toString() {
  return 'CostSettings(kwhPrice: $kwhPrice, targetMarginPct: $targetMarginPct, minMarginPct: $minMarginPct, rounding: $rounding, hourlyRate: $hourlyRate, includeFixedCosts: $includeFixedCosts)';
}


}

/// @nodoc
abstract mixin class _$CostSettingsCopyWith<$Res> implements $CostSettingsCopyWith<$Res> {
  factory _$CostSettingsCopyWith(_CostSettings value, $Res Function(_CostSettings) _then) = __$CostSettingsCopyWithImpl;
@override @useResult
$Res call({
 double kwhPrice, double targetMarginPct, double minMarginPct, double rounding, double hourlyRate, bool includeFixedCosts
});




}
/// @nodoc
class __$CostSettingsCopyWithImpl<$Res>
    implements _$CostSettingsCopyWith<$Res> {
  __$CostSettingsCopyWithImpl(this._self, this._then);

  final _CostSettings _self;
  final $Res Function(_CostSettings) _then;

/// Create a copy of CostSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kwhPrice = null,Object? targetMarginPct = null,Object? minMarginPct = null,Object? rounding = null,Object? hourlyRate = null,Object? includeFixedCosts = null,}) {
  return _then(_CostSettings(
kwhPrice: null == kwhPrice ? _self.kwhPrice : kwhPrice // ignore: cast_nullable_to_non_nullable
as double,targetMarginPct: null == targetMarginPct ? _self.targetMarginPct : targetMarginPct // ignore: cast_nullable_to_non_nullable
as double,minMarginPct: null == minMarginPct ? _self.minMarginPct : minMarginPct // ignore: cast_nullable_to_non_nullable
as double,rounding: null == rounding ? _self.rounding : rounding // ignore: cast_nullable_to_non_nullable
as double,hourlyRate: null == hourlyRate ? _self.hourlyRate : hourlyRate // ignore: cast_nullable_to_non_nullable
as double,includeFixedCosts: null == includeFixedCosts ? _self.includeFixedCosts : includeFixedCosts // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
