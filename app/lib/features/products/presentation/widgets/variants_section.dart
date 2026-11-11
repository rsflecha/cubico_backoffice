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
      final repository = ref.read(variantRepositoryProvider);
      final draft = await repository.create(productId: productId);
      // dá-lhe logo o nome do filamento que o cartão de custo vai mostrar (o primeiro da lista)
      final first = ref.read(filamentsProvider).value?.firstOrNull;
      created = first == null
          ? draft
          : await repository.update(draft.copyWith(name: first.displayName));
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

  /// Pergunta, e apaga a variante.
  Future<void> _deleteVariant(BuildContext context, WidgetRef ref, Variant v) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Apagar \"${v.name}\"?"),
        content: const Text("A variante e a receita dela desaparecem. Não dá para desfazer."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text("Apagar")),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(variantRepositoryProvider).delete(v.id);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$error")));
      }
      return;
    }
    ref.invalidate(variantsProvider(productId));
    ref.invalidate(allVariantsProvider);
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
                          if (isAdmin) const DataColumn(label: Text("")),
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
                                // o caixote, só para o administrador (a coluna também tem o mesmo if)
                                if (isAdmin)
                                  DataCell(
                                    IconButton(
                                      tooltip: "Apagar variante",
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () => _deleteVariant(context, ref, v),
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
