import 'package:cubico_backoffice/features/auth/domain/app_user.dart';
import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:cubico_backoffice/features/products/domain/product_category.dart';
import 'package:cubico_backoffice/features/products/presentation/products_providers.dart';
import 'package:cubico_backoffice/features/products/presentation/products_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Os botões das categorias: quando não cabem numa linha, descem para a seguinte.
/// Antes deslizavam para o lado e os últimos (incluindo "Nova") ficavam fora do ecrã.

class _Demo extends DemoModeNotifier {
  @override
  bool build() => true;
}

class _Admin extends SessionNotifier {
  @override
  AppUser? build() => const AppUser(id: 1, name: "Rui", email: "rui@teste.pt", role: UserRole.admin);
}

const _names = ["Brindes", "Flexi", "Packs", "Secretária", "Decoração Natal", "Porta-chaves", "Suportes F1"];

void main() {
  testWidgets("num ecrã de 700 px, todas as categorias e o Nova ficam dentro do ecrã", (tester) async {
    tester.view.physicalSize = const Size(700, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(routes: [GoRoute(path: "/", builder: (_, _) => const ProductsScreen())]);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        demoModeProvider.overrideWith(_Demo.new),
        sessionProvider.overrideWith(_Admin.new),
        productCategoriesProvider.overrideWith(
          (ref) async => [for (final (i, n) in _names.indexed) ProductCategory(id: i + 1, name: n)],
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    for (final label in ["Todas", ..._names, "Nova"]) {
      final rect = tester.getRect(find.widgetWithText(ActionChip, label).evaluate().isNotEmpty
          ? find.widgetWithText(ActionChip, label)
          : find.widgetWithText(ChoiceChip, label));
      expect(rect.right, lessThanOrEqualTo(700), reason: "\"$label\" saiu do ecrã");
    }
    // não cabem numa linha: há botões em mais do que uma linha
    final tops = {
      for (final label in ["Todas", ..._names]) tester.getTopLeft(find.widgetWithText(ChoiceChip, label)).dy,
    };
    expect(tops.length, greaterThan(1));
  });
}
