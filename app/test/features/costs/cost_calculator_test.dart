import 'package:cubico_backoffice/features/costs/domain/cost_calculator.dart';
import 'package:cubico_backoffice/features/costs/domain/filament.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const calc = CostCalculator();

  const pla = Filament(
    id: 1,
    material: "PLA",
    colorName: "Preto",
    listPrice: 24.99,
    paidPrice: 20.00,
    shippingCost: 5.00,
    spoolsInOrder: 2,
  );

  group("Filamento", () {
    test("€/kg inclui a parte dos portes de cada rolo", () {
      // 20 € + 5 € ÷ 2 rolos = 22,50 € por rolo de 1 kg
      expect(calc.filamentPricePerKg(pla), closeTo(22.50, 0.001));
    });

    test("custo de 50 g", () {
      // 50 g × 22,50 €/kg = 1,125 €
      expect(calc.filamentCost(grams: 50, filament: pla), closeTo(1.125, 0.001));
    });
  });

  group("Impressora", () {
    test("custo por hora da A1: luz + desgaste + manutenção", () {
      // luz 0,01995 + desgaste 0,07628 + manutenção 0,02667 ≈ 0,1229 €/h
      final perHour = calc.printerCostPerHour(
        powerW: 95,
        kwhPrice: 0.21,
        purchasePrice: 381.40,
        lifespanHours: 5000,
        yearlyMaintenance: 40,
        yearlyHours: 1500,
      );
      expect(perHour, closeTo(0.1229, 0.0001));
    });

    test("imprimir 90 minutos", () {
      // 90 min = 1,5 h × 0,1229 €/h ≈ 0,1844 €
      final cost = calc.printingCost(minutes: 90, costPerHour: 0.1229);
      expect(cost, closeTo(0.1844, 0.0001));
    });
  });

  group("Venda", () {
    test("taxas da Etsy a 20€", () {
      // 20 × 10,5% = 2,10 + 0,30 + 0,20 = 2,60 €
      final etsy = calc.channelFees(
        price: 20,
        transactionPct: 6.5,
        processingPct: 4,
        flatFee: 0.30,
        listingFee: 0.20,
      );
      expect(etsy, closeTo(2.60, 0.001));
    });
  });
}