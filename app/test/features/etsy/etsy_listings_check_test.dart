import 'package:cubico_backoffice/core/api/api_exception.dart';
import 'package:cubico_backoffice/features/etsy/domain/etsy_listings_check.dart';
import 'package:cubico_backoffice/features/etsy/presentation/etsy_listings_check_screen.dart';
import 'package:cubico_backoffice/features/etsy/presentation/etsy_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// A resposta tal como a API a manda (snake_case), com um anúncio bom e um com problemas.
final _json = {
  "checked_at": "2026-11-16T22:00:00+00:00",
  "ok": 2,
  "problems": 2,
  "listings": [
    {
      "listing_id": "1001",
      "title": "Suporte F1",
      "url": "https://www.etsy.com/listing/1001",
      "products": [
        {
          "sku": "CD3-SUP-01-HAMILTON",
          "variation": "Piloto: Hamilton",
          "status": "ok",
          "variant": {"variant_id": 5, "product_id": 2, "sku": "CD3-SUP-01-HAMILTON", "label": "Suporte F1 · Hamilton"},
        },
        {"sku": "CD3-SUP-01-VERS", "variation": "Piloto: Verstappen", "status": "unknown_sku", "variant": null},
      ],
    },
    {
      "listing_id": "1002",
      "title": "Abre-cápsulas",
      "url": "",
      "products": [
        {
          "sku": "CD3-ABR-01",
          "variation": "",
          "status": "ok",
          "variant": {"variant_id": 7, "product_id": 3, "sku": "CD3-ABR-01", "label": "Abre-cápsulas"},
        },
      ],
    },
    {
      "listing_id": "1003",
      "title": "Base sem SKU",
      "url": "",
      "products": [
        {"sku": null, "variation": "", "status": "no_sku", "variant": null},
      ],
    },
  ],
  "unlisted_variants": [
    {"variant_id": 9, "product_id": 4, "sku": "CD3-POR-01", "label": "Porta-chaves"},
  ],
};

void main() {
  test("lê a resposta da API", () {
    final c = EtsyListingsCheck.fromJson(_json);
    expect(c.ok, 2);
    expect(c.problems, 2);
    expect(c.listings.first.products.first.variant!.productId, 2);
    expect(c.unlistedVariants.single.sku, "CD3-POR-01");
  });

  test("o que falta, em português", () {
    final p = EtsyListingsCheck.fromJson(_json).listings.first.products;
    expect(p[0].problem, isNull);
    expect(p[1].problem, "Nenhuma variante da app tem o SKU CD3-SUP-01-VERS.");
    expect(const EtsyProductCheck(status: "no_sku").problem, "Sem SKU na Etsy.");
  });

  test("anúncios com problemas primeiro, depois por título", () {
    final titles = EtsyListingsCheck.fromJson(_json).sorted.map((l) => l.title).toList();
    expect(titles, ["Base sem SKU", "Suporte F1", "Abre-cápsulas"]);
  });

  Future<void> show(WidgetTester tester, Future<EtsyListingsCheck> Function() load) async {
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [etsyListingsCheckProvider.overrideWith((ref) => load())],
      child: const MaterialApp(home: EtsyListingsCheckScreen()),
    ));
    await tester.pump();
  }

  testWidgets("com problemas: resumo a vermelho e cada artigo com o que falta", (tester) async {
    await show(tester, () async => EtsyListingsCheck.fromJson(_json));
    expect(find.text("2 artigos ficavam de fora numa venda."), findsOneWidget);
    expect(find.text("Liga a: Suporte F1 · Hamilton"), findsOneWidget);
    expect(find.text("Piloto: Verstappen · SKU CD3-SUP-01-VERS"), findsOneWidget);
    expect(find.text("Nenhuma variante da app tem o SKU CD3-SUP-01-VERS."), findsOneWidget);
    expect(find.text("sem SKU"), findsOneWidget);
    expect(find.text("Sem SKU na Etsy."), findsOneWidget);
    expect(find.text("Variantes da app sem anúncio na Etsy (1)"), findsOneWidget);
  });

  testWidgets("tudo certo: diz que as vendas entram sozinhas", (tester) async {
    final allOk = EtsyListingsCheck.fromJson({..._json, "digital_skipped": 3}).copyWith(problems: 0, ok: 3, listings: []);
    await show(tester, () async => allOk);
    expect(find.text("Tudo certo: 3 artigos ligam a uma variante."), findsOneWidget);
    expect(find.textContaining("3 anúncios digitais ignorados"), findsOneWidget);
    expect(find.text("A loja não tem anúncios ativos."), findsOneWidget);
  });

  testWidgets("erro da API (ligação antiga): mostra a mensagem e deixa tentar outra vez", (tester) async {
    await show(tester, () async => throw const ApiException("Carrega em «Ligar outra vez»."));
    expect(find.text("Carrega em «Ligar outra vez»."), findsOneWidget);
    expect(find.text("Tentar outra vez"), findsOneWidget);
  });
}
