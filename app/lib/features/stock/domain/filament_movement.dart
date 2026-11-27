import 'package:freezed_annotation/freezed_annotation.dart';

part 'filament_movement.freezed.dart';
part 'filament_movement.g.dart';

/// Tipos de movimento do livro de stock (nomes iguais aos da API).
enum MovementType {
  purchase,
  consumption,
  failure,
  adjustment,
  reversal,
}

/// Uma linha do livro de movimentos de um filamento. As gramas têm sinal:
/// compras somam, consumos e falhas subtraem.
@freezed
abstract class FilamentMovement with _$FilamentMovement {
  const factory FilamentMovement({
    required int id,
    @JsonKey(name: "movement_type") required MovementType type,
    required double grams,
    int? spools,
    // só vêm para quem pode ver custos: podem faltar no JSON
    double? paidPrice,
    double? shippingCost,
    String? note,
    String? userName,
    int? printJobId,
    required DateTime createdAt,
  }) = _FilamentMovement;

  factory FilamentMovement.fromJson(Map<String, dynamic> json) => _$FilamentMovementFromJson(json);
}
