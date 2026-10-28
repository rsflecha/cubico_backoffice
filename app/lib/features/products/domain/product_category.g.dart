// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductCategory _$ProductCategoryFromJson(Map<String, dynamic> json) =>
    _ProductCategory(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      color: json['color'] as String? ?? '#A1A1AA',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ProductCategoryToJson(_ProductCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'color': instance.color,
      'sort_order': instance.sortOrder,
    };
