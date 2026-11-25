import 'package:cubico_backoffice/core/api/api_client.dart';
import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:cubico_backoffice/features/production/data/api_print_job_repository.dart';
import 'package:cubico_backoffice/features/orders/domain/order.dart';
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

/// As tarefas de impressão do quadro.
///
/// As de encomendas canceladas que ainda não foram impressas não aparecem (não se apagam:
/// ficam na base). As já concluídas continuam, porque a peça foi mesmo impressa.
final printJobsProvider = FutureProvider<List<PrintJob>>((ref) async {
  final jobs = await ref.watch(printJobRepositoryProvider).fetchAll();
  final List<Order> orders;
  try {
    orders = await ref.watch(ordersProvider.future);
  } catch (_) {
    return jobs; // sem as encomendas, mostra tudo (melhor do que um quadro vazio)
  }
  final cancelled = {
    for (final o in orders)
      if (o.status == OrderStatus.cancelled) o.id,
  };
  return [
    for (final j in jobs)
      if (!cancelled.contains(j.orderId) || j.status == PrintJobStatus.done) j,
  ];
});

/// As regras que ligam encomendas e produção.
final productionServiceProvider = Provider<ProductionService>((ref) {
  return ProductionService(
    ref.watch(printJobRepositoryProvider),
    ref.watch(orderRepositoryProvider),
  );
});