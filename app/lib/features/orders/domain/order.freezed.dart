// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Order {

 int get id; int get orderNumber;// o número que se vê: #1042
 int get channelId; String? get externalRef;// nº da encomenda na Etsy
 int? get customerId;// null = sem ficha de cliente
 String get customerName; String? get customerContact; OrderStatus get status; PaymentStatus get paymentStatus; String? get paymentMethod; DeliveryMethod get deliveryMethod; String? get carrierName; String? get trackingCode; double get shippingCharged;// portes que o cliente pagou
 double get shippingPaid;// portes que custaram mesmo
 DateTime? get shipByDate;// prazo de envio
 String? get notes; bool get createdManually; bool get isSeen; DateTime get createdAt; DateTime get updatedAt; List<OrderLine> get lines;
/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderCopyWith<Order> get copyWith => _$OrderCopyWithImpl<Order>(this as Order, _$identity);

  /// Serializes this Order to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Order&&(identical(other.id, id) || other.id == id)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.externalRef, externalRef) || other.externalRef == externalRef)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerContact, customerContact) || other.customerContact == customerContact)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.deliveryMethod, deliveryMethod) || other.deliveryMethod == deliveryMethod)&&(identical(other.carrierName, carrierName) || other.carrierName == carrierName)&&(identical(other.trackingCode, trackingCode) || other.trackingCode == trackingCode)&&(identical(other.shippingCharged, shippingCharged) || other.shippingCharged == shippingCharged)&&(identical(other.shippingPaid, shippingPaid) || other.shippingPaid == shippingPaid)&&(identical(other.shipByDate, shipByDate) || other.shipByDate == shipByDate)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdManually, createdManually) || other.createdManually == createdManually)&&(identical(other.isSeen, isSeen) || other.isSeen == isSeen)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.lines, lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,orderNumber,channelId,externalRef,customerId,customerName,customerContact,status,paymentStatus,paymentMethod,deliveryMethod,carrierName,trackingCode,shippingCharged,shippingPaid,shipByDate,notes,createdManually,isSeen,createdAt,updatedAt,const DeepCollectionEquality().hash(lines)]);

@override
String toString() {
  return 'Order(id: $id, orderNumber: $orderNumber, channelId: $channelId, externalRef: $externalRef, customerId: $customerId, customerName: $customerName, customerContact: $customerContact, status: $status, paymentStatus: $paymentStatus, paymentMethod: $paymentMethod, deliveryMethod: $deliveryMethod, carrierName: $carrierName, trackingCode: $trackingCode, shippingCharged: $shippingCharged, shippingPaid: $shippingPaid, shipByDate: $shipByDate, notes: $notes, createdManually: $createdManually, isSeen: $isSeen, createdAt: $createdAt, updatedAt: $updatedAt, lines: $lines)';
}


}

/// @nodoc
abstract mixin class $OrderCopyWith<$Res>  {
  factory $OrderCopyWith(Order value, $Res Function(Order) _then) = _$OrderCopyWithImpl;
@useResult
$Res call({
 int id, int orderNumber, int channelId, String? externalRef, int? customerId, String customerName, String? customerContact, OrderStatus status, PaymentStatus paymentStatus, String? paymentMethod, DeliveryMethod deliveryMethod, String? carrierName, String? trackingCode, double shippingCharged, double shippingPaid, DateTime? shipByDate, String? notes, bool createdManually, bool isSeen, DateTime createdAt, DateTime updatedAt, List<OrderLine> lines
});




}
/// @nodoc
class _$OrderCopyWithImpl<$Res>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._self, this._then);

  final Order _self;
  final $Res Function(Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderNumber = null,Object? channelId = null,Object? externalRef = freezed,Object? customerId = freezed,Object? customerName = null,Object? customerContact = freezed,Object? status = null,Object? paymentStatus = null,Object? paymentMethod = freezed,Object? deliveryMethod = null,Object? carrierName = freezed,Object? trackingCode = freezed,Object? shippingCharged = null,Object? shippingPaid = null,Object? shipByDate = freezed,Object? notes = freezed,Object? createdManually = null,Object? isSeen = null,Object? createdAt = null,Object? updatedAt = null,Object? lines = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as int,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as int,externalRef: freezed == externalRef ? _self.externalRef : externalRef // ignore: cast_nullable_to_non_nullable
as String?,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int?,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,customerContact: freezed == customerContact ? _self.customerContact : customerContact // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as PaymentStatus,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String?,deliveryMethod: null == deliveryMethod ? _self.deliveryMethod : deliveryMethod // ignore: cast_nullable_to_non_nullable
as DeliveryMethod,carrierName: freezed == carrierName ? _self.carrierName : carrierName // ignore: cast_nullable_to_non_nullable
as String?,trackingCode: freezed == trackingCode ? _self.trackingCode : trackingCode // ignore: cast_nullable_to_non_nullable
as String?,shippingCharged: null == shippingCharged ? _self.shippingCharged : shippingCharged // ignore: cast_nullable_to_non_nullable
as double,shippingPaid: null == shippingPaid ? _self.shippingPaid : shippingPaid // ignore: cast_nullable_to_non_nullable
as double,shipByDate: freezed == shipByDate ? _self.shipByDate : shipByDate // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdManually: null == createdManually ? _self.createdManually : createdManually // ignore: cast_nullable_to_non_nullable
as bool,isSeen: null == isSeen ? _self.isSeen : isSeen // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<OrderLine>,
  ));
}

}


