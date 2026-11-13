import 'package:cubico_backoffice/app/theme.dart';
import 'package:cubico_backoffice/core/formatting.dart';
import 'package:cubico_backoffice/features/costs/domain/fixed_cost.dart';
import 'package:cubico_backoffice/features/costs/presentation/costs_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// O cartão dos custos fixos mensais: a lista, o total, e juntar, mudar ou apagar.
class FixedCostsCard extends ConsumerWidget {
  const FixedCostsCard({super.key});

  /// Corre uma gravação e mostra o erro, se houver.
  Future<void> _run(BuildContext context, WidgetRef ref, Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Não foi possível guardar: $error")),
        );
      }
      return;
    }
    ref.invalidate(fixedCostsProvider);
  }

  /// Abre a janela para criar (cost == null) ou mudar um custo fixo.
  Future<void> _edit(BuildContext context, WidgetRef ref, FixedCost? cost) async {
    final result = await showDialog<FixedCost>(
      context: context,
      builder: (context) => _FixedCostDialog(initial: cost),
    );
    if (result == null || !context.mounted) return;
    final repository = ref.read(fixedCostRepositoryProvider);
    await _run(
      context,
      ref,
      () => cost == null ? repository.create(result) : repository.update(result),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final costs = ref.watch(fixedCostsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: costs.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text("Erro: $error"),
          data: (list) {
            final total = list.fold(0.0, (sum, c) => sum + c.monthlyValue);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("Custos fixos (por mês)", style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  "Pagam-se todos os meses, venda-se muito ou pouco. "
                  "Não entram no lucro de cada encomenda: o Dashboard tira-os ao lucro do mês.",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                for (final c in list)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(c.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(euro(c.monthlyValue), style: AppTextStyles.mono),
                        IconButton(
                          tooltip: "Apagar",
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _run(
                            context,
                            ref,
                            () => ref.read(fixedCostRepositoryProvider).delete(c.id),
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _edit(context, ref, c),
                  ),
                const Divider(),
                Row(
                  children: [
                    const Expanded(
                      child: Text("Total por mês", style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    Text(
                      euro(total),
                      style: AppTextStyles.mono.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 48), // alinhado com os valores de cima (o espaço do caixote)
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => _edit(context, ref, null),
                    icon: const Icon(Icons.add),
                    label: const Text("Juntar custo fixo"),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// A janela de um custo fixo: tem os seus controllers, e deita-os fora no momento certo.
class _FixedCostDialog extends StatefulWidget {
  const _FixedCostDialog({this.initial});

  final FixedCost? initial;

  @override
  State<_FixedCostDialog> createState() => _FixedCostDialogState();
}

class _FixedCostDialogState extends State<_FixedCostDialog> {
  late final _name = TextEditingController(text: widget.initial?.name ?? "");
  late final _value = TextEditingController(
    text: widget.initial == null ? "" : decimalField(widget.initial!.monthlyValue),
  );

  @override
  void dispose() {
    _name.dispose();
    _value.dispose();
    super.dispose();
  }

  String? _error; // o problema a mostrar por baixo dos campos (null = nenhum)

  /// O que está mal no que foi escrito, ou null se está tudo bem.
  String? _problem(String name, double value) {
    if (name.isEmpty) return "Falta o nome.";
    if (value <= 0) return "O valor por mês tem de ser maior do que 0.";
    return null;
  }

  void _submit() {
    final name = _name.text.trim();
    final value = parseDecimal(_value.text);
    final problem = _problem(name, value);
    if (problem != null) {
      setState(() => _error = problem); // antes, "Guardar" não fazia nada e não dizia porquê
      return;
    }
    Navigator.pop(
      context,
      FixedCost(id: widget.initial?.id ?? 0, name: name, monthlyValue: value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? "Novo custo fixo" : "Custo fixo"),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              decoration: const InputDecoration(labelText: "Nome", hintText: "Ex.: Etsy Plus"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _value,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: "Valor por mês", suffixText: "€"),
              onSubmitted: (_) => _submit(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
        FilledButton(onPressed: _submit, child: const Text("Guardar")),
      ],
    );
  }
}
