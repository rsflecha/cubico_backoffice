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
    required double yearlyHours
  }){
    final electricity = powerW / 1000 * kwhPrice;
    final wear = purchasePrice / lifespanHours;
    final maintenance = yearlyMaintenance / yearlyHours;
    return electricity + wear + maintenance;
  }

  /// Custo de imprimir uma peça: minutos passados a horas × custo por hora.
  double printingCost({required double minutes, required double costPerHour}) {
    return minutes / 60 * costPerHour;
  }
}