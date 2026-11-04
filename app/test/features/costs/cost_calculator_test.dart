import 'package:cubico_backoffice/features/costs/domain/component.dart';
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

    test("sem taxas (Instagram, Facebook, Pessoalmente)", () {
      final fees = calc.channelFees(
        price: 20,
        transactionPct: 0,
        processingPct: 0,
        flatFee: 0,
        listingFee: 0,
      );
      expect(fees, closeTo(0, 0.001));
    });

    test("margem a 20 € com 6 € de produção na Etsy", () {
      // lucro = 20 − 6 − 2,60 = 11,40 → 11,40 ÷ 20 = 57%
      final margin = calc.marginPct(
        price: 20,
        productionCost: 6,
        fees: 2.60,
      );
      expect(margin, closeTo(57, 0.001));
    });

    test("preço sugerido para 60% de margem na Etsy", () {
      // (6 + 0,30 + 0,20) ÷ (1 − 0,105 − 0,60) = 22,03 → arredonda para cima a 0,50 = 22,50
      final price = calc.suggestedPrice(
        productionCost: 6,
        targetMarginPct: 60,
        transactionPct: 6.5,
        processingPct: 4,
        flatFee: 0.30,
        listingFee: 0.20,
      );
      expect(price, closeTo(22.50, 0.001));
    });
  });

  group("Componentes", () {
    test("custo por unidade de um íman vendido em pack de 100", () {
      // 7,50 € ÷ 100 = 0,075 €
      const magnet = Component(
        id: 1,
        name: "Íman de neodímio",
        kind: ComponentKind.component,
        packPrice: 7.50,
        unitsPerPack: 100,
      );
      expect(calc.componentUnitCost(magnet), closeTo(0.075, 0.0001));
    });
  });
}