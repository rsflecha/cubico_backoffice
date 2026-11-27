import 'package:cubico_backoffice/features/auth/domain/app_user.dart';
import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:cubico_backoffice/features/costs/data/demo_filament_repository.dart';
import 'package:cubico_backoffice/features/costs/domain/filament.dart';
import 'package:cubico_backoffice/features/costs/presentation/costs_providers.dart';
import 'package:cubico_backoffice/features/stock/data/demo_stock_repository.dart';
import 'package:cubico_backoffice/features/stock/presentation/filament_stock_screen.dart';
import 'package:cubico_backoffice/features/stock/presentation/stock_providers.dart';
import 'package:cubico_backoffice/features/stock/presentation/stock_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Os ecrãs do Stock em modo demo: lista, histórico, compra e acerto pesando.

class _Demo extends DemoModeNotifier {
  @override
  bool build() => true;
}

class _Admin extends SessionNotifier {
  @override
  AppUser? build() => const AppUser(id: 1, name: "Rui", email: "rui@teste.pt", role: UserRole.admin);
}

class _Staff extends SessionNotifier {
  @override
  AppUser? build() => const AppUser(id: 2, name: "Sara", email: "sara@teste.pt", role: UserRole.staff);
}

/// Abre [home] com o utilizador pedido; devolve o container para espreitar o estado.
Future<ProviderContainer> _open(WidgetTester tester, Widget home, {bool admin = true, List<Override> extra = const []}) async {
  tester.view.physicalSize = const Size(1400, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        demoModeProvider.overrideWith(_Demo.new),
        sessionProvider.overrideWith(admin ? _Admin.new : _Staff.new),
        ...extra,
      ],
      child: MaterialApp(home: home),
    ),
  );
  await _settle(tester);
  return ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
}

/// Passos curtos em vez de pumpAndSettle: o spinner de "a gravar" nunca assenta.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 400));
  }
}

Finder _field(String label) => find.byWidgetPredicate((w) => w is TextField && w.decoration?.labelText == label);

Future<void> _type(WidgetTester tester, String label, String text) async {
  await tester.enterText(_field(label), text);
  await tester.pump();
}

/// Escolhe no menu da janela de compra o filamento [label] (por omissão o primeiro: id 1).
Future<void> _pickFilament(WidgetTester tester, {String label = "PLA Black Basic · Bambu Lab"}) async {
  await tester.tap(find.byType(DropdownButtonFormField<int>));
  await _settle(tester);
  await tester.tap(find.text(label).last);
  await _settle(tester);
}

