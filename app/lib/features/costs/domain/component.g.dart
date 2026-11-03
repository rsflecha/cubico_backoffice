// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'component.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Component _$ComponentFromJson(Map<String, dynamic> json) => _Component(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  kind: $enumDecode(_$ComponentKindEnumMap, json['kind']),
  sizeLabel: json['size_label'] as String?,
  weightG: (json['weight_g'] as num?)?.toInt() ?? 0,
  packPrice: (json['pack_price'] as num).toDouble(),
  unitsPerPack: (json['units_per_pack'] as num?)?.toInt() ?? 1,
  stockQty: (json['stock_qty'] as num?)?.toInt() ?? 0,
  minStockQty: (json['min_stock_qty'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ComponentToJson(_Component instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'kind': _$ComponentKindEnumMap[instance.kind]!,
      'size_label': instance.sizeLabel,
      'weight_g': instance.weightG,
      'pack_price': instance.packPrice,
      'units_per_pack': instance.unitsPerPack,
      'stock_qty': instance.stockQty,
      'min_stock_qty': instance.minStockQty,
    };

const _$ComponentKindEnumMap = {
  ComponentKind.component: 'component',
  ComponentKind.packaging: 'packaging',
};
