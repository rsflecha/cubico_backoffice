import 'dart:convert';

import 'package:cubico_backoffice/features/auth/domain/app_user.dart';
import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:cubico_backoffice/features/orders/presentation/create_order_screen.dart';
import 'package:cubico_backoffice/features/products/presentation/product_form_screen.dart';
import 'package:cubico_backoffice/features/products/presentation/products_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// O caminho que faltava testar: criar um produto com a receita e o preço,
/// e ver esse preço chegar sozinho à encomenda. Tudo no modo demo (sem servidor).

class _Demo extends DemoModeNotifier {
  @override
  bool build() => true;
}

class _Admin extends SessionNotifier {
  @override
  AppUser? build() => const AppUser(id: 1, name: "Rui", email: "rui@teste.pt", role: UserRole.admin);
}

// uma imagem PNG de 1×1 pixel, para a foto obrigatória
final _png = base64Decode(
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==");

void main() {
  late GoRouter router;

  Future<void> start(WidgetTester tester, String location) async {
    tester.view.physicalSize = const Size(1400, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    router = GoRouter(initialLocation: location, routes: [
      GoRoute(path: "/", builder: (_, _) => const Text("lista"), routes: [
        GoRoute(path: "new", builder: (_, _) => ProductFormScreen(initialPhoto: _png)),
        GoRoute(
          path: "edit/:id",
          builder: (_, s) => ProductFormScreen(productId: int.parse(s.pathParameters["id"]!)),
        ),
        GoRoute(path: "order", builder: (_, _) => const CreateOrderScreen()),
      ]),
    ]);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        demoModeProvider.overrideWith(_Demo.new),
        sessionProvider.overrideWith(_Admin.new),
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    await settle(tester);
  }

  testWidgets("produto novo: um Guardar grava a receita e o preço, e a encomenda já vem com eles",
      (tester) async {
    await start(tester, "/new");

    // os mesmos campos de editar, desde o início, e vazios (nada de valores de exemplo)
    expect(find.text("Preço de venda"), findsOneWidget);
    expect(find.text("Guardar variante"), findsNothing);
    expect(find.text("Guardar"), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, "Nome"), "Bola teste");
    await tester.tap(find.text("Categoria"));
    await settle(tester);
    await tester.tap(find.text("Brindes").last);
    await settle(tester);
    // cores disponíveis: só Orange Basic
    await tester.tap(find.widgetWithText(FilterChip, "Orange Basic · PLA"));
    await tester.pump();

    // sem receita nem preço: não grava, e diz o que falta
    await tester.tap(find.text("Guardar"));
    await settle(tester);
    expect(find.text("Escreve as gramas de filamento."), findsOneWidget);
    final container = ProviderScope.containerOf(tester.element(find.byType(ProductFormScreen)));
    expect((await tester.runAsync(() => container.read(productRepositoryProvider).fetchAll()))!
        .where((p) => p.name == "Bola teste"), isEmpty);

    await tester.enterText(find.widgetWithText(TextField, "Gramas"), "50");
    await tester.enterText(find.widgetWithText(TextField, "Impressão"), "90");
    await tester.enterText(find.widgetWithText(TextField, "Peso da peça"), "60");
    await tester.enterText(find.widgetWithText(TextField, "Preço de venda"), "12,50");
    await tester.pump();
    await tester.tap(find.text("Guardar"));
    await settle(tester);

    // fechou a ficha
    expect(find.text("lista"), findsOneWidget);

    // o produto e a variante ficaram gravados, com tudo
    final product = (await tester.runAsync(() => container.read(productRepositoryProvider).fetchAll()))!
        .singleWhere((p) => p.name == "Bola teste");
    expect(product.colorIds, [3]);
    final variants = (await tester.runAsync(() => container.read(variantRepositoryProvider).fetchByProduct(product.id)))!;
    expect(variants, hasLength(1));
    final v = variants.single;
    expect(v.name, ""); // modelo único
    expect(v.salePrice, 12.5);
    expect(v.printTimeMin, 90);
    expect(v.weightG, 60);
    expect(v.filaments.single.grams, 50);
    expect(v.filaments.single.filamentId, 1); // Black Basic, o primeiro da lista

    // a encomenda: o preço vem sozinho, e o menu da cor só tem a da receita e a Orange
    router.go("/order");
    await settle(tester);
    await tester.tap(find.text("Adicionar produto do catálogo"));
    await settle(tester);
    await tester.tap(find.descendant(of: find.byType(SimpleDialog), matching: find.text("12,50 €")));
    await settle(tester);
    expect(find.widgetWithText(TextField, "Preço un."), findsOneWidget);
    expect((tester.widget<TextField>(find.widgetWithText(TextField, "Preço un.")).controller!).text, "12,50");
    await tester.tap(find.text("A da receita (Black Basic)"));
    await settle(tester);
    expect(find.text("Orange Basic · PLA"), findsWidgets);
    expect(find.text("Translucent · PETG"), findsNothing); // não está nas cores disponíveis
  });

  testWidgets("editar: o Guardar grava a variante; sair com alterações pergunta primeiro", (tester) async {
    await start(tester, "/");
    router.push("/edit/2"); // Árvore de Natal (demo): uma variante, "Verde", 12,00 €
    await settle(tester);

    // uma só variante: sem tabela; o nome aparece porque esta tem um ("Verde")
    expect(find.byType(DataTable), findsNothing);
    expect(find.text("Nome da variante"), findsOneWidget);
    final price = find.widgetWithText(TextField, "Preço de venda");
    expect(tester.widget<TextField>(price).controller!.text, "12,00");

    // muda o preço e tenta sair pela seta: pergunta
    await tester.enterText(price, "15");
    await tester.pump();
    await tester.tap(find.byType(BackButton));
    await settle(tester);
    expect(find.text("Alterações por gravar"), findsOneWidget);
    await tester.tap(find.text("Cancelar"));
    await settle(tester);
    expect(find.text("lista"), findsNothing); // ficou na ficha

    // grava: esta variante não tinha peso, e sem peso os portes saíam errados — pede-o
    await tester.tap(find.text("Guardar"));
    await settle(tester);
    expect(find.text("Escreve o peso da peça (para os portes)."), findsOneWidget);
    expect(find.text("lista"), findsNothing);
    await tester.enterText(find.widgetWithText(TextField, "Peso da peça"), "40");
    await tester.pump();
    await tester.tap(find.text("Guardar"));
    await settle(tester);
    expect(find.text("lista"), findsOneWidget);
    final container = ProviderScope.containerOf(tester.element(find.text("lista")));
    final v = (await tester.runAsync(() => container.read(variantRepositoryProvider).fetchByProduct(2)))!.single;
    expect(v.salePrice, 15);
    expect(v.weightG, 40);
    expect(v.name, "Verde"); // o resto fica como estava
    expect(v.filaments.single.grams, 60);

    // abrir e sair sem mexer: não pergunta nada
    router.push("/edit/2");
    await settle(tester);
    await tester.tap(find.byType(BackButton));
    await settle(tester);
    expect(find.text("Alterações por gravar"), findsNothing);
    expect(find.text("lista"), findsOneWidget);
  });
}

/// Os repositórios demo fingem a demora da rede (300 ms por pedido, e gravar um produto
/// novo faz vários seguidos): deixa passar esse tempo.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 500));
  }
  await tester.pump();
}
