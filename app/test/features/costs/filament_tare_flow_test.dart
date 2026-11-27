import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:cubico_backoffice/features/costs/domain/filament.dart';
import 'package:cubico_backoffice/features/costs/domain/filament_repository.dart';
import 'package:cubico_backoffice/features/costs/presentation/costs_providers.dart';
import 'package:cubico_backoffice/features/costs/presentation/tabs/filaments_tab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// A tara na ficha do filamento e a oferta de a copiar para a mesma marca.

class _Demo extends DemoModeNotifier {
  @override
  bool build() => true;
}

/// Repositório em memória; `failFetchesAfter` faz as leituras seguintes falhar.
class _Repo implements FilamentRepository {
  _Repo(this.items);
  List<Filament> items;
  int fetches = 0;
  int? failFetchesAfter;

  @override
  Future<List<Filament>> fetchAll() async {
    fetches++;
    if (failFetchesAfter != null && fetches > failFetchesAfter!) {
      throw Exception("sem rede");
    }
    return List.of(items);
  }

  @override
  Future<Filament> create(Filament draft) async => draft;

  @override
  Future<Filament> update(Filament f) async {
    items = [for (final x in items) x.id == f.id ? f : x];
    return f;
  }
}

Filament _f(int id, String color, int tare) => Filament(
  id: id,
  material: "PLA",
  brand: "Bambu Lab",
  colorName: color,
  paidPrice: 20,
  listPrice: 20,
  emptySpoolG: tare,
);

Future<_Repo> _open(WidgetTester tester, {int? failAfter}) async {
  tester.view.physicalSize = const Size(1400, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final repo = _Repo([_f(1, "Preto", 250), _f(2, "Branco", 0)]);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        demoModeProvider.overrideWith(_Demo.new),
        filamentRepositoryProvider.overrideWithValue(repo),
      ],
      child: const MaterialApp(home: Scaffold(body: FilamentsTab())),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text("Preto"));
  await tester.pumpAndSettle();
  repo.failFetchesAfter = failAfter == null ? null : repo.fetches + failAfter;
  return repo;
}

Finder _field(String label) => find.byWidgetPredicate(
  (w) => w is TextField && w.decoration?.labelText == label,
);

Future<void> _type(WidgetTester tester, String label, String text) async {
  await tester.enterText(_field(label), text);
  await tester.pump();
}

Future<void> _save(WidgetTester tester) async {
  await tester.tap(find.text("Guardar"));
  await _settle(tester);
}

void main() {
  testWidgets("tara mudada: oferece copiar, e «Usar» grava no outro", (
    tester,
  ) async {
    final repo = await _open(tester);
    await _type(tester, "Carretel vazio", "300");
    await _save(tester);

    expect(
      find.text("Usar 300 g nos outros 1 filamentos Bambu Lab?"),
      findsOneWidget,
    );
    await tester.tap(find.text("Usar"));
    await _settle(tester);

    expect(repo.items.firstWhere((f) => f.id == 2).emptySpoolG, 300);
    expect(find.text("Editar filamento"), findsNothing);
  });

  testWidgets("«Agora não» deixa o outro como estava", (tester) async {
    final repo = await _open(tester);
    await _type(tester, "Carretel vazio", "300");
    await _save(tester);
    await tester.tap(find.text("Agora não"));
    await _settle(tester);

    expect(repo.items.firstWhere((f) => f.id == 2).emptySpoolG, 0);
    expect(find.text("Editar filamento"), findsNothing);
  });

  testWidgets("tara por mexer (só o preço): não pergunta nada", (tester) async {
    final repo = await _open(tester);
    await _type(tester, "Preço pago", "22");
    await _save(tester);

    expect(find.textContaining("Usar "), findsNothing);
    expect(repo.items.firstWhere((f) => f.id == 1).paidPrice, 22);
    expect(find.text("Editar filamento"), findsNothing);
  });

  testWidgets("tara a 0: não oferece apagar as dos outros", (tester) async {
    final repo = await _open(tester);
    repo.items = [
      repo.items[0],
      _f(2, "Branco", 100),
    ]; // difere de 0: sem a regra, ofereceria
    await _type(tester, "Carretel vazio", "0");
    await _save(tester);

    expect(find.textContaining("Usar "), findsNothing);
    expect(repo.items[1].emptySpoolG, 100);
    expect(find.text("Editar filamento"), findsNothing);
  });

  testWidgets("a releitura falha depois de gravar: não fica pendurado", (
    tester,
  ) async {
    final repo = await _open(tester, failAfter: 0);
    await _type(tester, "Carretel vazio", "300");
    await _save(tester);

    expect(tester.takeException(), isNull);
    expect(repo.items.firstWhere((f) => f.id == 1).emptySpoolG, 300);
    expect(find.textContaining("Usar "), findsNothing);
  });
}

/// Passos curtos em vez de pumpAndSettle: o spinner de "a guardar" nunca assenta.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
}
