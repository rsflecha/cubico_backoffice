// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'print_job.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PrintJob {

 int get id; int? get orderLineId;// null = tarefa manual (stock, protótipo)
 int? get orderId;// a encomenda (vem da API, juntando à linha)
 int? get orderNumber;// o número que se vê: #1041
 int get variantId; int get quantity; PrintJobStatus get status; int get estimatedMin;// tempo de impressão estimado, em minutos
 DateTime? get startedAt; DateTime? get finishedAt; String? get notes;
/// Create a copy of PrintJob
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrintJobCopyWith<PrintJob> get copyWith => _$PrintJobCopyWithImpl<PrintJob>(this as PrintJob, _$identity);

  /// Serializes this PrintJob to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrintJob&&(identical(other.id, id) || other.id == id)&&(identical(other.orderLineId, orderLineId) || other.orderLineId == orderLineId)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.variantId, variantId) || other.variantId == variantId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.status, status) || other.status == status)&&(identical(other.estimatedMin, estimatedMin) || other.estimatedMin == estimatedMin)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.finishedAt, finishedAt) || other.finishedAt == finishedAt)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderLineId,orderId,orderNumber,variantId,quantity,status,estimatedMin,startedAt,finishedAt,notes);

@override
String toString() {
  return 'PrintJob(id: $id, orderLineId: $orderLineId, orderId: $orderId, orderNumber: $orderNumber, variantId: $variantId, quantity: $quantity, status: $status, estimatedMin: $estimatedMin, startedAt: $startedAt, finishedAt: $finishedAt, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $PrintJobCopyWith<$Res>  {
  factory $PrintJobCopyWith(PrintJob value, $Res Function(PrintJob) _then) = _$PrintJobCopyWithImpl;
@useResult
$Res call({
 int id, int? orderLineId, int? orderId, int? orderNumber, int variantId, int quantity, PrintJobStatus status, int estimatedMin, DateTime? startedAt, DateTime? finishedAt, String? notes
});




}
/// @nodoc
class _$PrintJobCopyWithImpl<$Res>
    implements $PrintJobCopyWith<$Res> {
  _$PrintJobCopyWithImpl(this._self, this._then);

  final PrintJob _self;
  final $Res Function(PrintJob) _then;

/// Create a copy of PrintJob
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderLineId = freezed,Object? orderId = freezed,Object? orderNumber = freezed,Object? variantId = null,Object? quantity = null,Object? status = null,Object? estimatedMin = null,Object? startedAt = freezed,Object? finishedAt = freezed,Object? notes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,orderLineId: freezed == orderLineId ? _self.orderLineId : orderLineId // ignore: cast_nullable_to_non_nullable
as int?,orderId: freezed == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as int?,orderNumber: freezed == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as int?,variantId: null == variantId ? _self.variantId : variantId // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PrintJobStatus,estimatedMin: null == estimatedMin ? _self.estimatedMin : estimatedMin // ignore: cast_nullable_to_non_nullable
as int,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,finishedAt: freezed == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PrintJob].
extension PrintJobPatterns on PrintJob {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrintJob value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrintJob() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrintJob value)  $default,){
final _that = this;
switch (_that) {
case _PrintJob():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrintJob value)?  $default,){
final _that = this;
switch (_that) {
case _PrintJob() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int? orderLineId,  int? orderId,  int? orderNumber,  int variantId,  int quantity,  PrintJobStatus status,  int estimatedMin,  DateTime? startedAt,  DateTime? finishedAt,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrintJob() when $default != null:
return $default(_that.id,_that.orderLineId,_that.orderId,_that.orderNumber,_that.variantId,_that.quantity,_that.status,_that.estimatedMin,_that.startedAt,_that.finishedAt,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int? orderLineId,  int? orderId,  int? orderNumber,  int variantId,  int quantity,  PrintJobStatus status,  int estimatedMin,  DateTime? startedAt,  DateTime? finishedAt,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _PrintJob():
return $default(_that.id,_that.orderLineId,_that.orderId,_that.orderNumber,_that.variantId,_that.quantity,_that.status,_that.estimatedMin,_that.startedAt,_that.finishedAt,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int? orderLineId,  int? orderId,  int? orderNumber,  int variantId,  int quantity,  PrintJobStatus status,  int estimatedMin,  DateTime? startedAt,  DateTime? finishedAt,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _PrintJob() when $default != null:
return $default(_that.id,_that.orderLineId,_that.orderId,_that.orderNumber,_that.variantId,_that.quantity,_that.status,_that.estimatedMin,_that.startedAt,_that.finishedAt,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PrintJob extends PrintJob {
  const _PrintJob({required this.id, this.orderLineId, this.orderId, this.orderNumber, required this.variantId, this.quantity = 1, this.status = PrintJobStatus.queued, required this.estimatedMin, this.startedAt, this.finishedAt, this.notes}): super._();
  factory _PrintJob.fromJson(Map<String, dynamic> json) => _$PrintJobFromJson(json);

@override final  int id;
@override final  int? orderLineId;
// null = tarefa manual (stock, protótipo)
@override final  int? orderId;
// a encomenda (vem da API, juntando à linha)
@override final  int? orderNumber;
// o número que se vê: #1041
@override final  int variantId;
@override@JsonKey() final  int quantity;
@override@JsonKey() final  PrintJobStatus status;
@override final  int estimatedMin;
// tempo de impressão estimado, em minutos
@override final  DateTime? startedAt;
@override final  DateTime? finishedAt;
@override final  String? notes;

/// Create a copy of PrintJob
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrintJobCopyWith<_PrintJob> get copyWith => __$PrintJobCopyWithImpl<_PrintJob>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PrintJobToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrintJob&&(identical(other.id, id) || other.id == id)&&(identical(other.orderLineId, orderLineId) || other.orderLineId == orderLineId)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.variantId, variantId) || other.variantId == variantId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.status, status) || other.status == status)&&(identical(other.estimatedMin, estimatedMin) || other.estimatedMin == estimatedMin)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.finishedAt, finishedAt) || other.finishedAt == finishedAt)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderLineId,orderId,orderNumber,variantId,quantity,status,estimatedMin,startedAt,finishedAt,notes);

