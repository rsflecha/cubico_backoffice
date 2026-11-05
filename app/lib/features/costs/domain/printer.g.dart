// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'printer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Printer _$PrinterFromJson(Map<String, dynamic> json) => _Printer(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  powerW: (json['power_w'] as num).toInt(),
  purchasePrice: (json['purchase_price'] as num).toDouble(),
  lifespanHours: (json['lifespan_hours'] as num).toInt(),
  yearlyMaintenance: (json['yearly_maintenance'] as num?)?.toDouble() ?? 0,
  yearlyHours: (json['yearly_hours'] as num?)?.toInt() ?? 1000,
  isDefault: json['is_default'] as bool? ?? false,
);

Map<String, dynamic> _$PrinterToJson(_Printer instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'power_w': instance.powerW,
  'purchase_price': instance.purchasePrice,
  'lifespan_hours': instance.lifespanHours,
  'yearly_maintenance': instance.yearlyMaintenance,
  'yearly_hours': instance.yearlyHours,
  'is_default': instance.isDefault,
};
