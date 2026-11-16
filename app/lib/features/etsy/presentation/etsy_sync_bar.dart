import 'package:cubico_backoffice/core/api/api_exception.dart';
import 'package:cubico_backoffice/features/etsy/domain/etsy_sync.dart';
import 'package:cubico_backoffice/features/etsy/presentation/etsy_providers.dart';
import 'package:cubico_backoffice/features/orders/presentation/orders_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// A barra da Etsy, no topo das Encomendas: "Etsy · há 5 min · Sincronizar agora".
/// Só aparece com a loja ligada.
class EtsySyncBar extends ConsumerStatefulWidget {
  const EtsySyncBar({super.key});

  @override
  ConsumerState<EtsySyncBar> createState() => _EtsySyncBarState();
}

class _EtsySyncBarState extends ConsumerState<EtsySyncBar> {
  var _busy = false; // a sincronizar: o botão fica parado e roda

  Future<void> _sync() async {
    setState(() => _busy = true);
    EtsySyncRun? run;
    Object? error;
    try {
      run = await ref.read(etsyRepositoryProvider).syncNow();
    } catch (e) {
      error = e;
    }
    if (!mounted) return;
    setState(() => _busy = false);
    // a barra e a lista vão buscar tudo outra vez (há encomendas novas, ou um erro para mostrar)
    ref.invalidate(etsySyncInfoProvider);
    ref.invalidate(ordersProvider);

    final messenger = ScaffoldMessenger.of(context);
    if (run == null) {
      messenger.showSnackBar(SnackBar(
        content: Text(error is ApiException ? error.message : "Não foi possível sincronizar."),
      ));
      return;
    }
    messenger.showSnackBar(SnackBar(content: Text(_summary(run))));
    if (run.skippedCount > 0) await _showSkipped(run);
  }

  /// "2 novas, 1 atualizada" (ou "Nada de novo").
  String _summary(EtsySyncRun run) {
    final parts = [
      if (run.createdCount > 0) "${run.createdCount} ${run.createdCount == 1 ? "nova" : "novas"}",
      if (run.updatedCount > 0) "${run.updatedCount} ${run.updatedCount == 1 ? "atualizada" : "atualizadas"}",
      if (run.skippedCount > 0) "${run.skippedCount} por associar",
    ];
    return parts.isEmpty ? "Etsy: nada de novo." : "Etsy: ${parts.join(", ")}.";
  }

  /// As encomendas que não entraram, e porquê (o SKU não existe no backoffice).
  Future<void> _showSkipped(EtsySyncRun run) => showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("${run.skippedCount} por associar"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Estas encomendas ainda não entraram: os artigos não têm uma variante "
                  "com o mesmo SKU no backoffice. Cria o produto (ou acerta o SKU na Etsy) "
                  "e sincroniza outra vez.",
                ),
                const SizedBox(height: 12),
                for (final line in (run.notes ?? "").split("\n").where((l) => l.trim().isNotEmpty))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text("• $line"),
                  ),
              ],
            ),
          ),
          actions: [
            FilledButton(onPressed: () => Navigator.pop(context), child: const Text("Percebi")),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(etsySyncInfoProvider).value;
    // sem loja ligada (ou ainda a carregar), a barra não aparece
    if (info == null || !info.connected) return const SizedBox.shrink();

    final last = info.last;
    final scheme = Theme.of(context).colorScheme;
    String text;
    Color? color;
    if (last == null) {
      text = "Etsy · ainda não sincronizou";
    } else if (last.status == "error") {
      text = "Etsy · a última sincronização falhou (${timeAgo(last.startedAt, DateTime.now())}): ${last.errorMessage ?? ""}";
      color = scheme.error;
    } else {
      text = "Etsy · ${timeAgo(last.finishedAt ?? last.startedAt, DateTime.now())}";
      if (last.skippedCount > 0) text += " · ${last.skippedCount} por associar";
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Icon(Icons.storefront_outlined, size: 18, color: color ?? scheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              // com encomendas por associar, tocar no texto mostra quais
              onTap: last != null && last.skippedCount > 0 ? () => _showSkipped(last) : null,
              child: Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
              ),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: _busy ? null : _sync,
            icon: _busy
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.sync, size: 18),
            label: Text(_busy ? "A sincronizar…" : "Sincronizar agora"),
          ),
        ],
      ),
    );
  }
}
