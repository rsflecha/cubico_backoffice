import 'package:cubico_backoffice/features/costs/domain/filament.dart';
import 'package:cubico_backoffice/features/costs/domain/filament_repository.dart';
import 'package:cubico_backoffice/features/stock/domain/filament_movement.dart';
import 'package:cubico_backoffice/features/stock/domain/filament_stock.dart';
import 'package:cubico_backoffice/features/stock/domain/stock_repository.dart';
import 'package:cubico_backoffice/features/stock/domain/weighing.dart';

/// O stock em memória, para o modo demo (sem servidor).
/// Cada filamento começa com uma compra de 1 rolo; compras e acertos contam como na API.
class DemoStockRepository implements StockRepository {
  DemoStockRepository(this._filaments);

  final FilamentRepository _filaments;
  final Map<int, List<FilamentMovement>> _movements = {};
  int _nextId = 1;

  Future<void> _latency() => Future.delayed(const Duration(milliseconds: 300));

  /// Garante que cada filamento conhecido tem a compra inicial.
  Future<List<Filament>> _sync() async {
    final filaments = await _filaments.fetchAll();
    for (final f in filaments) {
      _movements.putIfAbsent(
        f.id,
        () => [
          FilamentMovement(
            id: _nextId++,
            type: MovementType.purchase,
            grams: f.spoolWeightG.toDouble(),
            spools: 1,
            paidPrice: f.paidPrice,
            shippingCost: 0,
            userName: "Demo",
            createdAt: DateTime.now(),
          ),
        ],
      );
    }
    return filaments;
  }

  double _stockOf(int filamentId) =>
      (_movements[filamentId] ?? const []).fold<double>(0, (sum, m) => sum + m.grams);

  Future<Filament> _filament(int id) async {
    final filaments = await _sync();
    return filaments.firstWhere((f) => f.id == id, orElse: () => throw StateError("Filamento $id não existe."));
  }

  @override
  Future<List<FilamentStock>> fetchStock() async {
    await _latency();
    final filaments = await _sync();
    return [
      for (final f in filaments)
        FilamentStock(
          filamentId: f.id,
          stockG: _stockOf(f.id),
          spools: _stockOf(f.id) / f.spoolWeightG,
          minStockG: f.minStockG,
        ),
    ];
  }

  @override
  Future<List<FilamentMovement>> fetchMovements(int filamentId) async {
    await _latency();
    await _sync();
    // o mais recente primeiro (o id cresce com o tempo)
    final list = List<FilamentMovement>.of(_movements[filamentId] ?? const []);
    list.sort((a, b) => b.id.compareTo(a.id));
    return list;
  }

  @override
  Future<FilamentMovement> recordPurchase(
    int filamentId, {
    required int spools,
    required double paidPrice,
    required double shippingCost,
  }) async {
    await _latency();
    final f = await _filament(filamentId);
    if (spools <= 0) throw StateError("Tem de comprar pelo menos 1 rolo.");
    final movement = FilamentMovement(
      id: _nextId++,
      type: MovementType.purchase,
      grams: (spools * f.spoolWeightG).toDouble(),
      spools: spools,
      paidPrice: paidPrice,
      shippingCost: shippingCost,
      userName: "Demo",
      createdAt: DateTime.now(),
    );
    _movements[filamentId]!.add(movement);
    return movement;
  }

  @override
  Future<FilamentMovement> recordAdjustment(
    int filamentId, {
    required int closedSpools,
    required List<double> openGrossG,
    String? note,
  }) async {
    await _latency();
    final f = await _filament(filamentId);
    final problem = weighingProblem(closedSpools: closedSpools, openGrossG: openGrossG, emptySpoolG: f.emptySpoolG);
    if (problem != null) throw StateError(problem);
    final total = weighedTotal(
      closedSpools: closedSpools,
      spoolWeightG: f.spoolWeightG,
      openGrossG: openGrossG,
      emptySpoolG: f.emptySpoolG,
    );
    final movement = FilamentMovement(
      id: _nextId++,
      type: MovementType.adjustment,
      grams: total - _stockOf(filamentId), // a diferença, mesmo que seja 0
      note: note,
      userName: "Demo",
      createdAt: DateTime.now(),
    );
    _movements[filamentId]!.add(movement);
    return movement;
  }
}
