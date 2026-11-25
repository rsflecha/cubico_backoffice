import 'package:cubico_backoffice/features/orders/presentation/widgets/product_picker_dialog.dart';
import 'package:cubico_backoffice/features/products/domain/product.dart';
import 'package:cubico_backoffice/features/products/domain/product_category.dart';
import 'package:cubico_backoffice/features/products/domain/variant.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

final _t = DateTime(2026, 11, 22);
Product _p(int id, String name, int? cat) =>
    Product(id: id, name: name, baseSku: "CD3-$id", categoryId: cat, createdAt: _t, updatedAt: _t);
Variant _v(int id, int product, String name, String sku) =>
    Variant(id: id, productId: product, name: name, sku: sku, salePrice: 10);

final _categories = [
  const ProductCategory(id: 1, name: "Suportes", sortOrder: 2),
  const ProductCategory(id: 2, name: "Natal", sortOrder: 1),
  const ProductCategory(id: 3, name: "Vazia", sortOrder: 3), // sem produtos: não leva botão
];
final _products = [
  _p(10, "Rena de Natal", 2),
  _p(11, "Árvore de Família", 2),
  _p(12, "Suporte F1", 1),
  _p(13, "Bola de Natal", 2), // modelo único
  _p(14, "Porta-chaves", null), // sem categoria
  _p(15, "Sem variantes", 1), // não se pode vender: não aparece
];
final _variants = [
  // criadas por esta ordem: 240 mm primeiro; pelo alfabeto ficava ao contrário
  _v(1, 10, "Rena 240mm", "CD3-DE2-03-01"),
  _v(2, 10, "Rena 95mm", "CD3-DE2-03-02"),
  _v(3, 11, "180mm", "CD3-DE2-02-01"),
  _v(4, 12, "Verstappen", "CD3-SUP-01-01"),
  _v(5, 12, "Hamilton", "CD3-SUP-01-02"),
  _v(6, 13, "", "CD3-DE2-01"),
  _v(7, 14, "Azul", "CD3-POR-01-01"),
];

/// Abre a janela; o que ela devolver vai para [picked].
Future<void> _open(WidgetTester tester, {Size size = const Size(900, 1400), List<Variant?>? picked}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    home: Builder(
      builder: (context) => TextButton(
        onPressed: () async {
          // (nunca "picked?.add(await …)": com picked null, o ?. saltava o showDialog)
          final v = await showDialog<Variant>(
          context: context,
          builder: (_) => ProductPickerDialog(products: _products, variants: _variants, categories: _categories),
          );
          picked?.add(v);
        },
        child: const Text("abrir"),
      ),
    ),
  ));
  await tester.tap(find.text("abrir"));
  await tester.pumpAndSettle();
}

/// O texto de cada linha, de cima para baixo (para conferir a ordem).
List<String> _order(WidgetTester tester, List<String> wanted) {
  final found = wanted.where((w) => find.text(w).evaluate().isNotEmpty).toList();
  found.sort((a, b) => tester.getTopLeft(find.text(a)).dy.compareTo(tester.getTopLeft(find.text(b)).dy));
  return found;
}

