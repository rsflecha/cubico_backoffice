// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filament_stock.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FilamentStock _$FilamentStockFromJson(Map<String, dynamic> json) =>
    _FilamentStock(
      filamentId: (json['filament_id'] as num).toInt(),
      stockG: (json['stock_g'] as num).toDouble(),
      spools: (json['spools'] as num).toDouble(),
      minStockG: (json['min_stock_g'] as num).toInt(),
    );

Map<String, dynamic> _$FilamentStockToJson(_FilamentStock instance) =>
    <String, dynamic>{
      'filament_id': instance.filamentId,
      'stock_g': instance.stockG,
      'spools': instance.spools,
      'min_stock_g': instance.minStockG,
    };
