// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fixed_cost.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FixedCost _$FixedCostFromJson(Map<String, dynamic> json) => _FixedCost(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  monthlyValue: (json['monthly_value'] as num).toDouble(),
);

Map<String, dynamic> _$FixedCostToJson(_FixedCost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'monthly_value': instance.monthlyValue,
    };
