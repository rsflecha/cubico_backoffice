import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
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
  Future<void> show(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [demoModeProvider.overrideWith(_Demo.new)],
      child: const MaterialApp(home: Scaffold(body: SingleChildScrollView(child: CostCard()))),
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

  testWidgets("no telemóvel: uma por baixo da outra", (tester) async {
    await show(tester, 400);
    final etsy = tester.getTopLeft(find.text("Etsy"));
    final direct = tester.getTopLeft(find.text("Venda direta"));
    expect(direct.dy, greaterThan(etsy.dy));
  });
}
