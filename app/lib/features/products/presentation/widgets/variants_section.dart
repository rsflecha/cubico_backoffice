import 'package:cubico_backoffice/core/formatting.dart';
import 'package:cubico_backoffice/app/theme.dart';
import 'package:cubico_backoffice/features/costs/domain/cost_calculator.dart';
import 'package:cubico_backoffice/features/costs/presentation/costs_providers.dart';
import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:cubico_backoffice/features/products/presentation/products_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:cubico_backoffice/features/products/domain/variant.dart';

/// A tabela "Variantes" de um produto, com o custo de produção de cada uma.
class VariantsSection extends ConsumerWidget {
  const VariantsSection({
    super.key,
    required this.productId,
    this.selectedVariantId,
    this.onSelect,
  });

  final int productId;
  final int? selectedVariantId; // qual está escolhida (para a pintar)
  final ValueChanged<Variant>? onSelect; // chamada quando se toca numa linha

  /// Cria uma variante vazia e escolhe-a, para se preencher no cartão de custo.
  Future<void> _addVariant(BuildContext context, WidgetRef ref) async {
    final Variant created;
    try {
      created = await ref.read(variantRepositoryProvider).create(productId: productId);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Não foi possível criar a variante: $error")),
        );
      }
      return;
    }
    ref.invalidate(variantsProvider(productId));
    ref.invalidate(allVariantsProvider);
    onSelect?.call(created);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const calc = CostCalculator();
    final variants = ref.watch(variantsProvider(productId));
    final filaments = ref.watch(filamentsProvider).value ?? [];
    final components = ref.watch(componentsProvider).value ?? [];
    final perHour = ref.watch(printerCostPerHourProvider);
    // o colaborador não vê o custo de produção
    final canSeeCosts = ref.watch(sessionProvider)?.canSeeCosts ?? false;
    final isAdmin = ref.watch(sessionProvider)?.isAdmin ?? false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text("Variantes", style: Theme.of(context).textTheme.titleMedium),
                ),
                if (isAdmin)
                  TextButton.icon(
                    onPressed: () => _addVariant(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text("Adicionar variante"),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            variants.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text("Erro: $error"),
              data: (list) {
                if (list.isEmpty) {
                  return const Text("Este produto ainda não tem variantes.");
                }
                return LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                      ),
                      child: DataTable(
                        showCheckboxColumn: false,
                        columnSpacing: 32, // espaço entre colunas (era 56)
                        horizontalMargin: 16, // espaço nas pontas (era 24)
                        columns: [
                          const DataColumn(label: Text("Variante")),
                          const DataColumn(label: Text("SKU")),
                          const DataColumn(label: Text("Tempo")),
                          if (canSeeCosts) const DataColumn(label: Text("Custo*"), numeric: true),
                          const DataColumn(label: Text("Preço"), numeric: true),
                        ],
                        rows: [
                          for (final v in list)
                            DataRow(
                              selected: v.id == selectedVariantId,
                              onSelectChanged: (_) => onSelect?.call(v),
                              cells: [
                                DataCell(Text(v.name)),
                                DataCell(
                                  Text(v.sku, style: AppTextStyles.mono),
                                ),
                                DataCell(Text(_formatHours(v.printTimeMin))),
                                if (canSeeCosts)
                                DataCell(
                                  Text(
                                    euro(
                                      calc.variantProductionCost(
                                        variant: v,
                                        filaments: filaments,
                                        components: components,
                                        costPerHour: perHour,
                                      ),
                                    ),
                                    style: AppTextStyles.mono,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    euro(v.salePrice),
                                    style: AppTextStyles.mono,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            if (canSeeCosts) ...[
              const SizedBox(height: 8),
              Text(
                "* Custo de produção: filamento + impressão + componentes + embalagem, "
                "sem taxas do canal nem portes.",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 300 min → "5 h"; 330 min → "5 h 30"
  String _formatHours(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? "$h h" : "$h h $m";
  }
}
