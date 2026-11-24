import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:cubico_backoffice/features/orders/data/demo_order_repository.dart';
import 'package:cubico_backoffice/features/orders/domain/order.dart';
import 'package:cubico_backoffice/features/orders/presentation/order_detail_screen.dart';
import 'package:cubico_backoffice/features/orders/presentation/orders_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Pagar depois: uma encomenda criada "Por pagar" passa a paga no detalhe,
/// e ao entregar uma por pagar pergunta-se primeiro se já pagou (antes ficava esquecida).

class _Demo extends DemoModeNotifier {
  @override
  bool build() => true;
}

/// As encomendas demo; a 1037 (Pedro, por pagar) no estado que o teste quiser,
/// e a 1042 por pagar (está pendente: paga, vai para produção).
class _Orders extends DemoOrderRepository {
  _Orders(this.status1037);
  final OrderStatus status1037;
  var _ready = false;

  @override
  Future<List<Order>> fetchAll() async {
    if (!_ready) {
      _ready = true;
      for (final o in await super.fetchAll()) {
        if (o.id == 4) await super.update(o.copyWith(status: status1037));
        if (o.id == 1) await super.update(o.copyWith(paymentStatus: PaymentStatus.unpaid));
      }
    }
    return super.fetchAll();
  }
}

Future<_Orders> _open(WidgetTester tester, int orderId, {OrderStatus status1037 = OrderStatus.ready}) async {
  tester.view.physicalSize = const Size(1400, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final repo = _Orders(status1037);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      demoModeProvider.overrideWith(_Demo.new),
      orderRepositoryProvider.overrideWithValue(repo),
    ],
    child: MaterialApp(home: OrderDetailScreen(orderId: orderId)),
  ));
  await _settle(tester);
  return repo;
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 500));
  }
}

Future<Order> _saved(WidgetTester tester, _Orders repo, int id) async =>
    (await tester.runAsync(repo.fetchAll))!.firstWhere((o) => o.id == id);

void main() {
  testWidgets("por pagar: «Marcar como pago» pede o método e grava", (tester) async {
    final repo = await _open(tester, 4);
    expect(find.text("Por pagar"), findsWidgets);
    await tester.tap(find.text("Marcar como pago"));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Transferência").last);
    await tester.pumpAndSettle();
    await tester.tap(find.text("Confirmar"));
    await _settle(tester);

    final o = await _saved(tester, repo, 4);
    expect(o.paymentStatus, PaymentStatus.paid);
    expect(o.paymentMethod, "Transferência");
    expect(o.status, OrderStatus.ready, reason: "pagar não muda o estado");
    expect(find.text("Marcar como pago"), findsNothing);
  });

  testWidgets("pendente e por pagar: ao pagar vai sozinha para produção", (tester) async {
    final repo = await _open(tester, 1);
    await tester.tap(find.text("Marcar como pago"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Confirmar"));
    await _settle(tester);
    final o = await _saved(tester, repo, 1);
    expect(o.paymentStatus, PaymentStatus.paid);
    expect(o.status, OrderStatus.inProduction);
  });

  testWidgets("entregar uma por pagar: «Já pagou» entrega e marca como pago", (tester) async {
    final repo = await _open(tester, 4, status1037: OrderStatus.shipped);
    await tester.tap(find.text("Marcar como entregue"));
    await tester.pumpAndSettle();
    expect(find.text("Ainda está por pagar"), findsOneWidget);
    await tester.tap(find.text("Já pagou: entregar"));
    await _settle(tester);
    final o = await _saved(tester, repo, 4);
    expect(o.status, OrderStatus.delivered);
    expect(o.paymentStatus, PaymentStatus.paid);
    expect(o.paymentMethod, "Dinheiro", reason: "fica o método que já tinha");
  });

  testWidgets("entregar uma por pagar: «Entregar sem pagamento» e «Cancelar»", (tester) async {
    final repo = await _open(tester, 4, status1037: OrderStatus.shipped);
    await tester.tap(find.text("Marcar como entregue"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Cancelar"));
    await _settle(tester);
    expect((await _saved(tester, repo, 4)).status, OrderStatus.shipped, reason: "cancelar não muda nada");

    await tester.tap(find.text("Marcar como entregue"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Entregar sem pagamento"));
    await _settle(tester);
    final o = await _saved(tester, repo, 4);
    expect(o.status, OrderStatus.delivered);
    expect(o.paymentStatus, PaymentStatus.unpaid);
    expect(find.text("Marcar como pago"), findsOneWidget, reason: "dá para marcar depois");
  });

  testWidgets("uma paga entrega sem perguntar", (tester) async {
    final repo = await _open(tester, 5); // 1040: enviada e paga
    expect(find.text("Marcar como pago"), findsNothing);
    await tester.tap(find.text("Marcar como entregue"));
    await _settle(tester);
    expect(find.text("Ainda está por pagar"), findsNothing);
    expect((await _saved(tester, repo, 5)).status, OrderStatus.delivered);
  });
}
