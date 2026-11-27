import 'package:freezed_annotation/freezed_annotation.dart';

part 'filament_stock.freezed.dart';
part 'filament_stock.g.dart';

/// O stock atual de um filamento (a soma do livro de movimentos).
@freezed
abstract class FilamentStock with _$FilamentStock {
  const factory FilamentStock({
    required int filamentId,
    required double stockG,
    required double spools,
    required int minStockG,
  }) = _FilamentStock;

  factory FilamentStock.fromJson(Map<String, dynamic> json) => _$FilamentStockFromJson(json);
}
