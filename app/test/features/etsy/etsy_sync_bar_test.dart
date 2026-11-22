import 'package:cubico_backoffice/core/api/api_exception.dart';
import 'package:cubico_backoffice/features/etsy/domain/etsy_listings_check.dart';
import 'package:cubico_backoffice/features/etsy/domain/etsy_repository.dart';
import 'package:cubico_backoffice/features/etsy/domain/etsy_status.dart';
import 'package:cubico_backoffice/features/etsy/domain/etsy_sync.dart';
import 'package:cubico_backoffice/features/etsy/presentation/etsy_providers.dart';
import 'package:cubico_backoffice/features/etsy/presentation/etsy_sync_bar.dart';
import 'package:cubico_backoffice/features/orders/domain/order.dart';
import 'package:cubico_backoffice/features/orders/presentation/orders_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Uma Etsy de faz-de-conta: devolve o que o teste mandar.
class _FakeEtsy implements EtsyRepository {
  @override
  Future<void> link({required String productId, required String listingId, required int variantId}) async {}

  @override
  Future<void> unlink(String productId) async {}

  _FakeEtsy(this.info, this.result);
  EtsySyncInfo info;
  final Object result; // EtsySyncRun, ou uma exceção para lançar
  var syncCalls = 0;

  @override
  Future<EtsySyncInfo> fetchSyncInfo() async => info;
  @override
  Future<EtsySyncRun> syncNow() async {
    syncCalls++;
    if (result is EtsySyncRun) return result as EtsySyncRun;
    throw result;
  }

  @override
  Future<EtsyStatus> fetchStatus() async => const EtsyStatus();
  @override
  Future<Uri> startConnect() async => Uri();
  @override
  Future<void> disconnect() async {}
  @override
  Future<EtsyListingsCheck> checkListings() async => throw UnimplementedError();
}

void main() {
  test("timeAgo", () {
    final now = DateTime(2026, 11, 16, 18);
    expect(timeAgo(now.subtract(const Duration(seconds: 20)), now), "agora mesmo");
    expect(timeAgo(now.subtract(const Duration(minutes: 5)), now), "há 5 min");
    expect(timeAgo(now.subtract(const Duration(hours: 3)), now), "há 3 h");
    expect(timeAgo(now.subtract(const Duration(days: 1)), now), "há 1 dia");
    expect(timeAgo(now.subtract(const Duration(days: 4)), now), "há 4 dias");
  });

  test("lê a última sincronização como a API a manda", () {
    final info = EtsySyncInfo.fromJson({
      "connected": true,
      "last": {
        "status": "ok",
        "started_at": "2026-11-16 18:00:00",
        "finished_at": "2026-11-16 18:00:04",
        "created_count": 2,
        "updated_count": 0,
        "skipped_count": 1,
        "error_message": null,
        "notes": "recibo #123: SKU CD3-X-01",
      },
    });
    expect(info.last!.createdCount, 2);
    expect(info.last!.notes, contains("CD3-X-01"));
  });

  Future<_FakeEtsy> show(WidgetTester tester, EtsySyncInfo info, Object result) async {
    final fake = _FakeEtsy(info, result);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        etsyRepositoryProvider.overrideWithValue(fake),
        ordersProvider.overrideWith((ref) async => <Order>[]),
      ],
      child: const MaterialApp(home: Scaffold(body: EtsySyncBar())),
    ));
    await tester.pump();
    return fake;
  }

  testWidgets("loja por ligar: a barra não aparece", (tester) async {
    await show(tester, const EtsySyncInfo(), Object());
    expect(find.text("Sincronizar agora"), findsNothing);
  });

  testWidgets("sincronizar: resumo e a lista das por associar", (tester) async {
    final run = EtsySyncRun(
      status: "ok",
      startedAt: DateTime.now(),
      createdCount: 2,
      skippedCount: 1,
      notes: "recibo #123: SKU CD3-X-01",
    );
    final fake = await show(tester, EtsySyncInfo(connected: true, last: run), run);
    expect(find.textContaining("1 por associar"), findsOneWidget);

    await tester.tap(find.text("Sincronizar agora"));
    await tester.pumpAndSettle();
    expect(fake.syncCalls, 1);
    expect(find.text("Etsy: 2 novas, 1 por associar."), findsOneWidget);
    expect(find.text("• recibo #123: SKU CD3-X-01"), findsOneWidget);
  });

  testWidgets("erro da Etsy: mostra a mensagem", (tester) async {
    await show(tester, const EtsySyncInfo(connected: true), const ApiException("A Etsy respondeu com erro (500)."));
    expect(find.text("Etsy · ainda não sincronizou"), findsOneWidget);
    await tester.tap(find.text("Sincronizar agora"));
    await tester.pumpAndSettle();
    expect(find.text("A Etsy respondeu com erro (500)."), findsOneWidget);
  });
}