/// Adds pattern-matching-related methods to [Order].
extension OrderPatterns on Order {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Order value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Order() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Order value)  $default,){
final _that = this;
switch (_that) {
case _Order():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Order value)?  $default,){
final _that = this;
switch (_that) {
case _Order() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int orderNumber,  int channelId,  String? externalRef,  int? customerId,  String customerName,  String? customerContact,  OrderStatus status,  PaymentStatus paymentStatus,  String? paymentMethod,  DeliveryMethod deliveryMethod,  String? carrierName,  String? trackingCode,  double shippingCharged,  double shippingPaid,  DateTime? shipByDate,  String? notes,  bool createdManually,  bool isSeen,  DateTime createdAt,  DateTime updatedAt,  List<OrderLine> lines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.orderNumber,_that.channelId,_that.externalRef,_that.customerId,_that.customerName,_that.customerContact,_that.status,_that.paymentStatus,_that.paymentMethod,_that.deliveryMethod,_that.carrierName,_that.trackingCode,_that.shippingCharged,_that.shippingPaid,_that.shipByDate,_that.notes,_that.createdManually,_that.isSeen,_that.createdAt,_that.updatedAt,_that.lines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int orderNumber,  int channelId,  String? externalRef,  int? customerId,  String customerName,  String? customerContact,  OrderStatus status,  PaymentStatus paymentStatus,  String? paymentMethod,  DeliveryMethod deliveryMethod,  String? carrierName,  String? trackingCode,  double shippingCharged,  double shippingPaid,  DateTime? shipByDate,  String? notes,  bool createdManually,  bool isSeen,  DateTime createdAt,  DateTime updatedAt,  List<OrderLine> lines)  $default,) {final _that = this;
switch (_that) {
case _Order():
return $default(_that.id,_that.orderNumber,_that.channelId,_that.externalRef,_that.customerId,_that.customerName,_that.customerContact,_that.status,_that.paymentStatus,_that.paymentMethod,_that.deliveryMethod,_that.carrierName,_that.trackingCode,_that.shippingCharged,_that.shippingPaid,_that.shipByDate,_that.notes,_that.createdManually,_that.isSeen,_that.createdAt,_that.updatedAt,_that.lines);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int orderNumber,  int channelId,  String? externalRef,  int? customerId,  String customerName,  String? customerContact,  OrderStatus status,  PaymentStatus paymentStatus,  String? paymentMethod,  DeliveryMethod deliveryMethod,  String? carrierName,  String? trackingCode,  double shippingCharged,  double shippingPaid,  DateTime? shipByDate,  String? notes,  bool createdManually,  bool isSeen,  DateTime createdAt,  DateTime updatedAt,  List<OrderLine> lines)?  $default,) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.orderNumber,_that.channelId,_that.externalRef,_that.customerId,_that.customerName,_that.customerContact,_that.status,_that.paymentStatus,_that.paymentMethod,_that.deliveryMethod,_that.carrierName,_that.trackingCode,_that.shippingCharged,_that.shippingPaid,_that.shipByDate,_that.notes,_that.createdManually,_that.isSeen,_that.createdAt,_that.updatedAt,_that.lines);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Order extends Order {
  const _Order({required this.id, required this.orderNumber, required this.channelId, this.externalRef, this.customerId, required this.customerName, this.customerContact, this.status = OrderStatus.pending, this.paymentStatus = PaymentStatus.unpaid, this.paymentMethod, this.deliveryMethod = DeliveryMethod.carrier, this.carrierName, this.trackingCode, this.shippingCharged = 0, this.shippingPaid = 0, this.shipByDate, this.notes, this.createdManually = false, this.isSeen = false, required this.createdAt, required this.updatedAt, final  List<OrderLine> lines = const []}): _lines = lines,super._();
  factory _Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

@override final  int id;
@override final  int orderNumber;
// o número que se vê: #1042
@override final  int channelId;
@override final  String? externalRef;
// nº da encomenda na Etsy
@override final  int? customerId;
// null = sem ficha de cliente
@override final  String customerName;
@override final  String? customerContact;
@override@JsonKey() final  OrderStatus status;
@override@JsonKey() final  PaymentStatus paymentStatus;
@override final  String? paymentMethod;
@override@JsonKey() final  DeliveryMethod deliveryMethod;
@override final  String? carrierName;
@override final  String? trackingCode;
@override@JsonKey() final  double shippingCharged;
// portes que o cliente pagou
@override@JsonKey() final  double shippingPaid;
// portes que custaram mesmo
@override final  DateTime? shipByDate;
// prazo de envio
@override final  String? notes;
@override@JsonKey() final  bool createdManually;
@override@JsonKey() final  bool isSeen;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
 final  List<OrderLine> _lines;
@override@JsonKey() List<OrderLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}


