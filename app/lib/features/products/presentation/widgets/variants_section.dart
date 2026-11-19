import 'package:cubico_backoffice/core/formatting.dart';
import 'package:cubico_backoffice/app/theme.dart';
import 'package:cubico_backoffice/features/costs/domain/cost_calculator.dart';
import 'package:cubico_backoffice/features/costs/presentation/costs_providers.dart';
import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:cubico_backoffice/features/products/domain/sku.dart';
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
    this.canLeave,
  });

  final int productId;
  final int? selectedVariantId; // qual está escolhida (para a pintar)
  final ValueChanged<Variant>? onSelect; // chamada quando se toca numa linha
  /// Antes de mudar de variante ou criar outra: a ficha pergunta se há alterações por gravar.
  /// Devolve false para ficar onde está.
  final Future<bool> Function()? canLeave;

  /// Escolhe outra variante, se a ficha deixar (não perde o que está escrito).
  Future<void> _select(Variant v) async {
    if (v.id == selectedVariantId) return;
    if (canLeave != null && !await canLeave!()) return;
    onSelect?.call(v);
  }

  /// Pergunta o nome (Hamilton, Verstappen…), cria a variante e escolhe-a no cartão de custo.
  /// A API copia-lhe o preço, o tempo, o peso e a receita da primeira variante.
  Future<void> _addVariant(BuildContext context, WidgetRef ref, List<Variant> current) async {
    final product = ref
        .read(productsProvider)
        .value
        ?.where((p) => p.id == productId)
        .firstOrNull;
    final name = await showDialog<String>(
      context: context,
      builder: (context) => _VariantNameDialog(
        productSku: product?.baseSku ?? "",
        hasUnnamed: current.any((v) => v.isUnnamed),
        siblingSkus: current.map((v) => v.sku).toList(),
      ),
    );
    if (name == null || !context.mounted) return; // cancelou
    // a nova copia a receita GRAVADA da primeira: o que está por gravar tem de ir antes
    if (canLeave != null && !await canLeave!()) return;
    if (!context.mounted) return;

    final Variant created;
    try {
      created = await ref
          .read(variantRepositoryProvider)
          .create(productId: productId, name: name);
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
  Future<void> _deleteVariant(
    BuildContext context,
    WidgetRef ref,
    Variant v,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Apagar \"${v.label}\"?"),
        content: const Text(
          "A variante e a receita dela desaparecem. Não dá para desfazer.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Apagar"),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(variantRepositoryProvider).delete(v.id);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("$error")));
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
                  child: Text(
                    "Variantes",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (isAdmin)
                  TextButton.icon(
                    onPressed: () => _addVariant(context, ref, variants.value ?? const []),
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
                // uma só (o próprio produto): não há tabela, a receita e o preço estão no cartão
                if (list.length <= 1) {
                  return Text(
                    "Sem variantes: vende-se como modelo único (receita e preço no cartão). "
                    "Junta variantes se houver versões com nomes, como Hamilton e Verstappen.",
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                }

                /// O custo de produção de uma variante.
                double costOf(Variant v) => calc.variantProductionCost(
                  variant: v,
                  filaments: filaments,
                  components: components,
                  costPerHour: perHour,
                );

                return LayoutBuilder(
                  builder: (context, constraints) => constraints.maxWidth < 560
                      // telemóvel: as 6 colunas não cabem (o custo e o preço nem se
                      // viam); cada variante é uma linha, com os valores à direita
                      ? Column(
                          children: [
                            for (final v in list) ...[
                              const Divider(height: 1),
                              ListTile(
                                contentPadding: const EdgeInsets.only(left: 4),
                                selected: v.id == selectedVariantId,
                                onTap: () => _select(v),
                                title: Text(v.label),
                                subtitle: Text(
                                  "${v.sku} · ${_formatHours(v.printTimeMin)}",
                                  style: AppTextStyles.mono.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          euro(v.salePrice),
                                          style: AppTextStyles.mono.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        if (canSeeCosts)
                                          Text(
                                            "custo ${euro(costOf(v))}*",
                                            style: AppTextStyles.mono.copyWith(
                                              fontSize: 11,
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (isAdmin)
                                      IconButton(
                                        tooltip: "Apagar variante",
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () =>
                                            _deleteVariant(context, ref, v),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth,
                            ),
                            child: DataTable(
                              showCheckboxColumn: false,
                              columnSpacing:
                                  32, // espaço entre colunas (era 56)
                              horizontalMargin:
                                  16, // espaço nas pontas (era 24)
                              columns: [
                                const DataColumn(label: Text("Variante")),
                                const DataColumn(label: Text("SKU")),
                                const DataColumn(label: Text("Tempo")),
                                if (canSeeCosts)
                                  const DataColumn(
                                    label: Text("Custo*"),
                                    numeric: true,
                                  ),
                                const DataColumn(
                                  label: Text("Preço"),
                                  numeric: true,
                                ),
                                if (isAdmin) const DataColumn(label: Text("")),
                              ],
                              rows: [
                                for (final v in list)
                                  DataRow(
                                    selected: v.id == selectedVariantId,
                                    onSelectChanged: (_) => _select(v),
                                    cells: [
                                      DataCell(Text(v.label)),
                                      DataCell(
                                        Text(v.sku, style: AppTextStyles.mono),
                                      ),
                                      DataCell(
                                        Text(_formatHours(v.printTimeMin)),
                                      ),
                                      if (canSeeCosts)
                                        DataCell(
                                          Text(
                                            euro(costOf(v)),
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
                                            icon: const Icon(
                                              Icons.delete_outline,
                                            ),
                                            onPressed: () =>
                                                _deleteVariant(context, ref, v),
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
            if (canSeeCosts && (variants.value?.length ?? 0) > 1) ...[
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
    //   é um espaço que não deixa partir a linha: "2 h" fica sempre junto
    return m == 0 ? "$h h" : "$h h $m";
  }
}

/// A janela "Nova variante": o nome, e o SKU que vai ficar (para ver antes de criar).
/// É um StatefulWidget que cria e deita fora o seu próprio controller.
class _VariantNameDialog extends StatefulWidget {
  const _VariantNameDialog({required this.productSku, required this.hasUnnamed, required this.siblingSkus});

  final String productSku;
  final List<String> siblingSkus; // os SKU das variantes que já existem (para o número seguinte)
  final bool hasUnnamed; // já há uma variante sem nome ("Modelo único")

  @override
  State<_VariantNameDialog> createState() => _VariantNameDialogState();
}

class _VariantNameDialogState extends State<_VariantNameDialog> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _create() {
    // com uma variante sem nome já criada, esta tem de ter nome (o SKU seria igual)
    if (widget.hasUnnamed && _name.text.trim().isEmpty) return;
    Navigator.pop(context, _name.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    // com nome: o número seguinte (CD3-NAT-01-03); sem nome: o SKU do produto
    final sku = variantSku(
      widget.productSku,
      _name.text.trim().isEmpty ? null : nextVariantNumber(widget.productSku, widget.siblingSkus),
    );
    final missingName = widget.hasUnnamed && _name.text.trim().isEmpty;
    return AlertDialog(
      title: const Text("Nova variante"),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              decoration: InputDecoration(
                labelText: "Nome",
                hintText: "Ex.: Hamilton",
                helperText: "SKU: $sku",
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _create(),
            ),
            const SizedBox(height: 12),
            Text(
              widget.hasUnnamed
                  ? "Este produto tem um \"Modelo único\". Dá-lhe também um nome (ex.: Hamilton) "
                      "no cartão de custo, para as variantes se distinguirem. A nova começa com a receita dele."
                  : "Começa com o preço, o tempo e a receita da primeira variante. Acerta o que mudar.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        FilledButton(
          onPressed: missingName ? null : _create,
          child: const Text("Criar"),
        ),
      ],
    );
  }
}
