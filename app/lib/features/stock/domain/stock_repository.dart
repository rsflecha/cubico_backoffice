import 'package:cubico_backoffice/features/stock/domain/filament_movement.dart';
import 'package:cubico_backoffice/features/stock/domain/filament_stock.dart';

abstract interface class StockRepository {
  /// O stock atual de cada filamento.
  Future<List<FilamentStock>> fetchStock();

  /// O histórico de um filamento, do mais recente para o mais antigo.
  Future<List<FilamentMovement>> fetchMovements(int filamentId);

  /// Regista uma compra de rolos fechados.
  Future<FilamentMovement> recordPurchase(
    int filamentId, {
    required int spools,
    required double paidPrice,
    required double shippingCost,
  });

  /// Acerta o stock pelo que se pesou: rolos fechados + peso bruto de cada rolo aberto.
  Future<FilamentMovement> recordAdjustment(
    int filamentId, {
    required int closedSpools,
    required List<double> openGrossG,
    String? note,
  });
}
