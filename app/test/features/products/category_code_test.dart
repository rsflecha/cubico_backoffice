import 'package:cubico_backoffice/core/api/api_exception.dart';
import 'package:cubico_backoffice/features/products/data/demo_product_category_repository.dart';
import 'package:cubico_backoffice/features/products/presentation/widgets/category_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Mudar o código de uma categoria ao editar (só enquanto não tem produtos).
void main() {
  group("repositório demo", () {
    test("o código muda e fica em maiúsculas", () async {
      final repo = DemoProductCategoryRepository();
      final flexi = (await repo.fetchAll()).firstWhere((c) => c.code == "FLE");
      final saved = await repo.update(flexi.copyWith(code: "flx"));
      expect(saved.code, "FLX");
    });

    test("código de outra categoria, GER ou inválido: falha", () async {
      final repo = DemoProductCategoryRepository();
      final flexi = (await repo.fetchAll()).firstWhere((c) => c.code == "FLE");
      for (final bad in ["SEC", "GER", "A", "COM ESPACO"]) {
        expect(() => repo.update(flexi.copyWith(code: bad)), throwsA(isA<ApiException>()), reason: bad);
      }
    });

    test("só mudar o nome não esbarra no próprio código", () async {
      final repo = DemoProductCategoryRepository();
      final flexi = (await repo.fetchAll()).firstWhere((c) => c.code == "FLE");
      final saved = await repo.update(flexi.copyWith(name: "Flexíveis"));
      expect(saved.code, "FLE");
    });
  });

  group("janela de edição", () {
    Future<void> open(WidgetTester tester, {Iterable<String>? taken}) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CategoryDialog(
            title: "Editar categoria",
            initialName: "Decoração Natal",
            initialCode: "DE2",
            takenCodes: taken,
          ),
        ),
      ));
    }

    testWidgets("sem produtos: mostra o código atual e não o muda com o nome", (tester) async {
      await open(tester, taken: ["DEC", "VAS"]);
      expect(find.text("DE2"), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, "Natal");
      await tester.pump();
      expect(find.text("DE2"), findsOneWidget); // não passou a NAT sozinho
    });

    testWidgets("código já usado por outra: aviso", (tester) async {
      await open(tester, taken: ["DEC", "VAS"]);
      await tester.enterText(find.byType(TextField).last, "DEC");
      await tester.pump();
      expect(find.text("Já há uma categoria com DEC."), findsOneWidget);
    });

    testWidgets("com produtos: o campo do código não aparece", (tester) async {
      await open(tester);
      expect(find.text("Código no SKU"), findsNothing);
    });
  });
}
