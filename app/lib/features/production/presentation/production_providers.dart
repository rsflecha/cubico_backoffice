import 'package:cubico_backoffice/features/production/data/demo_print_job_repository.dart';
import 'package:cubico_backoffice/features/production/domain/print_job.dart';
import 'package:cubico_backoffice/features/production/domain/print_job_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Qual é o repositório das tarefas de impressão.
final printJobRepositoryProvider = Provider<PrintJobRepository>((ref) {
  return DemoPrintJobRepository();
});

/// Todas as tarefas de impressão.
final printJobsProvider = FutureProvider<List<PrintJob>>((ref) {
  return ref.watch(printJobRepositoryProvider).fetchAll();
});