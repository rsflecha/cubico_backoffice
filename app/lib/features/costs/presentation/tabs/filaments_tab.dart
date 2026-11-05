import 'package:cubico_backoffice/app/theme.dart';
import 'package:cubico_backoffice/core/colors.dart';
import 'package:cubico_backoffice/core/formatting.dart';
import 'package:cubico_backoffice/features/costs/domain/cost_calculator.dart';
import 'package:cubico_backoffice/features/costs/domain/filament.dart';
import 'package:cubico_backoffice/features/costs/presentation/costs_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Separador "Filamentos": a tabela com o custo real de cada rolo.
class FilamentsTab extends ConsumerWidget {
  const FilamentsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filaments = ref.watch(filamentsProvider);

    return filaments.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text("Erro: $error")),
      data: (list) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Filamentos", style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    "A app usa sempre o preço que pagaste, mais a parte dos portes de cada rolo. "
                        "O preço normal fica como referência, para veres quanto poupaste.",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  if (list.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text("Ainda não há filamentos."),
                    )
                  else
                    _table(list),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _table(List<Filament> list) {
    const calc = CostCalculator();

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: DataTable(
            columnSpacing: 24,
            horizontalMargin: 8,
            columns: const [
              DataColumn(label: Text("Tipo")),
              DataColumn(label: Text("Marca")),
              DataColumn(label: Text("Cor")),
              DataColumn(label: Text("Rolo"), numeric: true),
              DataColumn(label: Text("Preço normal"), numeric: true),
              DataColumn(label: Text("Preço pago"), numeric: true),
              DataColumn(label: Text("Portes por rolo"), numeric: true),
              DataColumn(label: Text("€/kg"), numeric: true),
            ],
            rows: [
              for (final f in list)
                DataRow(
                  cells: [
                    DataCell(Text(f.material)),
                    DataCell(Text(f.brand ?? "—")),
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(radius: 6, backgroundColor: colorFromHex(f.colorHex)),
                        const SizedBox(width: 8),
                        Text(f.colorName),
                      ],
                    )),
                    DataCell(Text(
                      f.spoolWeightG >= 1000
                          ? "${(f.spoolWeightG / 1000).toStringAsFixed(f.spoolWeightG % 1000 == 0 ? 0 : 1)} kg"
                          : "${f.spoolWeightG} g",
                    )),
                    DataCell(Text(
                      euro(f.listPrice),
                      style: AppTextStyles.mono.copyWith(
                        color: const Color(0xFF71717A),
                        // riscado só quando houve desconto
                        decoration: f.discountPct > 0 ? TextDecoration.lineThrough : null,
                      ),
                    )),
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (f.discountPct > 0) ...[
                          _DiscountBadge(f.discountPct),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          euro(f.paidPrice),
                          style: AppTextStyles.mono.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    )),
                    DataCell(Text(
                      euro(f.shippingCost / f.spoolsInOrder),
                      style: AppTextStyles.mono.copyWith(
                        color: f.shippingCost == 0 ? const Color(0xFF71717A) : null,
                      ),
                    )),
                    DataCell(Text(
                      euro(calc.filamentPricePerKg(f)),
                      style: AppTextStyles.mono.copyWith(fontWeight: FontWeight.w700),
                    )),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A etiqueta verde com a percentagem poupada: "-30%".
class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge(this.pct);

  final double pct;

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF15803D);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        "-${pct.toStringAsFixed(0)}%",
        style: const TextStyle(color: green, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}