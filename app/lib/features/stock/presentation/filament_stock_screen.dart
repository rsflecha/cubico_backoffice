import 'package:cubico_backoffice/app/theme.dart';
import 'package:cubico_backoffice/core/formatting.dart';
import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:cubico_backoffice/features/costs/domain/filament.dart';
import 'package:cubico_backoffice/features/costs/presentation/costs_providers.dart';
import 'package:cubico_backoffice/features/stock/domain/filament_movement.dart';
import 'package:cubico_backoffice/features/stock/presentation/stock_providers.dart';
import 'package:cubico_backoffice/features/stock/presentation/stock_screen.dart';
import 'package:cubico_backoffice/features/stock/presentation/widgets/adjustment_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// O histórico de um filamento (o livro de movimentos) e o botão «Acertar».
class FilamentStockScreen extends ConsumerWidget {
  const FilamentStockScreen({super.key, required this.filamentId});

  final int filamentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filaments = ref.watch(filamentsProvider);
    final stocks = ref.watch(filamentStockProvider);
    final movements = ref.watch(filamentMovementsProvider(filamentId));
    final user = ref.watch(sessionProvider);
    final isAdmin = user?.isAdmin ?? false; // botões de compra e acerto
    final canSeeCosts = user?.canSeeCosts ?? false; // preços

    final Filament? filament = filaments.value?.where((f) => f.id == filamentId).firstOrNull;
    final stock = stocks.value?.where((s) => s.filamentId == filamentId).firstOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(filament == null ? "Stock" : filamentLabel(filament))),
      body: (filaments.hasError || stocks.hasError)
          ? _LoadError(onRetry: () {
              ref.invalidate(filamentsProvider);
              ref.invalidate(filamentStockProvider);
              ref.invalidate(filamentMovementsProvider(filamentId));
            })
          : movements.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text("Erro: $error")),
        data: (list) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    stock == null ? "" : "${gramsText(stock.stockG)} em stock",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (isAdmin && filament != null && stock != null)
                  FilledButton(
                    onPressed: () => showAdjustmentDialog(context, filament: filament, currentStockG: stock.stockG),
                    child: const Text("Acertar"),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (list.isEmpty)
              const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Text("Ainda não há movimentos."))
            else
              Card(
                child: Column(children: [for (final m in list) _tile(m, canSeeCosts)]),
              ),
          ],
        ),
      ),
    );
  }

  /// "Compra · 5 rolos", "Consumo · tarefa #43"…
  String _title(FilamentMovement m) {
    final job = m.printJobId == null ? "" : " · tarefa #${m.printJobId}";
    return switch (m.type) {
      MovementType.purchase => "Compra · ${m.spools ?? 0} ${m.spools == 1 ? "rolo" : "rolos"}",
      MovementType.consumption => "Consumo$job",
      MovementType.failure => "Falha$job",
      MovementType.adjustment => "Acerto (pesado)",
      MovementType.reversal => "Estorno$job",
    };
  }

  /// As gramas com sinal e décimas: "+5000 g", "−86,4 g", "0 g".
  String _signed(double grams) {
    final g = roundGrams(grams);
    if (g == 0) return "0 g";
    return "${g > 0 ? "+" : "−"}${gramsText(g.abs())}";
  }

  Widget _tile(FilamentMovement m, bool canSeeCosts) {
    final d = m.createdAt.toLocal();
    final date = "${d.day.toString().padLeft(2, "0")}/${d.month.toString().padLeft(2, "0")}/${d.year}";
    final parts = <String>[date, m.userName ?? "automático"];
    // preços só para o administrador (a API também os esconde ao colaborador)
    final spools = m.spools ?? 0;
    if (canSeeCosts && m.type == MovementType.purchase && m.paidPrice != null && spools > 0) {
      parts.add(euroPer(m.paidPrice!, "rolo")); // paidPrice já é por rolo
    }
    final note = (m.note ?? "").trim();
    return ListTile(
      title: Text(_title(m)),
      subtitle: Text([parts.join(" · "), if (note.isNotEmpty) note].join("\n")),
      isThreeLine: note.isNotEmpty,
      trailing: Text(_signed(m.grams), style: AppTextStyles.mono.copyWith(fontWeight: FontWeight.w700)),
    );
  }
}

/// O que se mostra quando os filamentos ou o stock não carregam.
class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Não foi possível carregar o stock."),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text("Tentar outra vez")),
        ],
      ),
    );
  }
}