/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderCopyWith<_Order> get copyWith => __$OrderCopyWithImpl<_Order>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Order&&(identical(other.id, id) || other.id == id)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.externalRef, externalRef) || other.externalRef == externalRef)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerContact, customerContact) || other.customerContact == customerContact)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.deliveryMethod, deliveryMethod) || other.deliveryMethod == deliveryMethod)&&(identical(other.carrierName, carrierName) || other.carrierName == carrierName)&&(identical(other.trackingCode, trackingCode) || other.trackingCode == trackingCode)&&(identical(other.shippingCharged, shippingCharged) || other.shippingCharged == shippingCharged)&&(identical(other.shippingPaid, shippingPaid) || other.shippingPaid == shippingPaid)&&(identical(other.shipByDate, shipByDate) || other.shipByDate == shipByDate)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdManually, createdManually) || other.createdManually == createdManually)&&(identical(other.isSeen, isSeen) || other.isSeen == isSeen)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._lines, _lines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,orderNumber,channelId,externalRef,customerId,customerName,customerContact,status,paymentStatus,paymentMethod,deliveryMethod,carrierName,trackingCode,shippingCharged,shippingPaid,shipByDate,notes,createdManually,isSeen,createdAt,updatedAt,const DeepCollectionEquality().hash(_lines)]);

@override
String toString() {
  return 'Order(id: $id, orderNumber: $orderNumber, channelId: $channelId, externalRef: $externalRef, customerId: $customerId, customerName: $customerName, customerContact: $customerContact, status: $status, paymentStatus: $paymentStatus, paymentMethod: $paymentMethod, deliveryMethod: $deliveryMethod, carrierName: $carrierName, trackingCode: $trackingCode, shippingCharged: $shippingCharged, shippingPaid: $shippingPaid, shipByDate: $shipByDate, notes: $notes, createdManually: $createdManually, isSeen: $isSeen, createdAt: $createdAt, updatedAt: $updatedAt, lines: $lines)';
}


}

