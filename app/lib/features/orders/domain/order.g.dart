// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Order _$OrderFromJson(Map<String, dynamic> json) => _Order(
  id: (json['id'] as num).toInt(),
  orderNumber: (json['order_number'] as num).toInt(),
  channelId: (json['channel_id'] as num).toInt(),
  externalRef: json['external_ref'] as String?,
  customerId: (json['customer_id'] as num?)?.toInt(),
  customerName: json['customer_name'] as String,
  customerContact: json['customer_contact'] as String?,
  status:
      $enumDecodeNullable(_$OrderStatusEnumMap, json['status']) ??
      OrderStatus.pending,
  paymentStatus:
      $enumDecodeNullable(_$PaymentStatusEnumMap, json['payment_status']) ??
      PaymentStatus.unpaid,
  paymentMethod: json['payment_method'] as String?,
  deliveryMethod:
      $enumDecodeNullable(_$DeliveryMethodEnumMap, json['delivery_method']) ??
      DeliveryMethod.carrier,
  carrierName: json['carrier_name'] as String?,
  trackingCode: json['tracking_code'] as String?,
  shippingCharged: (json['shipping_charged'] as num?)?.toDouble() ?? 0,
  shippingPaid: (json['shipping_paid'] as num?)?.toDouble() ?? 0,
  shipByDate: json['ship_by_date'] == null
      ? null
      : DateTime.parse(json['ship_by_date'] as String),
  notes: json['notes'] as String?,
  createdManually: json['created_manually'] as bool? ?? false,
  isSeen: json['is_seen'] as bool? ?? false,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  lines:
      (json['lines'] as List<dynamic>?)
          ?.map((e) => OrderLine.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$OrderToJson(_Order instance) => <String, dynamic>{
  'id': instance.id,
  'order_number': instance.orderNumber,
  'channel_id': instance.channelId,
  'external_ref': instance.externalRef,
  'customer_id': instance.customerId,
  'customer_name': instance.customerName,
  'customer_contact': instance.customerContact,
  'status': _$OrderStatusEnumMap[instance.status]!,
  'payment_status': _$PaymentStatusEnumMap[instance.paymentStatus]!,
  'payment_method': instance.paymentMethod,
  'delivery_method': _$DeliveryMethodEnumMap[instance.deliveryMethod]!,
  'carrier_name': instance.carrierName,
  'tracking_code': instance.trackingCode,
  'shipping_charged': instance.shippingCharged,
  'shipping_paid': instance.shippingPaid,
  'ship_by_date': instance.shipByDate?.toIso8601String(),
  'notes': instance.notes,
  'created_manually': instance.createdManually,
  'is_seen': instance.isSeen,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'lines': instance.lines.map((e) => e.toJson()).toList(),
};

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.inProduction: 'in_production',
  OrderStatus.ready: 'ready',
  OrderStatus.shipped: 'shipped',
  OrderStatus.delivered: 'delivered',
  OrderStatus.cancelled: 'cancelled',
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.unpaid: 'unpaid',
  PaymentStatus.paid: 'paid',
  PaymentStatus.refunded: 'refunded',
};

const _$DeliveryMethodEnumMap = {
  DeliveryMethod.carrier: 'carrier',
  DeliveryMethod.hand: 'hand',
  DeliveryMethod.pickup: 'pickup',
  DeliveryMethod.other: 'other',
};

_OrderLine _$OrderLineFromJson(Map<String, dynamic> json) => _OrderLine(
  id: (json['id'] as num).toInt(),
  variantId: (json['variant_id'] as num).toInt(),
  quantity: (json['quantity'] as num?)?.toInt() ?? 1,
  unitPrice: (json['unit_price'] as num).toDouble(),
  discount: (json['discount'] as num?)?.toDouble() ?? 0,
  customization: json['customization'] as String?,
  unitCost: (json['unit_cost'] as num).toDouble(),
  channelFee: (json['channel_fee'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$OrderLineToJson(_OrderLine instance) =>
    <String, dynamic>{
      'id': instance.id,
      'variant_id': instance.variantId,
      'quantity': instance.quantity,
      'unit_price': instance.unitPrice,
      'discount': instance.discount,
      'customization': instance.customization,
      'unit_cost': instance.unitCost,
      'channel_fee': instance.channelFee,
    };
