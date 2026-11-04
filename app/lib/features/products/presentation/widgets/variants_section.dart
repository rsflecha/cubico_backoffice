import 'package:cubico_backoffice/app/theme.dart';
import 'package:cubico_backoffice/features/costs/domain/cost_calculator.dart';
import 'package:cubico_backoffice/features/costs/presentation/costs_providers.dart';
import 'package:cubico_backoffice/features/products/presentation/products_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// A tabela "Variantes" de um produto, com o custo de produção de cada uma.
class VariantsSection extends ConsumerWidget {
  const VariantsSection({super.key, required this.productId});

  final int productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const calc = CostCalculator();
    final variants = ref.watch(variantsProvider(productId));
    final filaments = ref.watch(filamentsProvider).value ?? [];
    final components = ref.watch(componentsProvider).value ?? [];
    final perHour = ref.watch(printerCostPerHourProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Variantes", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            variants.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text("Erro: $error"),
              data: (list) {
                if (list.isEmpty) {
                  return const Text("Este produto ainda não tem variantes.");
                }
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text("Variante")),
                      DataColumn(label: Text("SKU")),
                      DataColumn(label: Text("Tempo")),
                      DataColumn(label: Text("Custo*"), numeric: true),
                      DataColumn(label: Text("Preço"), numeric: true),
                    ],
                    rows: [
                      for (final v in list)
                        DataRow(
                          cells: [
                            DataCell(Text(v.name)),
                            DataCell(Text(v.sku, style: AppTextStyles.mono)),
                            DataCell(Text("${(v.printTimeMin / 60).toStringAsFixed(1)} h")),
                            DataCell(Text(
                              "${calc.variantProductionCost(
                                variant: v,
                                filaments: filaments,
                                components: components,
                                costPerHour: perHour,
                              ).toStringAsFixed(2)} €",
                              style: AppTextStyles.mono,
                            )),
                            DataCell(Text(
                              "${v.salePrice.toStringAsFixed(2)} €",
                              style: AppTextStyles.mono,
                            )),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              "* Custo de produção: filamento + impressão + componentes + embalagem, "
                  "sem taxas do canal nem portes.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}