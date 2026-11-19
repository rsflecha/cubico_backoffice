import 'package:cubico_backoffice/features/products/domain/sku.dart';
import 'package:flutter_test/flutter_test.dart';

// Os mesmos casos do teste da API (api/src/sku.php): as duas têm de dar o mesmo.
void main() {
  group("código da categoria", () {
    test("3 letras do nome, sem acentos", () {
      expect(newCategoryCode("Secretária", []), "SEC");
      expect(newCategoryCode("Zé Teste Ótimo", []), "ZET");
      expect(newCategoryCode("Fórmula 1", []), "FOR");
    });
    test("já usado: XX2, XX3…", () {
      expect(newCategoryCode("Secos", ["SEC"]), "SE2");
      expect(newCategoryCode("Secos", ["SEC", "SE2"]), "SE3");
    });
    test("GER fica reservado para os produtos sem categoria", () {
      expect(newCategoryCode("Geral", []), "GE2");
    });
    test("nome sem letras: CAT", () {
      expect(newCategoryCode("***", []), "CAT");
    });
    test("códigos aceitáveis", () {
      expect(isValidCategoryCode("F1"), isTrue);
      expect(isValidCategoryCode("A B"), isFalse);
      expect(isValidCategoryCode("ABCDEF"), isFalse);
    });
  });

  group("SKU do produto", () {
    test("começa em 01 em cada categoria", () {
      expect(nextProductSku("SUP", []), "CD3-SUP-01");
      expect(nextProductSku("SUP", ["CD3-SUP-01", "CD3-SEC-07"]), "CD3-SUP-02");
    });
    test("o seguinte ao maior, mesmo com buracos", () {
      expect(nextProductSku("SUP", ["CD3-SUP-01", "CD3-SUP-05"]), "CD3-SUP-06");
    });
    test("sem categoria: GER", () {
      expect(nextProductSku(null, []), "CD3-GER-01");
    });
    test("passa dos 99", () {
      expect(nextProductSku("SUP", ["CD3-SUP-99"]), "CD3-SUP-100");
    });
  });

  group("SKU da variante", () {
    test("o do produto mais o número, com 2 algarismos", () {
      expect(variantSku("CD3-NAT-01", 1), "CD3-NAT-01-01");
      expect(variantSku("CD3-NAT-01", 12), "CD3-NAT-01-12");
      expect(variantSku("CD3-NAT-01", 100), "CD3-NAT-01-100");
    });
    test("sem número (modelo único): o próprio produto", () {
      expect(variantSku("CD3-SEC-01", null), "CD3-SEC-01");
    });
    test("lê o número do SKU", () {
      expect(variantNumber("CD3-NAT-01", "CD3-NAT-01-03"), 3);
      expect(variantNumber("CD3-NAT-01", "CD3-NAT-01"), isNull);
      expect(variantNumber("CD3-NAT-01", "CD3-NAT-01-HAMILTON"), isNull);
      expect(variantNumber("CD3-NAT-01", "CD3-NAT-02-01"), isNull);
    });
    test("o próximo número: o maior mais 1, sem reaproveitar buracos", () {
      expect(nextVariantNumber("CD3-NAT-01", []), 1);
      expect(nextVariantNumber("CD3-NAT-01", ["CD3-NAT-01"]), 1);
      expect(nextVariantNumber("CD3-NAT-01", ["CD3-NAT-01-01", "CD3-NAT-01-03"]), 4);
    });
  });
}
