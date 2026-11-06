import 'package:cubico_backoffice/features/costs/domain/shipping_rate.dart';
import 'package:cubico_backoffice/features/products/domain/variant.dart';
import 'component.dart';
import 'filament.dart';

/// Contas de custo. Dart puro, sem Flutter, para se poder testar sozinho.
class CostCalculator {
  const CostCalculator();

  /// Custo real por kg de um filamento: preço pago por rolo + a parte
  /// dos portes que cabe a esse rolo, a dividir pelo peso em kg.
  double filamentPricePerKg(Filament filament) {
    final shippingPerSpool = filament.shippingCost / filament.spoolsInOrder;
    final costPerSpool = filament.paidPrice + shippingPerSpool;
    return costPerSpool / (filament.spoolWeightG / 1000);
  }

  /// Custo do filamento gasto numa peça.
  double filamentCost({required double grams, required Filament filament}) {
    return grams * filamentPricePerKg(filament) / 1000;
  }

  double printerCostPerHour({
    required double powerW,
    required double kwhPrice,
    required double purchasePrice,
    required double lifespanHours,
    required double yearlyMaintenance,
    required double yearlyHours,
  }) {
    final electricity = powerW / 1000 * kwhPrice;
    final wear = purchasePrice / lifespanHours;
    final maintenance = yearlyMaintenance / yearlyHours;
    return electricity + wear + maintenance;
  }

  /// Custo de imprimir uma peça: minutos passados a horas × custo por hora.
  double printingCost({required double minutes, required double costPerHour}) {
    return minutes / 60 * costPerHour;
  }

  /// Taxas que o canal cobra numa venda: percentagens sobre o preço + fixos.
  double channelFees({
    required double price,
    required double transactionPct,
    required double processingPct,
    required double flatFee,
    required double listingFee,
  }) {
    final percentPart = price * (transactionPct + processingPct) / 100;
    return percentPart + flatFee + listingFee;
  }

  /// Margem de uma venda, em %: lucro a dividir pelo preço.
  double marginPct({
    required double price,
    required double productionCost,
    required double fees,
  }) {
    if (price <= 0) return 0;
    final profit = price - productionCost - fees;
    return profit / price * 100;
  }

  /// Preço que dá a margem alvo, já arredondado para cima.
  double suggestedPrice({
    required double productionCost,
    required double targetMarginPct,
    required double transactionPct,
    required double processingPct,
    required double flatFee,
    required double listingFee,
    double rounding = 0.50,
  }) {
    final keptPerEuro =
        1 - (transactionPct + processingPct) / 100 - targetMarginPct / 100;
    if (keptPerEuro <= 0) return 0; // margem impossível com estas taxas
    final rawPrice = (productionCost + flatFee + listingFee) / keptPerEuro;
    return (rawPrice / rounding).ceil() * rounding;
  }

  /// Custo de uma unidade de um componente ou embalagem: preço do pack ÷ unidades.
  double componentUnitCost(Component component) {
    return component.packPrice / component.unitsPerPack;
  }

  /// Custo de produção de uma variante: filamentos + impressão + componentes e embalagem.
  /// (Sem taxas do canal nem portes.)
  double variantProductionCost({
    required Variant variant,
    required List<Filament> filaments,
    required List<Component> components,
    required double costPerHour,
  }) {
    var total = 0.0;

    // filamentos: cada linha da receita
    for (final line in variant.filaments) {
      final filament = filaments
          .where((f) => f.id == line.filamentId)
          .firstOrNull;
      if (filament != null) {
        total += filamentCost(grams: line.grams.toDouble(), filament: filament);
      }
    }

    // impressão
    total += printingCost(
      minutes: variant.printTimeMin.toDouble(),
      costPerHour: costPerHour,
    );

    // componentes e embalagem: quantidade × custo por unidade
    for (final line in variant.components) {
      final component = components
          .where((c) => c.id == line.componentId)
          .firstOrNull;
      if (component != null) {
        total += line.quantity * componentUnitCost(component);
      }
    }

    return total;
  }

  /// O preço do envio para um peso, numa zona: o primeiro escalão dessa zona
  /// (do mais leve para o mais pesado) que aguenta o peso.
  /// null = mais pesado do que todos os escalões, ou zona sem escalões.
  double? shippingPrice({
    required int weightG,
    required int zoneId,
    required List<ShippingRate> rates,
  }) {
    final sorted = rates.where((r) => r.zoneId == zoneId).toList()
      ..sort((a, b) => a.maxWeightG.compareTo(b.maxWeightG));
    for (final rate in sorted) {
      if (weightG <= rate.maxWeightG) return rate.price;
    }
    return null;
  }

  /// Peso de envio de uma variante: a peça + os componentes e a embalagem.
  int variantShippingWeightG({
    required Variant variant,
    required List<Component> components,
  }) {
    var total = variant.weightG;
    for (final line in variant.components) {
      final component = components.where((c) => c.id == line.componentId).firstOrNull;
      if (component != null) total += line.quantity * component.weightG;
    }
    return total;
  }
}