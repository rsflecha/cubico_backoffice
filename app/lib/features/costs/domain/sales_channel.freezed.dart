// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sales_channel.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SalesChannel {

 int get id; String get code;// "etsy", "instagram"...
 String get name;// o que aparece no ecrã
 double get transactionFee;// em %
 double get processingFee;// em %
 double get flatFee;// em € por venda
 double get listingFee;// em € por venda
 bool get isAutomatic;
/// Create a copy of SalesChannel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SalesChannelCopyWith<SalesChannel> get copyWith => _$SalesChannelCopyWithImpl<SalesChannel>(this as SalesChannel, _$identity);

  /// Serializes this SalesChannel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SalesChannel&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.transactionFee, transactionFee) || other.transactionFee == transactionFee)&&(identical(other.processingFee, processingFee) || other.processingFee == processingFee)&&(identical(other.flatFee, flatFee) || other.flatFee == flatFee)&&(identical(other.listingFee, listingFee) || other.listingFee == listingFee)&&(identical(other.isAutomatic, isAutomatic) || other.isAutomatic == isAutomatic));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code,name,transactionFee,processingFee,flatFee,listingFee,isAutomatic);

@override
String toString() {
  return 'SalesChannel(id: $id, code: $code, name: $name, transactionFee: $transactionFee, processingFee: $processingFee, flatFee: $flatFee, listingFee: $listingFee, isAutomatic: $isAutomatic)';
}


}

/// @nodoc
abstract mixin class $SalesChannelCopyWith<$Res>  {
  factory $SalesChannelCopyWith(SalesChannel value, $Res Function(SalesChannel) _then) = _$SalesChannelCopyWithImpl;
@useResult
$Res call({
 int id, String code, String name, double transactionFee, double processingFee, double flatFee, double listingFee, bool isAutomatic
});




}
/// @nodoc
class _$SalesChannelCopyWithImpl<$Res>
    implements $SalesChannelCopyWith<$Res> {
  _$SalesChannelCopyWithImpl(this._self, this._then);

  final SalesChannel _self;
  final $Res Function(SalesChannel) _then;

/// Create a copy of SalesChannel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? name = null,Object? transactionFee = null,Object? processingFee = null,Object? flatFee = null,Object? listingFee = null,Object? isAutomatic = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,transactionFee: null == transactionFee ? _self.transactionFee : transactionFee // ignore: cast_nullable_to_non_nullable
as double,processingFee: null == processingFee ? _self.processingFee : processingFee // ignore: cast_nullable_to_non_nullable
as double,flatFee: null == flatFee ? _self.flatFee : flatFee // ignore: cast_nullable_to_non_nullable
as double,listingFee: null == listingFee ? _self.listingFee : listingFee // ignore: cast_nullable_to_non_nullable
as double,isAutomatic: null == isAutomatic ? _self.isAutomatic : isAutomatic // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SalesChannel].
extension SalesChannelPatterns on SalesChannel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SalesChannel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SalesChannel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SalesChannel value)  $default,){
final _that = this;
switch (_that) {
case _SalesChannel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SalesChannel value)?  $default,){
final _that = this;
switch (_that) {
case _SalesChannel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String code,  String name,  double transactionFee,  double processingFee,  double flatFee,  double listingFee,  bool isAutomatic)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SalesChannel() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.transactionFee,_that.processingFee,_that.flatFee,_that.listingFee,_that.isAutomatic);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String code,  String name,  double transactionFee,  double processingFee,  double flatFee,  double listingFee,  bool isAutomatic)  $default,) {final _that = this;
switch (_that) {
case _SalesChannel():
return $default(_that.id,_that.code,_that.name,_that.transactionFee,_that.processingFee,_that.flatFee,_that.listingFee,_that.isAutomatic);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String code,  String name,  double transactionFee,  double processingFee,  double flatFee,  double listingFee,  bool isAutomatic)?  $default,) {final _that = this;
switch (_that) {
case _SalesChannel() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.transactionFee,_that.processingFee,_that.flatFee,_that.listingFee,_that.isAutomatic);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SalesChannel implements SalesChannel {
  const _SalesChannel({required this.id, required this.code, required this.name, this.transactionFee = 0, this.processingFee = 0, this.flatFee = 0, this.listingFee = 0, this.isAutomatic = false});
  factory _SalesChannel.fromJson(Map<String, dynamic> json) => _$SalesChannelFromJson(json);

@override final  int id;
@override final  String code;
// "etsy", "instagram"...
@override final  String name;
// o que aparece no ecrã
@override@JsonKey() final  double transactionFee;
// em %
@override@JsonKey() final  double processingFee;
// em %
@override@JsonKey() final  double flatFee;
// em € por venda
@override@JsonKey() final  double listingFee;
// em € por venda
@override@JsonKey() final  bool isAutomatic;

/// Create a copy of SalesChannel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SalesChannelCopyWith<_SalesChannel> get copyWith => __$SalesChannelCopyWithImpl<_SalesChannel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SalesChannelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SalesChannel&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.transactionFee, transactionFee) || other.transactionFee == transactionFee)&&(identical(other.processingFee, processingFee) || other.processingFee == processingFee)&&(identical(other.flatFee, flatFee) || other.flatFee == flatFee)&&(identical(other.listingFee, listingFee) || other.listingFee == listingFee)&&(identical(other.isAutomatic, isAutomatic) || other.isAutomatic == isAutomatic));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code,name,transactionFee,processingFee,flatFee,listingFee,isAutomatic);

@override
String toString() {
  return 'SalesChannel(id: $id, code: $code, name: $name, transactionFee: $transactionFee, processingFee: $processingFee, flatFee: $flatFee, listingFee: $listingFee, isAutomatic: $isAutomatic)';
}


}

/// @nodoc
abstract mixin class _$SalesChannelCopyWith<$Res> implements $SalesChannelCopyWith<$Res> {
  factory _$SalesChannelCopyWith(_SalesChannel value, $Res Function(_SalesChannel) _then) = __$SalesChannelCopyWithImpl;
@override @useResult
$Res call({
 int id, String code, String name, double transactionFee, double processingFee, double flatFee, double listingFee, bool isAutomatic
});




}
/// @nodoc
class __$SalesChannelCopyWithImpl<$Res>
    implements _$SalesChannelCopyWith<$Res> {
  __$SalesChannelCopyWithImpl(this._self, this._then);

  final _SalesChannel _self;
  final $Res Function(_SalesChannel) _then;

/// Create a copy of SalesChannel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? name = null,Object? transactionFee = null,Object? processingFee = null,Object? flatFee = null,Object? listingFee = null,Object? isAutomatic = null,}) {
  return _then(_SalesChannel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,transactionFee: null == transactionFee ? _self.transactionFee : transactionFee // ignore: cast_nullable_to_non_nullable
as double,processingFee: null == processingFee ? _self.processingFee : processingFee // ignore: cast_nullable_to_non_nullable
as double,flatFee: null == flatFee ? _self.flatFee : flatFee // ignore: cast_nullable_to_non_nullable
as double,listingFee: null == listingFee ? _self.listingFee : listingFee // ignore: cast_nullable_to_non_nullable
as double,isAutomatic: null == isAutomatic ? _self.isAutomatic : isAutomatic // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
