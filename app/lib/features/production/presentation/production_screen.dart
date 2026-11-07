import 'package:cubico_backoffice/app/theme.dart';
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

  /// Passa a tarefa para a coluna seguinte.
  Future<void> _advance(WidgetRef ref, PrintJob job) async {
    final next = job.nextStatus;
    if (next == null) return;
    final now = DateTime.now();
    await ref.read(printJobRepositoryProvider).update(
      job.copyWith(
        status: next,
        // ao começar a imprimir, guarda a hora; ao sair da impressora, também
        startedAt: next == PrintJobStatus.printing ? now : job.startedAt,
        finishedAt: next == PrintJobStatus.postProcessing ? now : job.finishedAt,
      ),
    );
    ref.invalidate(printJobsProvider);
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
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
    );
  }

  /// O cartão de uma tarefa.
  Widget _card(BuildContext context, WidgetRef ref, PrintJob job, List<Variant> variants) {
    final variant = variants.where((v) => v.id == job.variantId).firstOrNull;
    final hours = job.estimatedMin ~/ 60;
    final minutes = job.estimatedMin % 60;
    final time = minutes == 0 ? "$hours h" : "$hours h $minutes";
    final isPrinting = job.status == PrintJobStatus.printing;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: isPrinting ? BorderSide(color: AppColors.orange, width: 2) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              variant?.name ?? "Variante ${job.variantId}",
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              "${job.quantity} un. · $time",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (job.notes != null)
              Text(job.notes!, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 6),
            Row(
              children: [
                if (job.orderNumber != null)
                  InkWell(
                    onTap: () => context.push("/orders/${job.orderId}"),
                    child: Text(
                      "#${job.orderNumber}",
                      style: AppTextStyles.mono.copyWith(
                        color: AppColors.orange,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                else
                  const Text("Manual", style: TextStyle(color: Color(0xFF71717A))),
                const Spacer(),
                if (job.nextStatus != null)
                  IconButton(
                    tooltip: "Passar a «${job.nextStatus!.label}»",
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _advance(ref, job),
                    icon: const Icon(Icons.arrow_forward),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}