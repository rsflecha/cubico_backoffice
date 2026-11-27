// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filament_movement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FilamentMovement _$FilamentMovementFromJson(Map<String, dynamic> json) =>
    _FilamentMovement(
      id: (json['id'] as num).toInt(),
      type: $enumDecode(_$MovementTypeEnumMap, json['movement_type']),
      grams: (json['grams'] as num).toDouble(),
      spools: (json['spools'] as num?)?.toInt(),
      paidPrice: (json['paid_price'] as num?)?.toDouble(),
      shippingCost: (json['shipping_cost'] as num?)?.toDouble(),
      note: json['note'] as String?,
      userName: json['user_name'] as String?,
      printJobId: (json['print_job_id'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$FilamentMovementToJson(_FilamentMovement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'movement_type': _$MovementTypeEnumMap[instance.type]!,
      'grams': instance.grams,
      'spools': instance.spools,
      'paid_price': instance.paidPrice,
      'shipping_cost': instance.shippingCost,
      'note': instance.note,
      'user_name': instance.userName,
      'print_job_id': instance.printJobId,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$MovementTypeEnumMap = {
  MovementType.purchase: 'purchase',
  MovementType.consumption: 'consumption',
  MovementType.failure: 'failure',
  MovementType.adjustment: 'adjustment',
  MovementType.reversal: 'reversal',
};
