import 'package:cubico_backoffice/features/costs/data/demo_filament_repository.dart';
import 'package:cubico_backoffice/features/costs/domain/filament.dart';
import 'package:cubico_backoffice/features/costs/domain/filament_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/demo_sales_channel_repository.dart';
import '../domain/sales_channel.dart';
import '../domain/sales_channel_repository.dart';

/// Placa 1: qual é o repositório dos filamentos.
final filamentRepositoryProvider = Provider<FilamentRepository>((ref) {
  return DemoFilamentRepository();
});

/// Placa 2: a lista de filamentos, vinda do repositório.
final filamentsProvider = FutureProvider<List<Filament>>((ref) {
  final repository = ref.watch(filamentRepositoryProvider);
  return repository.fetchAll();
});

/// Placa 3: qual é o repositório dos canais de venda.
final salesChannelRepositoryProvider = Provider<SalesChannelRepository>((ref) {
  return DemoSalesChannelRepository();
});

/// Placa 4: a lista de canais de venda.
final salesChannelsProvider = FutureProvider<List<SalesChannel>>((ref) {
  final repository = ref.watch(salesChannelRepositoryProvider);
  return repository.fetchAll();
});