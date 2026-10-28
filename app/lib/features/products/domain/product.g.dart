// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  baseSku: json['base_sku'] as String,
  description: json['description'] as String?,
  categoryId: (json['category_id'] as num?)?.toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  status:
      $enumDecodeNullable(_$ProductStatusEnumMap, json['status']) ??
      ProductStatus.draft,
  isCustomizable: json['is_customizable'] as bool? ?? false,
  isPack: json['is_pack'] as bool? ?? false,
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'base_sku': instance.baseSku,
  'description': instance.description,
  'category_id': instance.categoryId,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'status': _$ProductStatusEnumMap[instance.status]!,
  'is_customizable': instance.isCustomizable,
  'is_pack': instance.isPack,
};

const _$ProductStatusEnumMap = {
  ProductStatus.active: 'active',
  ProductStatus.draft: 'draft',
  ProductStatus.archived: 'archived',
};
