import 'dart:typed_data';

import 'package:cubico_backoffice/features/auth/domain/app_user.dart';
import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:cubico_backoffice/features/products/data/demo_product_repository.dart';
import 'package:cubico_backoffice/features/products/domain/product.dart';
import 'package:cubico_backoffice/features/products/presentation/product_form_screen.dart';
import 'package:cubico_backoffice/features/products/presentation/products_providers.dart';
import 'package:cubico_backoffice/features/products/presentation/products_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// O estado do produto (Ativo / Rascunho / Arquivado): muda-se na ficha e vê-se na lista.
/// Antes não havia campo: todos os produtos nasciam em Rascunho e assim ficavam.

class _Demo extends DemoModeNotifier {
  @override
  bool build() => true;
}

class _Admin extends SessionNotifier {
  @override
  AppUser? build() => const AppUser(id: 1, name: "Rui", email: "rui@teste.pt", role: UserRole.admin);
}

/// Os produtos demo, com uma cor (sem cor a ficha não grava).
class _WithColor extends DemoProductRepository {
  _WithColor() : super(categoryCode: (_) async => "SEC");

  @override
  Future<List<Product>> fetchAll() async => [for (final p in await super.fetchAll()) p.copyWith(colorIds: [1])];
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 500));
  }
}

void main() {
  testWidgets("mudar para Rascunho grava, e a lista mostra a etiqueta", (tester) async {
    tester.view.physicalSize = const Size(1400, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = _WithColor();
    final router = GoRouter(initialLocation: "/products", routes: [
      GoRoute(path: "/products", builder: (_, _) => const ProductsScreen(), routes: [
        GoRoute(
          path: ":id",
          builder: (_, s) => ProductFormScreen(productId: int.parse(s.pathParameters["id"]!)),
        ),
      ]),
    ]);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        demoModeProvider.overrideWith(_Demo.new),
        sessionProvider.overrideWith(_Admin.new),
        productRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    await _settle(tester);
    // todos à venda: nenhuma etiqueta
    expect(find.widgetWithText(Chip, "Rascunho"), findsNothing);

    await tester.tap(find.text("Árvore de Natal"));
    await _settle(tester);
    expect(find.text("Estado"), findsOneWidget);
    expect(find.text("À venda."), findsOneWidget);

    await tester.tap(find.text("Rascunho"));
    await tester.pump();
    expect(find.textContaining("na Etsy, não conta como ligado"), findsOneWidget);
    await tester.tap(find.text("Guardar"));
    await _settle(tester);

    // (o repositório demo espera 300 ms a sério: fora do relógio falso do teste)
    final saved = (await tester.runAsync(repo.fetchAll))!.firstWhere((p) => p.id == 2);
    expect(saved.status, ProductStatus.draft);
    // voltou à lista, e lá diz que está em rascunho
    expect(find.widgetWithText(Chip, "Rascunho"), findsOneWidget);
  });

  test("um produto novo nasce Ativo", () async {
    final p = await _WithColor().create(name: "Teste", categoryId: 1, photo: Uint8List(1));
    expect(p.status, ProductStatus.active);
  });
}
