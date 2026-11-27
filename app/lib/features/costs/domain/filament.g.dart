// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filament.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Filament _$FilamentFromJson(Map<String, dynamic> json) => _Filament(
  id: (json['id'] as num).toInt(),
  material: json['material'] as String,
  brand: json['brand'] as String?,
  colorName: json['color_name'] as String,
  colorHex: json['color_hex'] as String?,
  listPrice: (json['list_price'] as num?)?.toDouble() ?? 0,
  paidPrice: (json['paid_price'] as num?)?.toDouble() ?? 0,
  spoolWeightG: (json['spool_weight_g'] as num?)?.toInt() ?? 1000,
  shippingCost: (json['shipping_cost'] as num?)?.toDouble() ?? 0,
  spoolsInOrder: (json['spools_in_order'] as num?)?.toInt() ?? 1,
  minStockG: (json['min_stock_g'] as num?)?.toInt() ?? 250,
  emptySpoolG: (json['empty_spool_g'] as num?)?.toInt() ?? 0,
  isActive: json['is_active'] as bool? ?? true,
);

Map<String, dynamic> _$FilamentToJson(_Filament instance) => <String, dynamic>{
  'id': instance.id,
  'material': instance.material,
  'brand': instance.brand,
  'color_name': instance.colorName,
  'color_hex': instance.colorHex,
  'list_price': instance.listPrice,
  'paid_price': instance.paidPrice,
  'spool_weight_g': instance.spoolWeightG,
  'shipping_cost': instance.shippingCost,
  'spools_in_order': instance.spoolsInOrder,
  'min_stock_g': instance.minStockG,
  'empty_spool_g': instance.emptySpoolG,
  'is_active': instance.isActive,
};
