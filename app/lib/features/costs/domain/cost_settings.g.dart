// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cost_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CostSettings _$CostSettingsFromJson(Map<String, dynamic> json) =>
    _CostSettings(
      kwhPrice: (json['kwh_price'] as num).toDouble(),
      targetMarginPct: (json['target_margin_pct'] as num?)?.toDouble() ?? 60,
      minMarginPct: (json['min_margin_pct'] as num?)?.toDouble() ?? 35,
      rounding: (json['rounding'] as num?)?.toDouble() ?? 0.50,
      hourlyRate: (json['hourly_rate'] as num?)?.toDouble() ?? 0,
      includeFixedCosts: json['include_fixed_costs'] as bool? ?? false,
    );

Map<String, dynamic> _$CostSettingsToJson(_CostSettings instance) =>
    <String, dynamic>{
      'kwh_price': instance.kwhPrice,
      'target_margin_pct': instance.targetMarginPct,
      'min_margin_pct': instance.minMarginPct,
      'rounding': instance.rounding,
      'hourly_rate': instance.hourlyRate,
      'include_fixed_costs': instance.includeFixedCosts,
    };
