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
    // um só campo de gramas, e nada de filamento nem de peso à parte (as cores são à esquerda)
    expect(find.widgetWithText(TextField, "Gramas"), findsOneWidget);
    expect(find.text("Peso da peça"), findsNothing);
    expect(find.text("Filamento total"), findsNothing);
    expect(find.text("Adicionar cor"), findsNothing);

    // sem cores, sem receita nem preço: não grava, e diz o que falta
    await tester.tap(find.text("Guardar"));
    await settle(tester);
    expect(find.text("Escolhe pelo menos uma cor."), findsOneWidget);
    expect(find.text("Escreve as gramas de filamento."), findsOneWidget);

    // cores disponíveis: Black Basic (13,43 €/kg) e Orange Basic (11,88 €/kg)
    await tester.tap(find.widgetWithText(FilterChip, "Black Basic · PLA"));
    await tester.tap(find.widgetWithText(FilterChip, "Orange Basic · PLA"));
    await tester.pump();
    expect(find.text("Custo feito com a cor mais cara das disponíveis."), findsOneWidget);
    final container = ProviderScope.containerOf(tester.element(find.byType(ProductFormScreen)));
    expect((await tester.runAsync(() => container.read(productRepositoryProvider).fetchAll()))!
        .where((p) => p.name == "Bola teste"), isEmpty);

    await tester.enterText(find.widgetWithText(TextField, "Gramas"), "50");
    await tester.enterText(find.widgetWithText(TextField, "Impressão"), "90");
    await tester.enterText(find.widgetWithText(TextField, "Preço de venda"), "12,50");
    await tester.pump();
    await tester.tap(find.text("Guardar"));
    await settle(tester);

    // fechou a ficha
    expect(find.text("lista"), findsOneWidget);

    // o produto e a variante ficaram gravados, com tudo
    final product = (await tester.runAsync(() => container.read(productRepositoryProvider).fetchAll()))!
        .singleWhere((p) => p.name == "Bola teste");
    expect(product.colorIds, [1, 3]);
    final variants = (await tester.runAsync(() => container.read(variantRepositoryProvider).fetchByProduct(product.id)))!;
    expect(variants, hasLength(1));
    final v = variants.single;
    expect(v.name, ""); // modelo único
    expect(v.salePrice, 12.5);
    expect(v.printTimeMin, 90);
    expect(v.weightG, 50); // o peso é as gramas
    expect(v.filaments.single.grams, 50);
    expect(v.filaments.single.filamentId, 1); // Black Basic, a mais cara das duas

    // a encomenda: o preço vem sozinho; a cor é obrigatória e o menu só tem as duas
    router.go("/order");
    await settle(tester);
    await tester.tap(find.text("Adicionar produto do catálogo"));
    await settle(tester);
    // modelo único: uma linha "Bola teste … 12,50 €", sem "Modelo único"
    final dialog = find.byType(SimpleDialog);
    expect(find.descendant(of: dialog, matching: find.text("Bola teste")), findsOneWidget);
    expect(find.descendant(of: dialog, matching: find.text("Modelo único")), findsNothing);
    await tester.tap(find.descendant(of: dialog, matching: find.text("12,50 €")));
    await settle(tester);
    expect(find.widgetWithText(TextField, "Preço un."), findsOneWidget);
    expect((tester.widget<TextField>(find.widgetWithText(TextField, "Preço un.")).controller!).text, "12,50");
    expect(find.textContaining("A da receita"), findsNothing);
    await tester.enterText(find.widgetWithText(TextField, "Nome ou referência"), "Ana");
    await tester.tap(find.widgetWithText(FilledButton, "Criar encomenda"));
    await settle(tester);
    expect(find.text("Escolhe a cor de cada artigo."), findsOneWidget);
    expect(find.text("Escolher cor"), findsOneWidget);
    await tester.tap(find.byType(DropdownButtonFormField<int?>));
    await settle(tester);
    expect(find.text("Black Basic · PLA"), findsWidgets);
    expect(find.text("Orange Basic · PLA"), findsWidgets);
    expect(find.text("Translucent · PETG"), findsNothing); // não está nas cores disponíveis
    await tester.tap(find.text("Orange Basic · PLA").last);
    await settle(tester);
    expect(find.text("Escolhe a cor de cada artigo."), findsNothing);
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

    // grava: este produto ainda não tinha cores — pede-as
    await tester.tap(find.text("Guardar"));
    await settle(tester);
    expect(find.text("Escolhe pelo menos uma cor."), findsOneWidget);
    expect(find.text("lista"), findsNothing);
    await tester.tap(find.widgetWithText(FilterChip, "Orange Basic · PLA"));
    await tester.pump();
    await tester.tap(find.text("Guardar"));
    await settle(tester);
    expect(find.text("lista"), findsOneWidget);
    final container = ProviderScope.containerOf(tester.element(find.text("lista")));
    final v = (await tester.runAsync(() => container.read(variantRepositoryProvider).fetchByProduct(2)))!.single;
    expect(v.salePrice, 15);
    expect(v.weightG, 60); // não tinha peso: passa a ser as gramas
    expect(v.name, "Verde"); // o resto fica como estava
    expect(v.filaments.single.grams, 60);
    expect(v.filaments.single.filamentId, 3); // a receita passa para a cor disponível

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
