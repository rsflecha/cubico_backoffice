import 'package:cubico_backoffice/features/costs/data/demo_component_repository.dart';
import 'package:cubico_backoffice/features/costs/data/demo_cost_settings_repository.dart';
import 'package:cubico_backoffice/features/costs/data/demo_filament_repository.dart';
import 'package:cubico_backoffice/features/costs/data/demo_printer_repository.dart';
import 'package:cubico_backoffice/features/costs/domain/component.dart';
import 'package:cubico_backoffice/features/costs/domain/component_repository.dart';
import 'package:cubico_backoffice/features/costs/domain/cost_settings.dart';
import 'package:cubico_backoffice/features/costs/domain/cost_settings_repository.dart';
import 'package:cubico_backoffice/features/costs/domain/filament.dart';
import 'package:cubico_backoffice/features/costs/domain/filament_repository.dart';
import 'package:cubico_backoffice/features/costs/domain/printer.dart';
import 'package:cubico_backoffice/features/costs/domain/printer_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cubico_backoffice/features/costs/data/demo_sales_channel_repository.dart';
import 'package:cubico_backoffice/features/costs/domain/cost_calculator.dart';
import 'package:cubico_backoffice/features/costs/domain/sales_channel.dart';
import 'package:cubico_backoffice/features/costs/domain/sales_channel_repository.dart';

/// Qual é o repositório dos filamentos.
final filamentRepositoryProvider = Provider<FilamentRepository>((ref) {
  return DemoFilamentRepository();
});

/// A lista de filamentos, vinda do repositório.
final filamentsProvider = FutureProvider<List<Filament>>((ref) {
  final repository = ref.watch(filamentRepositoryProvider);
  return repository.fetchAll();
});

/// Qual é o repositório dos canais de venda.
final salesChannelRepositoryProvider = Provider<SalesChannelRepository>((ref) {
  return DemoSalesChannelRepository();
});

/// A lista de canais de venda.
final salesChannelsProvider = FutureProvider<List<SalesChannel>>((ref) {
  final repository = ref.watch(salesChannelRepositoryProvider);
  return repository.fetchAll();
});

/// Qual é o repositório dos componentes e embalagens.
final componentRepositoryProvider = Provider<ComponentRepository>((ref) {
  return DemoComponentRepository();
});

/// A lista de componentes e embalagens.
final componentsProvider = FutureProvider<List<Component>>((ref) {
  final repository = ref.watch(componentRepositoryProvider);
  return repository.fetchAll();
});

/// Custo por hora da impressora principal: luz + desgaste + manutenção.
/// Calculado a partir das definições e da impressora principal.
final printerCostPerHourProvider = Provider<double>((ref) {
  final settings = ref.watch(costSettingsProvider).value;
  final printers = ref.watch(printersProvider).value ?? [];
  final printer = printers.where((p) => p.isDefault).firstOrNull ?? printers.firstOrNull;

  // enquanto os dados não chegam, o custo por hora é 0
  if (settings == null || printer == null) return 0;

  return const CostCalculator().printerCostPerHour(
    powerW: printer.powerW.toDouble(),
    kwhPrice: settings.kwhPrice,
    purchasePrice: printer.purchasePrice,
    lifespanHours: printer.lifespanHours.toDouble(),
    yearlyMaintenance: printer.yearlyMaintenance,
    yearlyHours: printer.yearlyHours.toDouble(),
  );
});

/// Qual é o repositório das impressoras.
final printerRepositoryProvider = Provider<PrinterRepository>((ref) {
  return DemoPrinterRepository();
});

/// A lista de impressoras.
final printersProvider = FutureProvider<List<Printer>>((ref) {
  return ref.watch(printerRepositoryProvider).fetchAll();
});

/// Qual é o repositório das definições de custos.
final costSettingsRepositoryProvider = Provider<CostSettingsRepository>((ref) {
  return DemoCostSettingsRepository();
});

/// As definições de custos e preços.
final costSettingsProvider = FutureProvider<CostSettings>((ref) {
  return ref.watch(costSettingsRepositoryProvider).fetch();
});