/// @nodoc
abstract mixin class _$OrderCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$OrderCopyWith(_Order value, $Res Function(_Order) _then) = __$OrderCopyWithImpl;
@override @useResult
$Res call({
 int id, int orderNumber, int channelId, String? externalRef, int? customerId, String customerName, String? customerContact, OrderStatus status, PaymentStatus paymentStatus, String? paymentMethod, DeliveryMethod deliveryMethod, String? carrierName, String? trackingCode, double shippingCharged, double shippingPaid, DateTime? shipByDate, String? notes, bool createdManually, bool isSeen, DateTime createdAt, DateTime updatedAt, List<OrderLine> lines
});




}
/// @nodoc
class __$OrderCopyWithImpl<$Res>
    implements _$OrderCopyWith<$Res> {
  __$OrderCopyWithImpl(this._self, this._then);

  final _Order _self;
  final $Res Function(_Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderNumber = null,Object? channelId = null,Object? externalRef = freezed,Object? customerId = freezed,Object? customerName = null,Object? customerContact = freezed,Object? status = null,Object? paymentStatus = null,Object? paymentMethod = freezed,Object? deliveryMethod = null,Object? carrierName = freezed,Object? trackingCode = freezed,Object? shippingCharged = null,Object? shippingPaid = null,Object? shipByDate = freezed,Object? notes = freezed,Object? createdManually = null,Object? isSeen = null,Object? createdAt = null,Object? updatedAt = null,Object? lines = null,}) {
  return _then(_Order(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as int,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as int,externalRef: freezed == externalRef ? _self.externalRef : externalRef // ignore: cast_nullable_to_non_nullable
as String?,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int?,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,customerContact: freezed == customerContact ? _self.customerContact : customerContact // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as PaymentStatus,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String?,deliveryMethod: null == deliveryMethod ? _self.deliveryMethod : deliveryMethod // ignore: cast_nullable_to_non_nullable
as DeliveryMethod,carrierName: freezed == carrierName ? _self.carrierName : carrierName // ignore: cast_nullable_to_non_nullable
as String?,trackingCode: freezed == trackingCode ? _self.trackingCode : trackingCode // ignore: cast_nullable_to_non_nullable
as String?,shippingCharged: null == shippingCharged ? _self.shippingCharged : shippingCharged // ignore: cast_nullable_to_non_nullable
as double,shippingPaid: null == shippingPaid ? _self.shippingPaid : shippingPaid // ignore: cast_nullable_to_non_nullable
as double,shipByDate: freezed == shipByDate ? _self.shipByDate : shipByDate // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdManually: null == createdManually ? _self.createdManually : createdManually // ignore: cast_nullable_to_non_nullable
as bool,isSeen: null == isSeen ? _self.isSeen : isSeen // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<OrderLine>,
  ));
}


}


/// @nodoc
mixin _$OrderLine {

 int get id; int get variantId; int get quantity; double get unitPrice;// preço de venda de cada unidade
 double get discount; String? get customization;// "nome: Ana", "cor: azul"…
 double get unitCost;// custo de produção, no dia da venda
 double get channelFee;
/// Create a copy of OrderLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderLineCopyWith<OrderLine> get copyWith => _$OrderLineCopyWithImpl<OrderLine>(this as OrderLine, _$identity);

  /// Serializes this OrderLine to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderLine&&(identical(other.id, id) || other.id == id)&&(identical(other.variantId, variantId) || other.variantId == variantId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.customization, customization) || other.customization == customization)&&(identical(other.unitCost, unitCost) || other.unitCost == unitCost)&&(identical(other.channelFee, channelFee) || other.channelFee == channelFee));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,variantId,quantity,unitPrice,discount,customization,unitCost,channelFee);

@override
String toString() {
  return 'OrderLine(id: $id, variantId: $variantId, quantity: $quantity, unitPrice: $unitPrice, discount: $discount, customization: $customization, unitCost: $unitCost, channelFee: $channelFee)';
}


}

