import 'package:cubico_backoffice/core/api/api_client.dart';
import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:cubico_backoffice/features/production/data/api_print_job_repository.dart';
import 'package:cubico_backoffice/features/orders/presentation/orders_providers.dart';
import 'package:cubico_backoffice/features/production/data/demo_print_job_repository.dart';
import 'package:cubico_backoffice/features/production/domain/print_job.dart';
import 'package:cubico_backoffice/features/production/domain/print_job_repository.dart';
import 'package:cubico_backoffice/features/production/domain/production_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Qual é o repositório das tarefas de impressão.
final printJobRepositoryProvider = Provider<PrintJobRepository>((ref) {
  if (ref.watch(demoModeProvider)) return DemoPrintJobRepository();
  return ApiPrintJobRepository(ref.watch(dioProvider));
});

/// Todas as tarefas de impressão.
final printJobsProvider = FutureProvider<List<PrintJob>>((ref) {
  return ref.watch(printJobRepositoryProvider).fetchAll();
});

/// As regras que ligam encomendas e produção.
final productionServiceProvider = Provider<ProductionService>((ref) {
  return ProductionService(
    ref.watch(printJobRepositoryProvider),
    ref.watch(orderRepositoryProvider),
  );
});