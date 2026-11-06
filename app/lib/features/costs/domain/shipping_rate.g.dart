// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipping_rate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShippingRate _$ShippingRateFromJson(Map<String, dynamic> json) =>
    _ShippingRate(
      id: (json['id'] as num).toInt(),
      carrierId: (json['carrier_id'] as num?)?.toInt() ?? 1,
      zoneId: (json['zone_id'] as num?)?.toInt() ?? 1,
      maxWeightG: (json['max_weight_g'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
    );

Map<String, dynamic> _$ShippingRateToJson(_ShippingRate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'carrier_id': instance.carrierId,
      'zone_id': instance.zoneId,
      'max_weight_g': instance.maxWeightG,
      'price': instance.price,
    };
