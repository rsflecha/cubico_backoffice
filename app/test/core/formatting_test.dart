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
  });
}