@override
String toString() {
  return 'PrintJob(id: $id, orderLineId: $orderLineId, orderId: $orderId, orderNumber: $orderNumber, variantId: $variantId, quantity: $quantity, status: $status, estimatedMin: $estimatedMin, startedAt: $startedAt, finishedAt: $finishedAt, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$PrintJobCopyWith<$Res> implements $PrintJobCopyWith<$Res> {
  factory _$PrintJobCopyWith(_PrintJob value, $Res Function(_PrintJob) _then) = __$PrintJobCopyWithImpl;
@override @useResult
$Res call({
 int id, int? orderLineId, int? orderId, int? orderNumber, int variantId, int quantity, PrintJobStatus status, int estimatedMin, DateTime? startedAt, DateTime? finishedAt, String? notes
});




}
/// @nodoc
class __$PrintJobCopyWithImpl<$Res>
    implements _$PrintJobCopyWith<$Res> {
  __$PrintJobCopyWithImpl(this._self, this._then);

  final _PrintJob _self;
  final $Res Function(_PrintJob) _then;

/// Create a copy of PrintJob
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderLineId = freezed,Object? orderId = freezed,Object? orderNumber = freezed,Object? variantId = null,Object? quantity = null,Object? status = null,Object? estimatedMin = null,Object? startedAt = freezed,Object? finishedAt = freezed,Object? notes = freezed,}) {
  return _then(_PrintJob(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,orderLineId: freezed == orderLineId ? _self.orderLineId : orderLineId // ignore: cast_nullable_to_non_nullable
as int?,orderId: freezed == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as int?,orderNumber: freezed == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as int?,variantId: null == variantId ? _self.variantId : variantId // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PrintJobStatus,estimatedMin: null == estimatedMin ? _self.estimatedMin : estimatedMin // ignore: cast_nullable_to_non_nullable
as int,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,finishedAt: freezed == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