/// @nodoc
abstract mixin class $OrderLineCopyWith<$Res>  {
  factory $OrderLineCopyWith(OrderLine value, $Res Function(OrderLine) _then) = _$OrderLineCopyWithImpl;
@useResult
$Res call({
 int id, int variantId, int quantity, double unitPrice, double discount, String? customization, double unitCost, double channelFee
});




}
/// @nodoc
class _$OrderLineCopyWithImpl<$Res>
    implements $OrderLineCopyWith<$Res> {
  _$OrderLineCopyWithImpl(this._self, this._then);

  final OrderLine _self;
  final $Res Function(OrderLine) _then;

/// Create a copy of OrderLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? variantId = null,Object? quantity = null,Object? unitPrice = null,Object? discount = null,Object? customization = freezed,Object? unitCost = null,Object? channelFee = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,variantId: null == variantId ? _self.variantId : variantId // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,discount: null == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as double,customization: freezed == customization ? _self.customization : customization // ignore: cast_nullable_to_non_nullable
as String?,unitCost: null == unitCost ? _self.unitCost : unitCost // ignore: cast_nullable_to_non_nullable
as double,channelFee: null == channelFee ? _self.channelFee : channelFee // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderLine].
extension OrderLinePatterns on OrderLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderLine value)  $default,){
final _that = this;
switch (_that) {
case _OrderLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderLine value)?  $default,){
final _that = this;
switch (_that) {
case _OrderLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int variantId,  int quantity,  double unitPrice,  double discount,  String? customization,  double unitCost,  double channelFee)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderLine() when $default != null:
return $default(_that.id,_that.variantId,_that.quantity,_that.unitPrice,_that.discount,_that.customization,_that.unitCost,_that.channelFee);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int variantId,  int quantity,  double unitPrice,  double discount,  String? customization,  double unitCost,  double channelFee)  $default,) {final _that = this;
switch (_that) {
case _OrderLine():
return $default(_that.id,_that.variantId,_that.quantity,_that.unitPrice,_that.discount,_that.customization,_that.unitCost,_that.channelFee);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int variantId,  int quantity,  double unitPrice,  double discount,  String? customization,  double unitCost,  double channelFee)?  $default,) {final _that = this;
switch (_that) {
case _OrderLine() when $default != null:
return $default(_that.id,_that.variantId,_that.quantity,_that.unitPrice,_that.discount,_that.customization,_that.unitCost,_that.channelFee);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderLine implements OrderLine {
  const _OrderLine({required this.id, required this.variantId, this.quantity = 1, required this.unitPrice, this.discount = 0, this.customization, required this.unitCost, this.channelFee = 0});
  factory _OrderLine.fromJson(Map<String, dynamic> json) => _$OrderLineFromJson(json);

@override final  int id;
@override final  int variantId;
@override@JsonKey() final  int quantity;
@override final  double unitPrice;
// preço de venda de cada unidade
@override@JsonKey() final  double discount;
@override final  String? customization;
// "nome: Ana", "cor: azul"…
@override final  double unitCost;
// custo de produção, no dia da venda
@override@JsonKey() final  double channelFee;

/// Create a copy of OrderLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderLineCopyWith<_OrderLine> get copyWith => __$OrderLineCopyWithImpl<_OrderLine>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderLineToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderLine&&(identical(other.id, id) || other.id == id)&&(identical(other.variantId, variantId) || other.variantId == variantId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.customization, customization) || other.customization == customization)&&(identical(other.unitCost, unitCost) || other.unitCost == unitCost)&&(identical(other.channelFee, channelFee) || other.channelFee == channelFee));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,variantId,quantity,unitPrice,discount,customization,unitCost,channelFee);

@override
String toString() {
  return 'OrderLine(id: $id, variantId: $variantId, quantity: $quantity, unitPrice: $unitPrice, discount: $discount, customization: $customization, unitCost: $unitCost, channelFee: $channelFee)';
}


}

/// @nodoc
abstract mixin class _$OrderLineCopyWith<$Res> implements $OrderLineCopyWith<$Res> {
  factory _$OrderLineCopyWith(_OrderLine value, $Res Function(_OrderLine) _then) = __$OrderLineCopyWithImpl;
@override @useResult
$Res call({
 int id, int variantId, int quantity, double unitPrice, double discount, String? customization, double unitCost, double channelFee
});




}
/// @nodoc
class __$OrderLineCopyWithImpl<$Res>
    implements _$OrderLineCopyWith<$Res> {
  __$OrderLineCopyWithImpl(this._self, this._then);

  final _OrderLine _self;
  final $Res Function(_OrderLine) _then;

/// Create a copy of OrderLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? variantId = null,Object? quantity = null,Object? unitPrice = null,Object? discount = null,Object? customization = freezed,Object? unitCost = null,Object? channelFee = null,}) {
  return _then(_OrderLine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,variantId: null == variantId ? _self.variantId : variantId // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,discount: null == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as double,customization: freezed == customization ? _self.customization : customization // ignore: cast_nullable_to_non_nullable
as String?,unitCost: null == unitCost ? _self.unitCost : unitCost // ignore: cast_nullable_to_non_nullable
as double,channelFee: null == channelFee ? _self.channelFee : channelFee // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
