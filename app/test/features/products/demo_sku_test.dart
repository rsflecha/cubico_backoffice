import 'dart:typed_data';

import 'package:cubico_backoffice/core/api/api_exception.dart';
import 'package:cubico_backoffice/features/products/data/demo_product_repository.dart';
import 'package:cubico_backoffice/features/products/data/demo_variant_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// O modo demo tem de dar os mesmos SKU que a API, sem servidor.
void main() {
  late DemoProductRepository products;
  late DemoVariantRepository variants;

  setUp(() {
    const codes = {1: "SEC", 2: "BRI", 9: "FOR"};
    variants = DemoVariantRepository(
      productSku: (id) async => (await products.fetchAll()).firstWhere((p) => p.id == id).baseSku,
    );
    products = DemoProductRepository(
      categoryCode: (id) async => codes[id],
      onSkuChanged: variants.rebase,
    );
  });

  test("produto novo: o próximo número da categoria", () async {
    // a demo já tem CD3-BRI-01 e CD3-BRI-02
    final p = await products.create(name: "Teste", categoryId: 2, photo: Uint8List(1));
    expect(p.baseSku, "CD3-BRI-03");
  });

  test("variantes: sem nome = o produto; com nome = produto + nome; copiam a primeira", () async {
    final p = await products.create(name: "Suporte F1", categoryId: 9, photo: Uint8List(1));
    final first = await variants.create(productId: p.id);
    expect(first.sku, "CD3-FOR-01");
    await variants.update(first.copyWith(salePrice: 15, printTimeMin: 90));

    final second = await variants.create(productId: p.id, name: "Verstappen");
    expect(second.sku, "CD3-FOR-01-VERSTAPPEN");
    expect(second.salePrice, 15);
    expect(second.printTimeMin, 90);

    final renamed = await variants.update(first.copyWith(name: "Hamilton", sku: "IGNORADO"));
    expect(renamed.sku, "CD3-FOR-01-HAMILTON");
  });

  test("nome repetido falha como na API", () async {
    final p = await products.create(name: "Suporte F1", categoryId: 9, photo: Uint8List(1));
    await variants.create(productId: p.id, name: "Hamilton");
    expect(
      () => variants.create(productId: p.id, name: "hamílton"),
      throwsA(isA<ApiException>()),
    );
  });

  test("mudar de categoria: SKU novo e as variantes acompanham", () async {
    final p = await products.create(name: "Suporte F1", categoryId: 9, photo: Uint8List(1));
    await variants.create(productId: p.id, name: "Hamilton");
    final moved = await products.update(p.copyWith(categoryId: 1));
    expect(moved.baseSku, "CD3-SEC-02"); // a demo já tem CD3-SEC-01
    final list = await variants.fetchByProduct(p.id);
    expect(list.single.sku, "CD3-SEC-02-HAMILTON");
  });

  test("o SKU do produto não se muda à mão", () async {
    final p = (await products.fetchAll()).first;
    final saved = await products.update(p.copyWith(baseSku: "HACK", name: "Outro nome"));
    expect(saved.baseSku, p.baseSku);
    expect(saved.name, "Outro nome");
  });
}
