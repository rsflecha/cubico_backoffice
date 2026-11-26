import 'package:cubico_backoffice/core/formatting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("compareNames", () {
    test("põe por ordem alfabética sem ligar a maiúsculas", () {
      final names = ["flexi", "Packs", "Decoração", "árvores", "Base"]..sort(compareNames);
      expect(names, ["árvores", "Base", "Decoração", "flexi", "Packs"]);
    });

    test("um nome com acento fica no sítio da letra sem acento", () {
      // comparando o texto tal e qual, "Á" vinha depois de "Z"
      expect(compareNames("Árvore", "Zebra"), lessThan(0));
      expect(compareNames("Ção", "Casa"), lessThan(0)); // "cao" < "casa": o "o" vem antes do "s"
    });

    test("nomes iguais sem acentos ficam sempre pela mesma ordem", () {
      expect(compareNames("Acao", "Ação"), isNot(0));
      expect(compareNames("Base", "Base"), 0);
    });

    test("os números contam pelo valor (tamanhos do menor para o maior)", () {
      // as Renas da loja: pela criação vinham 135, 175, 245 com o SKU -02, -01, -03
      final renas = ["Rena de Natal - 245mm", "Rena de Natal - 1000mm", "Rena de Natal - 135mm", "Rena de Natal - 175mm"]
        ..sort(compareNames);
      expect(renas, ["Rena de Natal - 135mm", "Rena de Natal - 175mm", "Rena de Natal - 245mm", "Rena de Natal - 1000mm"]);
      final f1 = ["Red Bull", "Alpine", "APX", "Aston Martin"]..sort(compareNames);
      expect(f1, ["Alpine", "APX", "Aston Martin", "Red Bull"]);
      expect(compareNames("Caixa 9", "Caixa 10"), lessThan(0));
    });
  });

  group("gramsText", () {
    test("inteiras sem casas, décimas com vírgula", () {
      expect(gramsText(120), "120 g");
      expect(gramsText(86.4), "86,4 g");
      expect(gramsText(86.45), "86,45 g");
      expect(gramsText(1500), "1500 g");
    });

    test("somas de decimais não mostram o lixo do double", () {
      expect(86.4 * 3, isNot(259.2)); // 259.20000000000002
      expect(gramsText(86.4 * 3), "259,2 g");
    });
  });

  group("gramsField", () {
    test("para os campos: sem zeros a mais, no máximo 2 casas", () {
      expect(gramsField(120), "120");
      expect(gramsField(86.4), "86,4");
      expect(gramsField(86.456), "86,46");
    });
  });
}
