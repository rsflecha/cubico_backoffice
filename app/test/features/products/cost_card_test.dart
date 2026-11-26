import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:cubico_backoffice/features/products/domain/variant.dart';
import 'package:cubico_backoffice/features/products/presentation/widgets/cost_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// O modo demo ligado: o cartão usa os canais e custos de exemplo (Etsy com taxas, os outros sem).
class _Demo extends DemoModeNotifier {
  @override
  bool build() => true;
}

void main() {
  Future<void> show(WidgetTester tester, double width, {Widget card = const CostCard()}) async {
    tester.view.physicalSize = Size(width, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [demoModeProvider.overrideWith(_Demo.new)],
      child: MaterialApp(home: Scaffold(body: SingleChildScrollView(child: card))),
    ));
    // os repositórios demo fingem a demora da rede (Future.delayed): deixa passar esse tempo
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
  }

  testWidgets("sem escolher o canal: mostra a Etsy e a venda direta lado a lado", (tester) async {
    await show(tester, 900);
    // já não há botões de canal para escolher
    expect(find.byType(ChoiceChip), findsNothing);
    expect(find.text("Etsy"), findsOneWidget);
    expect(find.text("Venda direta"), findsOneWidget);
    expect(find.text("Instagram, Facebook, Pessoalmente"), findsOneWidget);
    // a venda direta não tem taxas; a Etsy tem
    expect(find.text("Taxas 0,00 €"), findsOneWidget);
    expect(find.textContaining("Taxas "), findsNWidgets(2));
    // lado a lado num ecrã largo
    final etsy = tester.getTopLeft(find.text("Etsy"));
    final direct = tester.getTopLeft(find.text("Venda direta"));
    expect(etsy.dy, direct.dy);
    expect(direct.dx, greaterThan(etsy.dx));
    expect(find.textContaining("na Etsy)"), findsOneWidget); // o sugerido conta com a Etsy
  });

  testWidgets("embalagem e componentes mostram o tamanho (para saber que caixa é)", (tester) async {
    await show(tester, 900);
    expect(find.widgetWithText(FilterChip, "Caixa 15 × 10 × 5 cm · 0,48 €"), findsOneWidget);
    expect(find.text("Papel de seda · 0,06 €"), findsOneWidget); // sem tamanho: só o nome
    expect(find.textContaining("Parafuso M3 10 mm · "), findsOneWidget);
  });

  testWidgets("no telemóvel: uma por baixo da outra", (tester) async {
    await show(tester, 400);
    final etsy = tester.getTopLeft(find.text("Etsy"));
    final direct = tester.getTopLeft(find.text("Venda direta"));
    expect(direct.dy, greaterThan(etsy.dy));
  });

  testWidgets("2 cores: pede as gramas da Cor 1 e da Cor 2, e grava o total e a Cor 2", (tester) async {
    final key = GlobalKey<CostCardState>();
    const base = Variant(id: 1, productId: 1, name: "", sku: "CD3-NAT-01", salePrice: 20,
        weightG: 105, gramsColor2: 25, filaments: [VariantFilament(filamentId: 1, grams: 105)]);
    await show(tester, 900, card: CostCard(key: key, variant: base, twoColors: true));
    // o total gravado (105) divide-se: Cor 1 = 80, Cor 2 = 25
    expect(find.widgetWithText(TextField, "Gramas · Cor 1"), findsOneWidget);
    expect(find.widgetWithText(TextField, "80"), findsOneWidget);
    expect(find.widgetWithText(TextField, "25"), findsOneWidget);
    expect(find.textContaining("Total: 105 g"), findsOneWidget);
    expect(key.currentState!.isChangedFrom(base), isFalse);

    await tester.enterText(find.widgetWithText(TextField, "25"), "40");
    await tester.pump();
    final saved = key.currentState!.applyTo(base);
    expect(saved.weightG, 120);
    expect(saved.gramsColor2, 40);
    expect(saved.filaments.single.grams, 120); // o custo continua a ser o total
    expect(key.currentState!.isChangedFrom(base), isTrue);
  });

  group("gramas com décimas (migração 014)", () {
    const base = Variant(id: 1, productId: 1, name: "", sku: "CD3-NAT-01", salePrice: 20,
        weightG: 100, filaments: [VariantFilament(filamentId: 1, grams: 100)]);

    Future<GlobalKey<CostCardState>> typeGrams(WidgetTester tester, String text) async {
      final key = GlobalKey<CostCardState>();
      await show(tester, 900, card: CostCard(key: key, variant: base));
      await tester.enterText(find.widgetWithText(TextField, "100"), text);
      await tester.pump();
      return key;
    }

    testWidgets("as gramas guardam as décimas: 86,4 não passa a 86", (tester) async {
      final key = await typeGrams(tester, "86,4");
      expect(key.currentState!.applyTo(base).filaments.single.grams, 86.4);
    });

    testWidgets("mais de 2 casas arredonda a 2, e depois de gravar não há alterações por gravar", (tester) async {
      final key = await typeGrams(tester, "86,456");
      final saved = key.currentState!.applyTo(base);
      expect(saved.filaments.single.grams, 86.46);
      expect(key.currentState!.isChangedFrom(saved), isFalse);
    });

    testWidgets("o peso dos portes arredonda para cima", (tester) async {
      final key = await typeGrams(tester, "100,4");
      expect(key.currentState!.applyTo(base).weightG, 101);
    });

    testWidgets("uma receita gravada com 86,4 g aparece 86,4 no campo", (tester) async {
      const saved = Variant(id: 1, productId: 1, name: "", sku: "CD3-NAT-01", salePrice: 20,
          weightG: 87, filaments: [VariantFilament(filamentId: 1, grams: 86.4)]);
      await show(tester, 900, card: const CostCard(variant: saved));
      expect(find.widgetWithText(TextField, "86,4"), findsOneWidget);
    });
  });

  testWidgets("1 cor: um só campo de gramas, e a Cor 2 fica a 0", (tester) async {
    final key = GlobalKey<CostCardState>();
    await show(tester, 900, card: CostCard(key: key));
    expect(find.widgetWithText(TextField, "Gramas"), findsOneWidget);
    expect(find.textContaining("Cor 2"), findsNothing);
  });
}
