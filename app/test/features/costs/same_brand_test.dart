import 'package:cubico_backoffice/features/costs/domain/filament.dart';
import 'package:cubico_backoffice/features/costs/domain/same_brand.dart';
import 'package:flutter_test/flutter_test.dart';

Filament _f(int id, String? brand, int tare) => Filament(
  id: id,
  material: "PLA",
  brand: brand,
  colorName: "Preto",
  emptySpoolG: tare,
);

void main() {
  test("devolve só os da mesma marca com tara diferente", () {
    final edited = _f(1, "Bambu Lab", 250);
    final other = _f(2, "bambu lab ", 0);
    final all = [edited, other, _f(3, "Bambu Lab", 250), _f(4, "Sunlu", 0)];

    expect(sameBrandOthers(all, edited), [other]);
  });

  test("marca nula ou vazia devolve lista vazia", () {
    final all = [_f(1, null, 250), _f(2, null, 0), _f(3, " ", 0)];

    expect(sameBrandOthers(all, all[0]), isEmpty);
    expect(sameBrandOthers(all, all[2]), isEmpty);
  });
}
