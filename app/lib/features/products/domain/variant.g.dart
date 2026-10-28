// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'variant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Variant _$VariantFromJson(Map<String, dynamic> json) => _Variant(
  id: (json['id'] as num).toInt(),
  productId: (json['product_id'] as num).toInt(),
  name: json['name'] as String,
  sku: json['sku'] as String,
  salePrice: (json['sale_price'] as num).toDouble(),
  printerId: (json['printer_id'] as num?)?.toInt(),
  modelFile: json['model_file'] as String?,
  etsyListingId: json['etsy_listing_id'] as String?,
  printTimeMin: (json['print_time_min'] as num?)?.toInt() ?? 0,
  plateCount: (json['plate_count'] as num?)?.toInt() ?? 1,
  weightG: (json['weight_g'] as num?)?.toInt() ?? 0,
  isActive: json['is_active'] as bool? ?? true,
);

Map<String, dynamic> _$VariantToJson(_Variant instance) => <String, dynamic>{
  'id': instance.id,
  'product_id': instance.productId,
  'name': instance.name,
  'sku': instance.sku,
  'sale_price': instance.salePrice,
  'printer_id': instance.printerId,
  'model_file': instance.modelFile,
  'etsy_listing_id': instance.etsyListingId,
  'print_time_min': instance.printTimeMin,
  'plate_count': instance.plateCount,
  'weight_g': instance.weightG,
  'is_active': instance.isActive,
};
