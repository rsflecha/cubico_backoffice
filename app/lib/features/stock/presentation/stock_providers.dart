import 'package:cubico_backoffice/core/api/api_client.dart';
import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:cubico_backoffice/features/costs/presentation/costs_providers.dart';
import 'package:cubico_backoffice/features/stock/data/api_stock_repository.dart';
import 'package:cubico_backoffice/features/stock/data/demo_stock_repository.dart';
import 'package:cubico_backoffice/features/stock/domain/filament_movement.dart';
import 'package:cubico_backoffice/features/stock/domain/filament_stock.dart';
import 'package:cubico_backoffice/features/stock/domain/stock_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Qual é o repositório do stock de filamento.
final stockRepositoryProvider = Provider<StockRepository>((ref) {
  if (ref.watch(demoModeProvider)) return DemoStockRepository(ref.watch(filamentRepositoryProvider));
  return ApiStockRepository(ref.watch(dioProvider));
});

/// O stock atual de todos os filamentos.
/// Depois de gravar, quem chama faz `ref.invalidate(filamentStockProvider)`.
final filamentStockProvider = FutureProvider<List<FilamentStock>>((ref) {
  return ref.watch(stockRepositoryProvider).fetchStock();
});

/// O histórico de movimentos de um filamento.
/// Depois de gravar, quem chama faz `ref.invalidate(filamentMovementsProvider(id))`.
final filamentMovementsProvider = FutureProvider.family<List<FilamentMovement>, int>((ref, filamentId) {
  return ref.watch(stockRepositoryProvider).fetchMovements(filamentId);
});
