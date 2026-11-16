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
    test("o do produto mais o nome", () {
      expect(variantSku("CD3-FOR-01", "Hamilton"), "CD3-FOR-01-HAMILTON");
      expect(variantSku("CD3-FOR-01", "Lewis Hamilton"), "CD3-FOR-01-LEWIS-HAMILTON");
      expect(variantSku("CD3-SEC-02", "Ação & Côr!"), "CD3-SEC-02-ACAO-COR");
    });
    test("sem nome: o próprio produto", () {
      expect(variantSku("CD3-SEC-01", ""), "CD3-SEC-01");
      expect(variantSku("CD3-SEC-01", "   "), "CD3-SEC-01");
    });
    test("nome sem letras: V", () {
      expect(variantSku("CD3-GER-01", "***"), "CD3-GER-01-V");
    });
    test("nome comprido: corta aos 30, sem hífen no fim", () {
      expect(
        variantSku("CD3-FOR-01", "Uma variante com um nome mesmo muito comprido demais"),
        "CD3-FOR-01-UMA-VARIANTE-COM-UM-NOME-MESMO",
      );
    });
  });
}
