import 'dart:async';
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

          // a primeira tarefa a imprimir (se houver)
          final printing = list.where((j) => j.status == PrintJobStatus.printing).firstOrNull;
          final printingVariant =
              variants.where((v) => v.id == printing?.variantId).firstOrNull;

          final banner = _PrintingBanner(
            // a key muda quando muda a tarefa a imprimir, e o cartão recomeça
            key: ValueKey(printing?.id),
            job: printing,
            title: printingVariant?.name ?? "",
          );

          // PC: 4 colunas lado a lado. Telemóvel: colunas a deslizar para o lado.
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: banner,
              ),
              Expanded(
                child: isWide
                    ? SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < columns.length; i++) ...[
                        if (i > 0) const SizedBox(width: 16),
                        Expanded(child: columns[i]),
                      ],
                    ],
                  ),
                )
                    : ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (var i = 0; i < columns.length; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      SizedBox(width: 280, child: SingleChildScrollView(child: columns[i])),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Uma coluna do quadro: aceita cartões largados, e mostra título, contagem e cartões.
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
  }

  /// O cartão de uma tarefa, que se pode arrastar para outra coluna.
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

    // no PC arrasta-se logo; no telemóvel é preciso manter o dedo, para não estragar o deslizar
    final isWide = MediaQuery.sizeOf(context).width >= 1100;
    return isWide
        ? Draggable<PrintJob>(
      data: job,
      feedback: feedback,
      childWhenDragging: ghost,
      child: card,
    )
        : LongPressDraggable<PrintJob>(
      data: job,
      feedback: feedback,
      childWhenDragging: ghost,
      child: card,
    );
  }
}

/// O cartão escuro do topo: a tarefa a imprimir, com o progresso a avançar sozinho.
class _PrintingBanner extends StatefulWidget {
  const _PrintingBanner({super.key, required this.job, required this.title});

  final PrintJob? job; // null = a impressora está livre
  final String title;

  @override
  State<_PrintingBanner> createState() => _PrintingBannerState();
}

class _PrintingBannerState extends State<_PrintingBanner> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // de 30 em 30 segundos, redesenha para o progresso avançar
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel(); // sem isto, o relógio continuava a tocar depois de saíres do ecrã
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    const white = TextStyle(color: Colors.white);
    const muted = TextStyle(color: Colors.white70);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: job == null
          ? const Text("Bambu Lab A1 · livre. Arrasta uma tarefa para «A imprimir».", style: muted)
          // LayoutBuilder: diz quanto espaço o cartão tem de facto (não o ecrã inteiro)
          : LayoutBuilder(builder: (context, constraints) {
        final now = DateTime.now();
        final progress = job.progressAt(now);
        final left = job.minutesLeftAt(now);

        final info = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Bambu Lab A1 · a imprimir", style: muted),
            const SizedBox(height: 4),
            Text(
              widget.title,
              style: white.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            Text(
              job.orderNumber == null
                  ? "Tarefa manual"
                  : "Encomenda #${job.orderNumber}",
              style: muted,
            ),
          ],
        );
        final bar = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text("${(progress * 100).round()}%",
                    style: white.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                Text(
                  left == 0
                      ? "deve ter acabado"
                      : "faltam ${left ~/ 60} h ${left % 60} min",
                  style: muted,
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              color: AppColors.orange,
              backgroundColor: Colors.white24,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        );

        // estreito (telemóvel): um por baixo do outro. Antes, ficavam lado a lado e a barra
        // tinha 260 px fixos: num ecrã de 375 px o texto ficava sem espaço e partia letra a letra.
        if (constraints.maxWidth < 560) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [info, const SizedBox(height: 16), bar],
          );
        }
        return Row(
          children: [
            Expanded(child: info),
            const SizedBox(width: 24),
            SizedBox(width: 260, child: bar),
          ],
        );
      }),
    );
  }
}