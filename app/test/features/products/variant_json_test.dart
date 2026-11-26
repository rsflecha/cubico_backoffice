import 'package:cubico_backoffice/features/products/domain/variant.dart';
import 'package:flutter_test/flutter_test.dart';

/// As gramas vêm da API com 2 casas (migração 014). Enquanto a API do servidor não for
/// atualizada, ainda chegam inteiras: as duas formas têm de servir.
void main() {
  test("aceita gramas inteiras (API antiga) e com decimais", () {
    expect(VariantFilament.fromJson({"filament_id": 1, "grams": 120}).grams, 120.0);
    expect(VariantFilament.fromJson({"filament_id": 1, "grams": 86.4}).grams, 86.4);
  });

  test("as gramas da Cor 2 também guardam as décimas", () {
    final v = Variant.fromJson({
      "id": 1,
      "product_id": 1,
      "name": "",
      "sku": "CD3-X-01",
      "sale_price": 10,
      "grams_color_2": 12.35,
    });
    expect(v.gramsColor2, 12.35);
  });
}