void main() {
  testWidgets("1.º passo: só os produtos, por categoria (pela ordem da categoria) e pelo nome",
      (tester) async {
    // alto o bastante para a lista caber toda (a ListView só constrói o que está à vista)
    await _open(tester, size: const Size(500, 2400));
    expect(
      _order(tester, [
        "NATAL", "Árvore de Família", "Bola de Natal", "Rena de Natal",
        "SUPORTES", "Suporte F1", "SEM CATEGORIA", "Porta-chaves",
      ]),
      [
        "NATAL", "Árvore de Família", "Bola de Natal", "Rena de Natal",
        "SUPORTES", "Suporte F1", "SEM CATEGORIA", "Porta-chaves",
      ],
    );
    // com várias variantes, ainda não estão à vista: só quantas são
    for (final v in ["Rena 240mm", "Rena 95mm", "Verstappen", "Hamilton"]) {
      expect(find.text(v), findsNothing, reason: v);
    }
    // com uma só variante com nome, mostra-se logo na linha (escolhe-se com um toque)
    expect(find.text("180mm"), findsOneWidget);
    expect(find.text("Azul"), findsOneWidget);
    expect(find.textContaining("1 variante"), findsNothing);
    expect(find.text("2 variantes"), findsNWidgets(2)); // Rena e Suporte F1
    expect(find.text("Sem variantes"), findsNothing);
    expect(find.text("Modelo único"), findsNothing, reason: "o modelo único é uma linha só, com o preço");
    expect(find.widgetWithText(ChoiceChip, "Vazia"), findsNothing);
  });

  testWidgets("os botões de categoria filtram; outra vez no mesmo volta a todas", (tester) async {
    await _open(tester);
    await tester.tap(find.widgetWithText(ChoiceChip, "Suportes"));
    await tester.pump();
    expect(find.text("Suporte F1"), findsOneWidget);
    expect(find.text("Rena de Natal"), findsNothing);
    await tester.tap(find.widgetWithText(ChoiceChip, "Suportes"));
    await tester.pump();
    expect(find.text("Rena de Natal"), findsOneWidget);
  });

  testWidgets("a procura ignora acentos e procura também na variante e no SKU", (tester) async {
    await _open(tester);
    await tester.enterText(find.byType(TextField), "arvore");
    await tester.pump();
    expect(find.text("Árvore de Família"), findsOneWidget);
    expect(find.text("Rena de Natal"), findsNothing);

    // pelo nome da variante: aparece o produto, e ao abri-lo só as variantes que batem certo
    await tester.enterText(find.byType(TextField), "hamil");
    await tester.pump();
    expect(find.text("Suporte F1"), findsOneWidget);
    expect(find.text("Rena de Natal"), findsNothing);
    await tester.tap(find.text("Suporte F1"));
    await tester.pumpAndSettle();
    expect(find.text("Hamilton"), findsOneWidget);
    expect(find.text("Verstappen"), findsNothing, reason: "só as variantes que batem certo");
    await tester.tap(find.byTooltip("Voltar aos produtos"));
    await tester.pumpAndSettle();

    // pelo SKU
    await tester.enterText(find.byType(TextField), "de2-03");
    await tester.pump();
    expect(find.text("Rena de Natal"), findsOneWidget);
    expect(find.text("Suporte F1"), findsNothing);

    await tester.enterText(find.byType(TextField), "xyz");
    await tester.pump();
    expect(find.text("Nenhum produto encontrado."), findsOneWidget);
  });

  testWidgets("escolher uma variante, ou um modelo único, devolve-a; fechar devolve nada", (tester) async {
    final picked = <Variant?>[];
    await _open(tester, picked: picked);
    await tester.tap(find.text("Suporte F1"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Hamilton"));
    await tester.pumpAndSettle();
    expect(find.text("Escolher produto"), findsNothing);

    await tester.tap(find.text("abrir"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Bola de Natal"));
    await tester.pumpAndSettle();

    // uma só variante com nome: um toque e está escolhida
    await tester.tap(find.text("abrir"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Árvore de Família"));
    await tester.pumpAndSettle();
    expect(find.text("Escolher produto"), findsNothing);

    await tester.tap(find.text("abrir"));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip("Fechar"));
    await tester.pumpAndSettle();

    expect(picked.map((v) => v?.id), [5, 6, 3, null]);
  });

  testWidgets("2.º passo: as variantes do produto pelo nome, números pelo valor; voltar mantém a categoria",
      (tester) async {
    await _open(tester);
    await tester.tap(find.widgetWithText(ChoiceChip, "Natal"));
    await tester.pump();
    await tester.tap(find.text("Rena de Natal"));
    await tester.pumpAndSettle();
    // só as da Rena: 95 antes de 240 (pela criação vinha 240 primeiro; letra a letra também,
    // porque "2" < "9")
    expect(_order(tester, ["Rena 240mm", "Rena 95mm"]), ["Rena 95mm", "Rena 240mm"]);
    expect(find.text("Hamilton"), findsNothing);
    expect(find.text("CD3-DE2-03-01"), findsOneWidget);
    expect(find.text("Suporte F1"), findsNothing);

    await tester.tap(find.byTooltip("Voltar aos produtos"));
    await tester.pumpAndSettle();
    expect(find.text("Rena de Natal"), findsOneWidget);
    expect(find.text("Suporte F1"), findsNothing, reason: "a categoria Natal continua escolhida");
    expect(tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, "Natal")).selected, isTrue);
  });

  testWidgets("no telemóvel ocupa o ecrã todo", (tester) async {
    await _open(tester, size: const Size(390, 844));
    expect(find.byType(Dialog), findsOneWidget);
    expect(tester.getSize(find.byType(Dialog)).width, 390);
  });
}
