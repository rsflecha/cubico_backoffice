import 'package:cubico_backoffice/features/costs/data/demo_component_repository.dart';
import 'package:cubico_backoffice/features/costs/data/demo_filament_repository.dart';
import 'package:cubico_backoffice/features/costs/domain/component.dart';
import 'package:cubico_backoffice/features/costs/domain/component_repository.dart';
import 'package:cubico_backoffice/features/costs/domain/filament.dart';
import 'package:cubico_backoffice/features/costs/domain/filament_repository.dart';
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

/// Custo por hora da impressora principal.
/// Valores fixos por agora; vão passar a vir de "Custos e preços".
final printerCostPerHourProvider = Provider<double>((ref) {
  return const CostCalculator().printerCostPerHour(
    powerW: 95,
    kwhPrice: 0.21,
    purchasePrice: 381.40,
    lifespanHours: 5000,
    yearlyMaintenance: 40,
    yearlyHours: 1500,
  );
});
