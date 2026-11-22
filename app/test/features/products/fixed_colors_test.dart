import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:cubico_backoffice/features/costs/domain/cost_calculator.dart';
import 'package:cubico_backoffice/features/costs/domain/filament.dart';
import 'package:cubico_backoffice/features/orders/data/demo_order_repository.dart';
import 'package:cubico_backoffice/features/orders/domain/order.dart';
import 'package:cubico_backoffice/features/orders/presentation/create_order_screen.dart';
import 'package:cubico_backoffice/features/orders/presentation/orders_providers.dart';
import 'package:cubico_backoffice/features/products/data/demo_product_repository.dart';
import 'package:cubico_backoffice/features/products/domain/product.dart';
import 'package:cubico_backoffice/features/products/domain/variant.dart';
import 'package:cubico_backoffice/features/products/presentation/products_providers.dart';
import 'package:cubico_backoffice/features/products/presentation/widgets/cost_card.dart';
import 'package:cubico_backoffice/features/auth/domain/app_user.dart';
import 'package:cubico_backoffice/features/products/presentation/product_form_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Cores fixas em cada variante (o suporte F1: a Red Bull leva branco, preto, vermelho e amarelo):
/// a receita tem várias cores com as gramas de cada uma, o custo é exato cor a cor,
/// e a encomenda não pede cor.

class _Demo extends DemoModeNotifier {
  @override
  bool build() => true;
}

class _Admin extends SessionNotifier {
  @override
  AppUser? build() => const AppUser(id: 1, name: "Rui", email: "rui@teste.pt", role: UserRole.admin);
}

class _Spy extends DemoOrderRepository {
  Order? sent;

  @override
  Future<Order> create(Order draft) {
    sent = draft;
    return super.create(draft);
  }
}

/// Os produtos demo, todos com as cores fixas na variante.
class _Fixed extends DemoProductRepository {
  _Fixed() : super(categoryCode: (_) async => null);

  @override
  Future<List<Product>> fetchAll() async => [
        for (final p in await super.fetchAll()) p.copyWith(colorsPerPiece: 0, colorIds: [1]),
      ];
}

Filament _f(int id, String name, double paid) => Filament(
    id: id, material: "PLA", brand: "Bambu", colorName: name, spoolWeightG: 1000,
    listPrice: paid, paidPrice: paid);

void main() {
  test("o custo sem cor escolhida é a receita, cor a cor, cada uma ao preço dela", () {
    const calc = CostCalculator();
    final filaments = [_f(1, "Branco", 20), _f(2, "Preto", 10), _f(3, "Vermelho", 30), _f(4, "Amarelo", 40)];
    const redBull = Variant(id: 1, productId: 1, name: "Red Bull", sku: "X", salePrice: 30, filaments: [
      VariantFilament(filamentId: 1, grams: 40),
      VariantFilament(filamentId: 2, grams: 20),
      VariantFilament(filamentId: 3, grams: 10),
      VariantFilament(filamentId: 4, grams: 5),
    ]);
    // 40 g × 20 €/kg + 20 × 10 + 10 × 30 + 5 × 40 = 0,80 + 0,20 + 0,30 + 0,20 = 1,50 €
    expect(
      calc.variantProductionCost(variant: redBull, filaments: filaments, components: const [], costPerHour: 0),
      closeTo(1.50, 0.0001),
    );
  });

  testWidgets("o cartão: uma linha por cor, juntar outra, e grava a receita toda", (tester) async {
    tester.view.physicalSize = const Size(900, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final key = GlobalKey<CostCardState>();
    const variant = Variant(id: 9, productId: 1, name: "Red Bull", sku: "CD3-SUP-01-03", salePrice: 30,
        printTimeMin: 120, filaments: [VariantFilament(filamentId: 1, grams: 40), VariantFilament(filamentId: 3, grams: 20)]);
    await tester.pumpWidget(ProviderScope(
      overrides: [demoModeProvider.overrideWith(_Demo.new)],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: CostCard(key: key, variant: variant, fixedColors: true)),
        ),
      ),
    ));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.text("Cores desta variante"), findsOneWidget);
    expect(find.text("Black Basic · PLA"), findsOneWidget);
    expect(find.text("Orange Basic · PLA"), findsOneWidget);
    expect(find.text("Filamento (2 cores)"), findsOneWidget);

    await tester.tap(find.text("Adicionar cor"));
    await tester.pump();
    expect(key.currentState!.problem(), isNull, reason: "uma linha vazia não conta");
    await tester.enterText(find.widgetWithText(TextField, "Gramas").last, "5");
    await tester.pump();
    expect(key.currentState!.problem(), "Escolhe o filamento de cada cor da receita.");
    await tester.tap(find.byType(DropdownButtonFormField<int>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text("Translucent · PETG").last);
    await tester.pumpAndSettle();

    final saved = key.currentState!.applyTo(variant);
    expect({for (final f in saved.filaments) f.filamentId: f.grams}, {1: 40, 3: 20, 2: 5});
    expect(saved.weightG, 65);
    expect(saved.gramsColor2, 0);
    expect(key.currentState!.problem(), isNull);
    expect(find.text("Total: 65 g (o peso da peça, para os portes)"), findsOneWidget);
  });

  testWidgets("a encomenda não pede cor: mostra as da variante, e o custo é o da receita", (tester) async {
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
        productRepositoryProvider.overrideWithValue(_Fixed()),
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pump(const Duration(seconds: 2));

    await tester.enterText(find.widgetWithText(TextField, "Nome ou referência"), "Ana");
    await tester.tap(find.text("Adicionar produto do catálogo"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Preto mate"));
    await tester.pumpAndSettle();

    expect(find.text("Cor"), findsNothing);
    expect(find.text("Escolher cor"), findsNothing);
    expect(find.textContaining("Cores: "), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, "Criar encomenda"));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    final line = spy.sent!.lines.single;
    expect(line.filamentId, isNull, reason: "a cor está na receita");
    expect(line.customization, isNull);
    expect(line.unitCost, greaterThan(0));
  });

  testWidgets("na ficha: sem «Cores disponíveis», e gravar não mexe na receita das outras variantes",
      (tester) async {
    tester.view.physicalSize = const Size(1400, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final container = ProviderContainer(overrides: [
      demoModeProvider.overrideWith(_Demo.new),
      sessionProvider.overrideWith(_Admin.new),
      productRepositoryProvider.overrideWithValue(_Fixed()),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: ProductFormScreen(productId: 1)),
    ));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(find.text("Cores disponíveis"), findsNothing);
    expect(find.text("Cores desta variante"), findsOneWidget);

    // a 1.ª variante fica com duas cores; a 2.ª (Translucent, 120 g) não se toca
    await tester.tap(find.text("Adicionar cor"));
    await tester.pump();
    await tester.tap(find.byType(DropdownButtonFormField<int>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text("Orange Basic · PLA").last);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, "Gramas").last, "15");
    await tester.pump();
    await tester.tap(find.text("Guardar"));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    final variants = (await tester.runAsync(() => container.read(variantRepositoryProvider).fetchByProduct(1)))!
      ..sort((a, b) => a.id.compareTo(b.id));
    expect({for (final f in variants[0].filaments) f.filamentId: f.grams}, {1: 120, 3: 15});
    expect({for (final f in variants[1].filaments) f.filamentId: f.grams}, {2: 120},
        reason: "antes, gravar o produto passava as outras variantes para uma só cor");
  });
}
