import 'package:freezed_annotation/freezed_annotation.dart';

part 'fixed_cost.freezed.dart';
part 'fixed_cost.g.dart';

/// Um custo que se paga todos os meses, venda-se muito ou pouco (Etsy Plus, alojamento…).
@freezed
abstract class FixedCost with _$FixedCost {
  const factory FixedCost({
    required int id,
    required String name,
    required double monthlyValue, // € por mês
  }) = _FixedCost;

  factory FixedCost.fromJson(Map<String, dynamic> json) => _$FixedCostFromJson(json);
}
