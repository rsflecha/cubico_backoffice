import 'package:cubico_backoffice/features/costs/data/demo_filament_repository.dart';
import 'package:cubico_backoffice/features/costs/domain/filament.dart';
import 'package:cubico_backoffice/features/costs/domain/filament_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Placa 1: qual é o repositório dos filamentos.
final filamentRepositoryProvider = Provider<FilamentRepository>((ref) {
  return DemoFilamentRepository();
});

/// Placa 2: a lista de filamentos, vinda do repositório.
final filamentsProvider = FutureProvider<List<Filament>>((ref) {
  final repository = ref.watch(filamentRepositoryProvider);
  return repository.fetchAll();
});