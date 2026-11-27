import 'package:cubico_backoffice/features/costs/domain/filament.dart';
import 'package:cubico_backoffice/features/costs/data/demo_filament_repository.dart';
import 'package:cubico_backoffice/features/stock/data/demo_stock_repository.dart';
import 'package:cubico_backoffice/features/stock/domain/filament_movement.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  inactiveRule();
  DemoStockRepository make() => DemoStockRepository(DemoFilamentRepository());

  Future<double> stockOf(DemoStockRepository r, int id) async =>
      (await r.fetchStock()).firstWhere((s) => s.filamentId == id).stockG;

  test("começa com 1 rolo por filamento", () async {
    expect(await stockOf(make(), 1), 1000);
  });

  test("uma compra de 2 rolos sobe o stock 2000 g e aparece primeiro", () async {
    final r = make();
    await r.recordPurchase(1, spools: 2, paidPrice: 20, shippingCost: 3);
    expect(await stockOf(r, 1), 3000);
    final moves = await r.fetchMovements(1);
    expect(moves.first.type, MovementType.purchase);
    expect(moves.first.grams, 2000);
  });

  test("um acerto com 1 rolo fechado deixa o stock em 1000 g", () async {
    final r = make();
    await r.recordPurchase(1, spools: 2, paidPrice: 20, shippingCost: 3);
    final m = await r.recordAdjustment(1, closedSpools: 1, openGrossG: []);
    expect(m.type, MovementType.adjustment);
    expect(m.grams, -2000);
    expect(await stockOf(r, 1), 1000);
  });

  test("um acerto com rolo aberto usa a tara do filamento", () async {
    final r = make();
    await r.recordAdjustment(1, closedSpools: 0, openGrossG: [712]);
    expect(await stockOf(r, 1), 462);
  });

  test("FilamentMovement.fromJson sem paid_price dá null", () {
    final m = FilamentMovement.fromJson({
      "id": 5,
      "filament_id": 1,
      "movement_type": "consumption",
      "grams": -12.5,
      "spools": null,
      "print_job_id": 3,
      "note": null,
      "user_name": "Ana",
      "created_at": "2026-11-27 10:30:00",
    });
    expect(m.paidPrice, isNull);
    expect(m.shippingCost, isNull);
    expect(m.type, MovementType.consumption);
    expect(m.grams, -12.5);
  });
}

/// Um repositório de filamentos com um inativo, para a regra "só os ativos têm linha de stock".
class _WithInactive extends DemoFilamentRepository {
  @override
  Future<List<Filament>> fetchAll() async {
    final all = await super.fetchAll();
    return [for (final f in all) f.id == 2 ? f.copyWith(isActive: false) : f];
  }
}

void inactiveRule() {
  test("filamento inativo não tem linha de stock (como na API)", () async {
    final r = DemoStockRepository(_WithInactive());
    final ids = (await r.fetchStock()).map((s) => s.filamentId).toList();
    expect(ids, [1, 3]);
  });
}
