import 'package:freezed_annotation/freezed_annotation.dart';

part 'cost_settings.freezed.dart';
part 'cost_settings.g.dart';

/// As definições de custos e preços da loja (tabela settings).
@freezed
abstract class CostSettings with _$CostSettings {
  const factory CostSettings({
    required double kwhPrice,               // € por kWh, com IVA
    @Default(60) double targetMarginPct,    // margem alvo para o preço sugerido
    @Default(35) double minMarginPct,       // abaixo disto, a app avisa
    @Default(0.50) double rounding,         // preços sugeridos arredondados a isto
    @Default(0) double hourlyRate,          // valor da tua hora (0 = não conta)
    @Default(false) bool includeFixedCosts, // repartir custos fixos pelas encomendas
  }) = _CostSettings;

  factory CostSettings.fromJson(Map<String, dynamic> json) =>
      _$CostSettingsFromJson(json);
}