void main() {
  fixRound1();
  testWidgets("lista: cada filamento com rolos e gramas; o administrador vê «Registar compra»", (tester) async {
    await _open(tester, const StockScreen());
    expect(find.text("PLA Black Basic · Bambu Lab"), findsOneWidget);
    expect(find.text("PETG Translucent · Bambu Lab"), findsOneWidget);
    expect(find.text("PLA Orange Basic · Bambu Lab"), findsOneWidget);
    expect(find.textContaining("1,0 rolos"), findsNWidgets(3));
    expect(find.textContaining("1000 g"), findsNWidgets(3));
    expect(find.text("Registar compra"), findsOneWidget);
  });

  testWidgets("lista: o colaborador não vê «Registar compra»", (tester) async {
    await _open(tester, const StockScreen(), admin: false);
    expect(find.text("PLA Black Basic · Bambu Lab"), findsOneWidget);
    expect(find.text("Registar compra"), findsNothing);
  });

  testWidgets("histórico: o colaborador não vê «Acertar» nem nenhum €", (tester) async {
    await _open(tester, const FilamentStockScreen(filamentId: 1), admin: false);
    expect(find.textContaining("Compra"), findsOneWidget); // o histórico carregou
    expect(find.text("Acertar"), findsNothing);
    expect(find.textContaining("€"), findsNothing);
  });

  testWidgets("histórico: o administrador vê «Acertar» e o preço por rolo", (tester) async {
    await _open(tester, const FilamentStockScreen(filamentId: 1));
    expect(find.text("Acertar"), findsOneWidget);
    expect(find.textContaining("€/rolo"), findsOneWidget);
  });

  testWidgets("acerto com a tara: mostra o total real e a diferença", (tester) async {
    await _open(tester, const FilamentStockScreen(filamentId: 1));
    await tester.tap(find.text("Acertar"));
    await _settle(tester);
    await _type(tester, "Rolos fechados", "2");
    await _type(tester, "Rolo aberto 1 (peso na balança, g)", "712");
    expect(find.text("Total real: 2462 g"), findsOneWidget);
    expect(find.text("Diferença: +1462 g"), findsOneWidget);
  });

  testWidgets("acerto: rolo aberto mais leve que o carretel não se grava", (tester) async {
    await _open(tester, const FilamentStockScreen(filamentId: 1));
    await tester.tap(find.text("Acertar"));
    await _settle(tester);
    await _type(tester, "Rolo aberto 1 (peso na balança, g)", "240");
    expect(find.textContaining("não pode pesar menos do que o carretel"), findsOneWidget);
    final save = tester.widget<FilledButton>(find.widgetWithText(FilledButton, "Gravar"));
    expect(save.onPressed, isNull);
  });

  testWidgets("acerto sem tara: não há linhas de rolo aberto e diz onde preencher", (tester) async {
    await _open(tester, const FilamentStockScreen(filamentId: 2));
    await tester.tap(find.text("Acertar"));
    await _settle(tester);
    expect(_field("Rolo aberto 1 (peso na balança, g)"), findsNothing);
    expect(find.textContaining("Custos e preços"), findsOneWidget);
  });

  testWidgets("acerto gravado entra no histórico", (tester) async {
    final container = await _open(tester, const FilamentStockScreen(filamentId: 1));
    await tester.tap(find.text("Acertar"));
    await _settle(tester);
    await _type(tester, "Rolos fechados", "2");
    await _type(tester, "Rolo aberto 1 (peso na balança, g)", "712");
    await tester.tap(find.text("Gravar"));
    await _settle(tester);
    final movements = (await tester.runAsync(() => container.read(stockRepositoryProvider).fetchMovements(1)))!;
    expect(movements.length, 2);
    expect(movements.first.grams, 1462);
    expect(find.text("Acerto (pesado)"), findsOneWidget);
  });

  testWidgets("compra: dois toques seguidos em «Gravar» gravam um só movimento", (tester) async {
    final container = await _open(tester, const StockScreen());
    await tester.tap(find.text("Registar compra"));
    await _settle(tester);
    await _type(tester, "Rolos", "2");
    await _pickFilament(tester);
    await _type(tester, "Preço pago por rolo", "13,43");
    await _type(tester, "Portes", "0");
    await tester.tap(find.text("Gravar"));
    await tester.tap(find.text("Gravar"));
    await _settle(tester);
    final movements = (await tester.runAsync(() => container.read(stockRepositoryProvider).fetchMovements(1)))!;
    expect(movements.length, 2); // a compra inicial do demo + esta
    expect(find.text("Gravar"), findsNothing); // a janela fechou
  });

  testWidgets("compra: recusa rolos a 0 ou acima de 255 e preços negativos ou a zero", (tester) async {
    final container = await _open(tester, const StockScreen());
    await tester.tap(find.text("Registar compra"));
    await _settle(tester);
    await _pickFilament(tester);
    for (final bad in [
      ["0", "10", "0"],
      ["256", "10", "0"],
      ["1", "-5", "0"],
      ["1", "10", "-1"],
      ["1", "0", "0"],
      ["1", "", "0"],
    ]) {
      await _type(tester, "Rolos", bad[0]);
      await _type(tester, "Preço pago por rolo", bad[1]);
      await _type(tester, "Portes", bad[2]);
      await tester.tap(find.text("Gravar"));
      await _settle(tester);
      expect(find.text("Gravar"), findsOneWidget, reason: "$bad devia ser recusado");
    }
    expect(find.textContaining("maior que zero"), findsOneWidget); // o último caso: preço vazio
    final movements = (await tester.runAsync(() => container.read(stockRepositoryProvider).fetchMovements(1)))!;
    expect(movements.length, 1);
  });

  testWidgets("compra: sem escolher o filamento mostra «Escolhe o filamento.» e não grava", (tester) async {
    final container = await _open(tester, const StockScreen());
    await tester.tap(find.text("Registar compra"));
    await _settle(tester);
    await _type(tester, "Rolos", "2");
    await _type(tester, "Preço pago por rolo", "15,00");
    await tester.tap(find.text("Gravar"));
    await _settle(tester);
    expect(find.text("Escolhe o filamento."), findsOneWidget);
    for (final id in [1, 2, 3]) {
      final movements = (await tester.runAsync(() => container.read(stockRepositoryProvider).fetchMovements(id)))!;
      expect(movements.length, 1, reason: "filamento $id não devia ter compras novas");
    }
  });

  testWidgets("compra de 2 rolos a 15,00 € por rolo: grava 15.0 por rolo e o histórico mostra «15,00 €/rolo»", (tester) async {
    final repo = DemoStockRepository(DemoFilamentRepository());
    await _open(tester, const StockScreen(), extra: [stockRepositoryProvider.overrideWithValue(repo)]);
    await tester.tap(find.text("Registar compra"));
    await _settle(tester);
    await _pickFilament(tester);
    await _type(tester, "Rolos", "2");
    await _type(tester, "Preço pago por rolo", "15,00");
    expect(find.textContaining("Total: 30,00"), findsOneWidget); // preço × rolos
    await tester.tap(find.text("Gravar"));
    await _settle(tester);
    final movements = (await tester.runAsync(() => repo.fetchMovements(1)))!;
    expect(movements.first.paidPrice, 15.0);
    expect(movements.first.spools, 2);

    await _open(tester, const FilamentStockScreen(filamentId: 1), extra: [stockRepositoryProvider.overrideWithValue(repo)]);
    expect(find.textContaining("15,00 €/rolo"), findsOneWidget);
  });

  testWidgets("compra: os filamentos são relidos (o preço novo chega a Custos e preços)", (tester) async {
    final filaments = DemoFilamentRepository();
    final repo = DemoStockRepository(filaments);
    final container = await _open(tester, const StockScreen(), extra: [
      filamentRepositoryProvider.overrideWithValue(filaments),
      stockRepositoryProvider.overrideWithValue(repo),
    ]);
    expect(container.read(filamentsProvider).requireValue.first.paidPrice, 13.43);
    await tester.tap(find.text("Registar compra"));
    await _settle(tester);
    await _pickFilament(tester);
    await _type(tester, "Rolos", "2");
    await _type(tester, "Preço pago por rolo", "15,00");
    await _type(tester, "Portes", "4,90");
    await tester.tap(find.text("Gravar"));
    await _settle(tester);
    final f = container.read(filamentsProvider).requireValue.first;
    expect(f.paidPrice, 15.0);
    expect(f.shippingCost, 4.9);
    expect(f.spoolsInOrder, 2);
  });
}

