import 'package:cubico_backoffice/features/costs/domain/component.dart';
import 'package:cubico_backoffice/features/costs/domain/cost_calculator.dart';
import 'package:cubico_backoffice/features/costs/domain/filament.dart';
import 'package:cubico_backoffice/features/costs/domain/shipping_rate.dart';
import 'package:cubico_backoffice/features/products/domain/variant.dart';
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
      expect(
        calc.filamentCost(grams: 50, filament: pla),
        closeTo(1.125, 0.001),
      );
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

    test("Etsy: as percentagens também caem sobre os portes cobrados", () {
      // (20 + 4,50) × 10,5% = 2,5725 + 0,30 + 0,20 = 3,0725 €
      final etsy = calc.channelFees(
        price: 20,
        shipping: 4.5,
        transactionPct: 6.5,
        processingPct: 4,
        flatFee: 0.30,
        listingFee: 0.20,
      );
      expect(etsy, closeTo(3.0725, 0.0001));
    });

    test("Etsy: a taxa de anúncio conta por unidade, o fixo uma vez", () {
      // 3 unidades a 10 €: 30 × 10,5% = 3,15 + 0,30 + 0,20 × 3 = 4,05 €
      final etsy = calc.channelFees(
        price: 30,
        units: 3,
        transactionPct: 6.5,
        processingPct: 4,
        flatFee: 0.30,
        listingFee: 0.20,
      );
      expect(etsy, closeTo(4.05, 0.0001));
    });

    test("Etsy: encomenda de 2 linhas soma o mesmo que a conta da encomenda inteira", () {
      // 2 × 10 € + 1 × 5 €, 4,50 € de portes: (25 + 4,50) × 10,5% + 0,30 + 0,20 × 3 = 3,9975 €
      // (os mesmos números do teste da API: 3,27 + 0,73 depois de arredondar cada linha)
      final first = calc.channelFees(
        price: 20,
        shipping: 4.5,
        units: 2,
        transactionPct: 6.5,
        processingPct: 4,
        flatFee: 0.30,
        listingFee: 0.20,
      );
      final second = calc.channelFees(
        price: 5,
        units: 1,
        transactionPct: 6.5,
        processingPct: 4,
        flatFee: 0,
        listingFee: 0.20,
      );
      expect(first, closeTo(3.2725, 0.0001));
      expect(second, closeTo(0.725, 0.0001));
      expect(first + second, closeTo(3.9975, 0.0001));
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
      final margin = calc.marginPct(price: 20, productionCost: 6, fees: 2.60);
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

    test("peso de envio: peça + componentes", () {
      // 120 g da peça + 2 ímanes de 1 g = 122 g
      const magnet = Component(
        id: 1, name: "Íman", kind: ComponentKind.component,
        weightG: 1, packPrice: 7.50, unitsPerPack: 100,
      );
      const variant = Variant(
        id: 1, productId: 1, name: "Teste", sku: "T", salePrice: 10, weightG: 120,
        components: [VariantComponent(componentId: 1, quantity: 2)],
      );
      expect(calc.variantShippingWeightG(variant: variant, components: [magnet]), 122);
    });
  });

  group("Portes", () {
    const rates = [
      // Portugal, Correio Registado (fora de ordem de propósito)
      ShippingRate(id: 3, zoneId: 1, maxWeightG: 2000, price: 8.93),
      ShippingRate(id: 1, zoneId: 1, maxWeightG: 100, price: 4.60),
      ShippingRate(id: 2, zoneId: 1, maxWeightG: 500, price: 5.40),
      // Europa, Correio Azul Internacional (só dois escalões, para o teste)
      ShippingRate(id: 4, carrierId: 2, zoneId: 2, maxWeightG: 100, price: 5.80),
      ShippingRate(id: 5, carrierId: 2, zoneId: 2, maxWeightG: 250, price: 7.55),
    ];

    test("um pacote leve paga o primeiro escalão da sua zona", () {
      expect(calc.shippingPrice(weightG: 80, zoneId: 1, rates: rates), 4.60);
      expect(calc.shippingPrice(weightG: 80, zoneId: 2, rates: rates), 5.80);
    });

    test("o limite do escalão está incluído", () {
      expect(calc.shippingPrice(weightG: 100, zoneId: 1, rates: rates), 4.60);
      expect(calc.shippingPrice(weightG: 101, zoneId: 1, rates: rates), 5.40);
    });

    test("sem escalão que aguente o peso, não há preço", () {
      expect(calc.shippingPrice(weightG: 2500, zoneId: 1, rates: rates), isNull);
      expect(calc.shippingPrice(weightG: 300, zoneId: 2, rates: rates), isNull);
    });

    test("uma zona sem escalões não tem preço", () {
      expect(calc.shippingPrice(weightG: 80, zoneId: 4, rates: rates), isNull);
    });
  });

  group("Cor escolhida na encomenda", () {
    // dourado a 40 €/kg, branco a 20 €/kg, preto (o pormenor) a 22,50 €/kg
    const gold = Filament(id: 7, material: "PLA", colorName: "Gold", listPrice: 40, paidPrice: 40);
    const white = Filament(id: 8, material: "PLA", colorName: "White", listPrice: 20, paidPrice: 20);
    const filaments = [pla, gold, white];
    // a bola: 100 g de dourado (a cor) + 10 g de preto (o pormenor)
    const ball = Variant(
      id: 1,
      productId: 1,
      name: "",
      sku: "CD3-DEC-01",
      salePrice: 10,
      filaments: [
        VariantFilament(filamentId: 1, grams: 10),
        VariantFilament(filamentId: 7, grams: 100),
      ],
    );
    double cost({int? color}) => calc.variantProductionCost(
          variant: ball,
          filaments: filaments,
          components: const [],
          costPerHour: 0,
          colorFilamentId: color,
        );

    test("o filamento principal é o que leva mais gramas", () {
      expect(calc.mainFilament(ball)?.filamentId, 7);
    });

    test("num empate de gramas, fica o de id mais baixo (como na API)", () {
      const tie = Variant(id: 2, productId: 1, name: "", sku: "X", salePrice: 1, filaments: [
        VariantFilament(filamentId: 8, grams: 50),
        VariantFilament(filamentId: 7, grams: 50),
      ]);
      expect(calc.mainFilament(tie)?.filamentId, 7);
    });

    test("sem cor escolhida: o custo da receita", () {
      // 100 g × 40 + 10 g × 22,50 = 4,00 + 0,225
      expect(cost(), closeTo(4.225, 0.0001));
    });

    test("em branco: as 100 g passam ao preço do branco, o pormenor fica", () {
      // 100 g × 20 + 10 g × 22,50 = 2,00 + 0,225
      expect(cost(color: 8), closeTo(2.225, 0.0001));
    });

    test("uma variante sem receita não muda", () {
      const empty = Variant(id: 3, productId: 1, name: "", sku: "Y", salePrice: 1);
      expect(calc.mainFilament(empty), isNull);
      expect(
        calc.variantProductionCost(
            variant: empty, filaments: filaments, components: const [], costPerHour: 0, colorFilamentId: 8),
        0,
      );
    });

    test("2 cores: as gramas da Cor 2 saem da principal e contam ao preço dela", () {
      // a árvore: 100 g, das quais 30 g são a Cor 2
      const tree = Variant(id: 4, productId: 1, name: "", sku: "Z", salePrice: 1, gramsColor2: 30,
          filaments: [VariantFilament(filamentId: 7, grams: 100)]);
      // Cor 1 branco (70 g × 20) + Cor 2 dourado (30 g × 40) = 1,40 + 1,20
      expect(calc.variantProductionCost(variant: tree, filaments: filaments, components: const [],
          costPerHour: 0, colorFilamentId: 8, color2FilamentId: 7), closeTo(2.60, 0.0001));
    });

    test("2 cores sem as gramas da Cor 2: a mais cara das duas", () {
      const tree = Variant(id: 5, productId: 1, name: "", sku: "Z", salePrice: 1,
          filaments: [VariantFilament(filamentId: 7, grams: 100)]);
      // 100 g ao preço do dourado (o mais caro): 4,00
      expect(calc.variantProductionCost(variant: tree, filaments: filaments, components: const [],
          costPerHour: 0, colorFilamentId: 8, color2FilamentId: 7), closeTo(4.00, 0.0001));
    });
  });

  test("as gramas com decimais contam no custo", () {
    // 86,4 g de PLA a 22,50 €/kg = 1,944 € (com 86 g dava 1,935 €)
    const piece = Variant(id: 9, productId: 1, name: "", sku: "Z", salePrice: 1,
        filaments: [VariantFilament(filamentId: 1, grams: 86.4)]);
    expect(calc.variantProductionCost(variant: piece, filaments: const [pla], components: const [], costPerHour: 0),
        closeTo(1.944, 0.0001));
  });
}
