import 'package:cubico_backoffice/app/theme.dart';
import 'package:cubico_backoffice/features/orders/presentation/orders_providers.dart';
import 'package:cubico_backoffice/features/production/domain/print_job.dart';
import 'package:cubico_backoffice/features/production/presentation/production_providers.dart';
import 'package:cubico_backoffice/features/products/domain/variant.dart';
import 'package:cubico_backoffice/features/products/presentation/products_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// O nome de cada coluna.
extension _StatusLabel on PrintJobStatus {
  String get label => switch (this) {
    PrintJobStatus.queued => "Por imprimir",
    PrintJobStatus.printing => "A imprimir",
    PrintJobStatus.postProcessing => "Pós-processamento",
    PrintJobStatus.done => "Concluído",
  };
}

class ProductionScreen extends ConsumerWidget {
  const ProductionScreen({super.key});

  /// Move a tarefa para uma coluna (qualquer uma, para a frente ou para trás).
  Future<void> _moveTo(WidgetRef ref, PrintJob job, PrintJobStatus status) async {
    if (job.status == status) return;
    final now = DateTime.now();
    await ref.read(printJobRepositoryProvider).update(
      job.copyWith(
        status: status,
        // volta a "Por imprimir": apaga as horas
        startedAt: status == PrintJobStatus.queued
            ? null
            : status == PrintJobStatus.printing
            ? now
            : job.startedAt ?? now,
        finishedAt: status == PrintJobStatus.queued || status == PrintJobStatus.printing
            ? null
            : job.finishedAt ?? now,
      ),
    );
    // se a tarefa é de uma encomenda, acerta o estado dela
    final orderId = job.orderId;
    if (orderId != null) {
      await ref.read(productionServiceProvider).syncOrder(orderId);
      ref.invalidate(ordersProvider);
    }
    ref.invalidate(printJobsProvider);
  }

  /// O botão →: passa para a coluna seguinte.
  Future<void> _advance(WidgetRef ref, PrintJob job) async {
    final next = job.nextStatus;
    if (next != null) await _moveTo(ref, job, next);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(printJobsProvider);
    final variants = ref.watch(allVariantsProvider).value ?? <Variant>[];
    final isWide = MediaQuery.sizeOf(context).width >= 1100;

    return Scaffold(
      appBar: AppBar(title: const Text("Produção")),
      body: jobs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text("Erro: $error")),
        data: (list) {
          final columns = [
            for (final status in PrintJobStatus.values)
              _column(
                context,
                ref,
                status,
                list.where((j) => j.status == status).toList(),
                variants,
              ),
          ];

          // PC: 4 colunas lado a lado. Telemóvel: colunas a deslizar para o lado.
          return isWide
              ? Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final c in columns) ...[
                  Expanded(child: c),
                  const SizedBox(width: 16),
                ],
              ],
            ),
          )
              : ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            children: [
              for (final c in columns) ...[
                SizedBox(width: 280, child: c),
                const SizedBox(width: 12),
              ],
            ],
          );
        },
      ),
    );
  }

  /// Uma coluna do quadro: título, contagem e cartões.
  Widget _column(
      BuildContext context,
      WidgetRef ref,
      PrintJobStatus status,
      List<PrintJob> jobs,
      List<Variant> variants,
      ) {
    return DragTarget<PrintJob>(
      // só aceita tarefas que venham de OUTRA coluna
      onWillAcceptWithDetails: (details) => details.data.status != status,
      onAcceptWithDetails: (details) => _moveTo(ref, details.data, status),
      builder: (context, candidates, rejected) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // enquanto um cartão está por cima, a coluna acende
          color: candidates.isNotEmpty
              ? AppColors.orange.withValues(alpha: 0.10)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: candidates.isNotEmpty ? AppColors.orange : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          // ...o Column que já tens, igual
        ),
      ),
    );
  }

  /// O cartão de uma tarefa.
  Widget _card(BuildContext context, WidgetRef ref, PrintJob job, List<Variant> variants) {
    final variant = variants.where((v) => v.id == job.variantId).firstOrNull;
    final hours = job.estimatedMin ~/ 60;
    final minutes = job.estimatedMin % 60;
    final time = minutes == 0 ? "$hours h" : "$hours h $minutes";
    final isPrinting = job.status == PrintJobStatus.printing;

    final card = Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: isPrinting ? BorderSide(color: AppColors.orange, width: 2) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(status.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
                Text("${jobs.length}"),
              ],
            ),
            const SizedBox(height: 8),
            if (jobs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text("Vazio", style: TextStyle(color: Color(0xFF71717A))),
              ),
            for (final job in jobs) _card(context, ref, job, variants),
          ],
        ),
      ),
    );
    // o que fica "colado ao rato" enquanto se arrasta: o cartão, um pouco levantado
    final feedback = SizedBox(
      width: 260,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(10),
        child: card,
      ),
    );
// o que fica no sítio de onde saiu: o cartão, esbatido
    final ghost = Opacity(opacity: 0.3, child: card);

    final isWide = MediaQuery.sizeOf(context).width >= 1100;
    return isWide
        ? Draggable<PrintJob>(data: job, feedback: feedback, childWhenDragging: ghost, child: card)
        : LongPressDraggable<PrintJob>(
        data: job, feedback: feedback, childWhenDragging: ghost, child: card);
  }
}