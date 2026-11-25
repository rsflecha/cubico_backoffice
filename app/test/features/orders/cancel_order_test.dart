import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:cubico_backoffice/features/orders/data/demo_order_repository.dart';
import 'package:cubico_backoffice/features/orders/domain/order.dart';
import 'package:cubico_backoffice/features/orders/presentation/order_detail_screen.dart';
import 'package:cubico_backoffice/features/orders/presentation/orders_providers.dart';
import 'package:cubico_backoffice/features/production/presentation/production_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Cancelar uma encomenda feita por engano: no menu ⋮ do detalhe, com confirmação.
/// As tarefas dela que ainda não foram impressas saem do quadro da Produção.
///
/// Encomendas demo: #1041 (id 2) em produção, com a tarefa 1 a imprimir;
/// #1037 (id 4) pronta, com a tarefa 2 já concluída; #1036 (id 5) enviada.

class _Demo extends DemoModeNotifier {
  @override
  bool build() => true;
}

Future<DemoOrderRepository> _open(WidgetTester tester, int orderId) async {
  tester.view.physicalSize = const Size(1400, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final repo = DemoOrderRepository();
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

/// Os repositórios demo usam Future.delayed: deixar passar o tempo aos bocados.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 500));
  }
}

/// As tarefas que o quadro mostra. O provider vive no relógio falso do teste: fica a ouvir,
/// deixa passar o tempo, e lê o valor (com runAsync ficava pendurado).
Future<List<int>> _jobIds(WidgetTester tester) async {
  final container = ProviderScope.containerOf(tester.element(find.byType(OrderDetailScreen)));
  container.invalidate(printJobsProvider);
  final sub = container.listen(printJobsProvider, (_, _) {});
  await _settle(tester);
  final ids = container.read(printJobsProvider).requireValue.map((j) => j.id).toList();
  sub.close();
  return ids;
}

Future<Order> _saved(WidgetTester tester, DemoOrderRepository repo, int id) async =>
    (await tester.runAsync(repo.fetchAll))!.firstWhere((o) => o.id == id);

/// Abre o menu ⋮ e escolhe "Cancelar encomenda" (abre a confirmação).
Future<void> _askCancel(WidgetTester tester) async {
  await tester.tap(find.byTooltip("Mais opções"));
  await tester.pumpAndSettle();
  await tester.tap(find.text("Cancelar encomenda"));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets("«Não» deixa como estava; confirmar cancela e o menu desaparece", (tester) async {
    final repo = await _open(tester, 2);
    await _askCancel(tester);
    expect(find.text("Cancelar a encomenda #1041?"), findsOneWidget);
    await tester.tap(find.text("Não"));
    await _settle(tester);
    expect((await _saved(tester, repo, 2)).status, OrderStatus.inProduction);

    await _askCancel(tester);
    await tester.tap(find.widgetWithText(FilledButton, "Cancelar encomenda"));
    await _settle(tester);
    expect((await _saved(tester, repo, 2)).status, OrderStatus.cancelled);
    expect(find.text("Esta encomenda foi cancelada."), findsOneWidget);
    expect(find.byTooltip("Mais opções"), findsNothing, reason: "uma cancelada já não se cancela");
  });

  testWidgets("a tarefa por imprimir sai do quadro; as outras ficam", (tester) async {
    await _open(tester, 2);
    expect(await _jobIds(tester), containsAll([1, 2, 3, 4]));
    await _askCancel(tester);
    await tester.tap(find.widgetWithText(FilledButton, "Cancelar encomenda"));
    await _settle(tester);
    final ids = await _jobIds(tester);
    expect(ids, isNot(contains(1)), reason: "a peça da #1041 ainda não estava impressa");
    expect(ids, containsAll([2, 3, 4]), reason: "a de outra encomenda e as manuais ficam");
  });

  testWidgets("cancelar uma pronta: a tarefa já concluída continua (a peça foi impressa)", (tester) async {
    await _open(tester, 4);
    await _askCancel(tester);
    await tester.tap(find.widgetWithText(FilledButton, "Cancelar encomenda"));
    await _settle(tester);
    expect(await _jobIds(tester), contains(2));
  });

  testWidgets("uma encomenda já enviada não se cancela", (tester) async {
    await _open(tester, 5);
    expect(find.byTooltip("Mais opções"), findsNothing);
  });
}
