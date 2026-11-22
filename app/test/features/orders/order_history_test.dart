import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:cubico_backoffice/features/orders/data/demo_order_repository.dart';
import 'package:cubico_backoffice/features/orders/domain/order_event.dart';
import 'package:cubico_backoffice/features/orders/presentation/order_detail_screen.dart';
import 'package:cubico_backoffice/features/orders/presentation/orders_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class _Demo extends DemoModeNotifier {
  @override
  bool build() => true;
}

/// As encomendas demo, com um histórico como o que a API manda.
class _WithHistory extends DemoOrderRepository {
  var asked = 0;

  @override
  Future<List<OrderEvent>> fetchEvents(int orderId) async {
    asked++;
    return [
      OrderEvent.fromJson({
        "id": 3, "description": "Pagamento: Por pagar → Pago", "source": "user",
        "created_at": "2026-11-22 14:05:00", "new_status": null, "user_name": "Sara",
      }),
      OrderEvent.fromJson({
        "id": 2, "description": "Pagamento confirmado na Etsy", "source": "sync",
        "created_at": "2026-11-21 09:00:00", "new_status": "in_production", "user_name": null,
      }),
      OrderEvent(id: 1, description: "Encomenda criada", source: "system", createdAt: _created),
    ];
  }
}

final _created = DateTime(2026, 11, 20, 8, 3);

void main() {
  test("quem fez: a pessoa, a Etsy, ou a app sozinha", () {
    OrderEvent e(String source, [String? name]) =>
        OrderEvent(id: 1, description: "x", source: source, createdAt: _created, userName: name);
    expect(e("user", "Sara").who, "Sara");
    expect(e("sync").who, "Etsy");
    expect(e("system").who, "Automático");
  });

  testWidgets("o detalhe da encomenda mostra o histórico, com data e quem", (tester) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = _WithHistory();
    final container = ProviderContainer(overrides: [
      demoModeProvider.overrideWith(_Demo.new),
      orderRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: const OrderDetailScreen(orderId: 1)),
    ));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text("Histórico"), findsOneWidget);
    expect(find.text("Pagamento: Por pagar → Pago"), findsOneWidget);
    expect(find.text("22/11/2026 14:05 · Sara"), findsOneWidget);
    expect(find.text("21/11/2026 09:00 · Etsy"), findsOneWidget);
    expect(find.text("20/11/2026 08:03 · Automático"), findsOneWidget);

    // quando as encomendas mudam (ex.: marcar como paga), o histórico volta a ser pedido
    final before = repo.asked;
    container.invalidate(ordersProvider);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(repo.asked, greaterThan(before));
  });
}
