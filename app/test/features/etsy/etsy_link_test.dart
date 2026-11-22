import 'package:cubico_backoffice/features/etsy/data/demo_etsy_repository.dart';
import 'package:cubico_backoffice/features/etsy/domain/etsy_listings_check.dart';
import 'package:cubico_backoffice/features/etsy/presentation/etsy_listings_check_screen.dart';
import 'package:cubico_backoffice/features/etsy/presentation/etsy_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Um anúncio com um artigo por ligar e outro associado à mão; duas variantes para escolher.
EtsyListingsCheck _check({bool linkedDone = false}) => EtsyListingsCheck.fromJson({
      "checked_at": "2026-11-22T10:00:00+00:00",
      "ok": linkedDone ? 2 : 1,
      "problems": linkedDone ? 0 : 1,
      "listings": [
        {
          "listing_id": "4440001",
          "title": "Suporte F1",
          "products": [
            linkedDone
                ? {
                    "product_id": "111",
                    "linked": true,
                    "sku": "VERS-ETSY",
                    "variation": "Piloto: Verstappen",
                    "status": "ok",
                    "variant": {"variant_id": 6, "product_id": 2, "sku": "CD3-SUP-01-02", "label": "Suporte F1 · Verstappen"},
                  }
                : {"product_id": "111", "sku": "VERS-ETSY", "variation": "Piloto: Verstappen", "status": "unknown_sku"},
            {
              "product_id": "222",
              "linked": true,
              "sku": null,
              "variation": "Piloto: Hamilton",
              "status": "ok",
              "variant": {"variant_id": 5, "product_id": 2, "sku": "CD3-SUP-01-01", "label": "Suporte F1 · Hamilton"},
            },
          ],
        },
      ],
      "variants": [
        {"variant_id": 5, "product_id": 2, "sku": "CD3-SUP-01-01", "label": "Suporte F1 · Hamilton"},
        {"variant_id": 6, "product_id": 2, "sku": "CD3-SUP-01-02", "label": "Suporte F1 · Verstappen"},
      ],
    });

/// Guarda o que o ecrã mandou associar ou desfazer.
class _Spy extends DemoEtsyRepository {
  final linked = <String>[];
  final unlinked = <String>[];

  @override
  Future<void> link({required String productId, required String listingId, required int variantId}) async {
    linked.add("$productId/$listingId → $variantId");
  }

  @override
  Future<void> unlink(String productId) async => unlinked.add(productId);
}

void main() {
  test("lê o produto da Etsy, o 'associado à mão' e as variantes para escolher", () {
    final c = _check();
    expect(c.listings.single.products.first.productId, "111");
    expect(c.listings.single.products.last.linked, isTrue);
    expect(c.variants.map((v) => v.variantId), [5, 6]);
  });

  testWidgets("associar: escolhe a variante, grava e confere outra vez; desfazer também", (tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final spy = _Spy();
    var loads = 0;
    await tester.pumpWidget(ProviderScope(
      overrides: [
        etsyRepositoryProvider.overrideWithValue(spy),
        etsyListingsCheckProvider.overrideWith((ref) async => _check(linkedDone: loads++ > 0)),
      ],
      child: const MaterialApp(home: EtsyListingsCheckScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text("Liga a: Suporte F1 · Hamilton (associado à mão)"), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, "Associar"));
    await tester.pumpAndSettle();
    expect(find.text("Associar a uma variante"), findsOneWidget);
    expect(find.text("Na Etsy: Piloto: Verstappen · SKU VERS-ETSY"), findsOneWidget);

    // sem escolher, o botão de gravar está desligado
    final save = find.descendant(of: find.byType(AlertDialog), matching: find.widgetWithText(FilledButton, "Associar"));
    expect(tester.widget<FilledButton>(save).onPressed, isNull);
    await tester.tap(find.text("Suporte F1 · Verstappen"));
    await tester.pump();
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(spy.linked, ["111/4440001 → 6"]);
    expect(loads, 2, reason: "depois de associar, confere outra vez");
    expect(find.text("Associar a uma variante"), findsNothing);
    expect(find.text("Liga a: Suporte F1 · Verstappen (associado à mão)"), findsOneWidget);

    await tester.tap(find.text("Desfazer").first);
    await tester.pumpAndSettle();
    expect(spy.unlinked, ["111"]);
  });
}
