import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:cubico_backoffice/features/orders/data/demo_order_repository.dart';
import 'package:cubico_backoffice/features/orders/domain/order.dart';
import 'package:cubico_backoffice/features/orders/presentation/create_order_screen.dart';
import 'package:cubico_backoffice/features/orders/presentation/orders_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// O modo demo ligado: produtos, variantes e filamentos de exemplo.
class _Demo extends DemoModeNotifier {
  @override
  bool build() => true;
}

/// O repositório demo, mas guarda o rascunho que o ecrã mandou gravar.
class _Spy extends DemoOrderRepository {
  Order? sent;

  @override
  Future<Order> create(Order draft) {
    sent = draft;
    return super.create(draft);
  }
}

void main() {
  testWidgets("a cor escolhida vai na personalização e muda o custo da linha", (tester) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final spy = _Spy();
    final router = GoRouter(routes: [
      GoRoute(path: "/", builder: (_, _) => const CreateOrderScreen()),
      GoRoute(path: "/orders/:id", builder: (_, _) => const Text("detalhe")),
    ]);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        demoModeProvider.overrideWith(_Demo.new),
        orderRepositoryProvider.overrideWithValue(spy),
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pump(const Duration(seconds: 2)); // os repositórios demo fingem a demora da rede

    await tester.enterText(find.widgetWithText(TextField, "Nome ou referência"), "Ana");

    // a mesma variante duas vezes: uma com a cor da receita, outra em Orange Basic
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text("Adicionar produto do catálogo"));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SimpleDialogOption).first);
      await tester.pumpAndSettle();
    }

    // por omissão: a cor da receita, com o nome dela
    expect(find.text("A da receita (Black Basic)"), findsNWidgets(2));

    await tester.tap(find.text("A da receita (Black Basic)").last);
    await tester.pumpAndSettle();
    await tester.tap(find.text("Orange Basic · PLA").last);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, "Personalização (opcional)").last, "CARLA");
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, "Criar encomenda"));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    final lines = spy.sent!.lines;
    expect(lines, hasLength(2));
    // a primeira fica como estava
    expect(lines[0].filamentId, isNull);
    expect(lines[0].customization, isNull);
    // a segunda leva a cor à frente do texto, e o id para a API fazer a conta
    expect(lines[1].filamentId, 3);
    expect(lines[1].customization, "Cor: Orange Basic · CARLA");
    // 120 g: Black Basic a 13,43 €/kg → Orange Basic a 11,88 €/kg = 0,186 € mais barato
    expect(lines[1].unitCost - lines[0].unitCost, closeTo(-0.186, 0.0001));
    // e o pedido para a API leva o filament_id
    expect(lines[1].toJson()["filament_id"], 3);
  });
}