/// Fix round 1: erros de carregamento e lista de filamentos vazia.
void fixRound1() {
  testWidgets("histórico: filamentos que falham mostram erro com «Tentar outra vez»", (tester) async {
    await _open(
      tester,
      const FilamentStockScreen(filamentId: 1),
      extra: [filamentsProvider.overrideWith((ref) async => throw Exception("sem rede"))],
    );
    expect(find.textContaining("Não foi possível carregar o stock"), findsOneWidget);
    expect(find.text("Tentar outra vez"), findsOneWidget);
  });

  testWidgets("histórico: stock que falha mostra erro com «Tentar outra vez»", (tester) async {
    await _open(
      tester,
      const FilamentStockScreen(filamentId: 1),
      extra: [filamentStockProvider.overrideWith((ref) async => throw Exception("sem rede"))],
    );
    expect(find.textContaining("Não foi possível carregar o stock"), findsOneWidget);
    expect(find.text("Tentar outra vez"), findsOneWidget);
  });

  testWidgets("lista sem filamentos: «Registar compra» fica desligado e não rebenta", (tester) async {
    await _open(
      tester,
      const StockScreen(),
      extra: [filamentsProvider.overrideWith((ref) async => <Filament>[])],
    );
    final button = tester.widget<FilledButton>(find.byWidgetPredicate((w) => w is FilledButton));
    expect(button.onPressed, isNull);
    expect(tester.takeException(), isNull);
  });
}
