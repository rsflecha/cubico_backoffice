import 'package:cubico_backoffice/app/theme.dart';
import 'package:cubico_backoffice/core/formatting.dart';
import 'package:cubico_backoffice/features/costs/domain/component.dart';
import 'package:cubico_backoffice/features/costs/domain/cost_calculator.dart';
import 'package:cubico_backoffice/features/costs/presentation/costs_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Separador "Embalagens e componentes": a tabela com o custo de cada unidade, e o formulário.
class ComponentsTab extends ConsumerStatefulWidget {
  const ComponentsTab({super.key});

  @override
  ConsumerState<ComponentsTab> createState() => _ComponentsTabState();
}

class _ComponentsTabState extends ConsumerState<ComponentsTab> {
  var _formOpen = false;  // o formulário está aberto?
  Component? _editing;    // null = novo; senão, o que se está a editar

  void _openNew() => setState(() {
    _formOpen = true;
    _editing = null;
  });

  void _openEdit(Component c) => setState(() {
    _formOpen = true;
    _editing = c;
  });

  void _close() => setState(() {
    _formOpen = false;
    _editing = null;
  });

  @override
  Widget build(BuildContext context) {
    final components = ref.watch(componentsProvider);

    return components.when(
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Embalagens e componentes",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _formOpen ? null : _openNew,
                        icon: const Icon(Icons.add),
                        label: const Text("Adicionar"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Compras em packs; a app usa o custo de cada unidade.",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (_formOpen) ...[
                    const SizedBox(height: 16),
                    _ComponentForm(
                      key: ValueKey(_editing?.id),
                      initial: _editing,
                      onClose: _close,
                    ),
                  ],
                  const SizedBox(height: 8),
                  if (list.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text("Ainda não há componentes."),
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

  Widget _table(List<Component> list) {
    const calc = CostCalculator();

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: DataTable(
            columnSpacing: 24,
            horizontalMargin: 8,
            showCheckboxColumn: false,
            columns: const [
              DataColumn(label: Text("Nome")),
              DataColumn(label: Text("Tipo")),
              DataColumn(label: Text("Tamanho")),
              DataColumn(label: Text("Peso"), numeric: true),
              DataColumn(label: Text("Preço do pack"), numeric: true),
              DataColumn(label: Text("Unidades"), numeric: true),
              DataColumn(label: Text("Custo por unidade"), numeric: true),
            ],
            rows: [
              for (final c in list)
                DataRow(
                  selected: _editing?.id == c.id,
                  onSelectChanged: (_) => _openEdit(c),
                  cells: [
                    DataCell(Text(c.name)),
                    DataCell(Text(c.kind.label)),
                    DataCell(Text(c.sizeLabel ?? "—")),
                    DataCell(Text("${c.weightG} g")),
                    DataCell(Text(euro(c.packPrice), style: AppTextStyles.mono)),
                    DataCell(Text("${c.unitsPerPack}")),
                    DataCell(Text(
                      euroPer(calc.componentUnitCost(c), "un.", decimals: 3),
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

/// O formulário de criar ou editar um componente ou embalagem.
class _ComponentForm extends ConsumerStatefulWidget {
  const _ComponentForm({super.key, this.initial, required this.onClose});

  final Component? initial;    // null = novo
  final VoidCallback onClose;  // chamada para fechar (ao cancelar ou depois de guardar)

  @override
  ConsumerState<_ComponentForm> createState() => _ComponentFormState();
}

class _ComponentFormState extends ConsumerState<_ComponentForm> {
  static const _calc = CostCalculator();

  late var _kind = widget.initial?.kind ?? ComponentKind.component;
  late final _name = TextEditingController(text: widget.initial?.name ?? "");
  late final _sizeLabel = TextEditingController(text: widget.initial?.sizeLabel ?? "");
  late final _weight = TextEditingController(text: "${widget.initial?.weightG ?? 0}");
  late final _packPrice = TextEditingController(
      text: widget.initial == null ? "" : decimalField(widget.initial!.packPrice));
  late final _units = TextEditingController(text: "${widget.initial?.unitsPerPack ?? 1}");

  var _saving = false;

  @override
  void dispose() {
    for (final c in [_name, _sizeLabel, _weight, _packPrice, _units]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Junta o que está escrito num componente. Serve para a pré-visualização E para gravar.
  Component _draft() {
    final size = _sizeLabel.text.trim();
    return Component(
      id: widget.initial?.id ?? 0,
      name: _name.text.trim(),
      kind: _kind,
      sizeLabel: size.isEmpty ? null : size,
      weightG: parseDecimal(_weight.text).round(),
      packPrice: parseDecimal(_packPrice.text),
      unitsPerPack: parseDecimal(_units.text).round(),
      // os campos que o formulário não mostra ficam como estavam
      stockQty: widget.initial?.stockQty ?? 0,
      minStockQty: widget.initial?.minStockQty ?? 0,
    );
  }

  /// O primeiro problema que impede de gravar, ou null se estiver tudo bem.
  String? _problem(Component d) {
    if (d.name.isEmpty) return "Escreve o nome.";
    if (d.packPrice <= 0) return "Escreve o preço do pack.";
    if (d.unitsPerPack < 1) return "O pack tem de ter pelo menos 1 unidade.";
    return null;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final repository = ref.read(componentRepositoryProvider);
    final draft = _draft();

    try {
      if (widget.initial == null) {
        await repository.create(draft);
      } else {
        await repository.update(draft);
      }
    } catch (error) {
      // correu mal: volta a ligar o botão e mostra o erro
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Não foi possível guardar: $error")),
      );
      return;
    }

    ref.invalidate(componentsProvider);
    if (!mounted) return;
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = _draft();
    final problem = _problem(draft);
    final unitCost = draft.unitsPerPack > 0 ? _calc.componentUnitCost(draft) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.orange),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.initial == null ? "Novo componente" : "Editar componente",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(onPressed: widget.onClose, icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: SegmentedButton<ComponentKind>(
              segments: const [
                ButtonSegment(value: ComponentKind.component, label: Text("Componente")),
                ButtonSegment(value: ComponentKind.packaging, label: Text("Embalagem")),
              ],
              selected: {_kind},
              onSelectionChanged: (selection) => setState(() => _kind = selection.first),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _text(_name, "Nome", hint: "Ex.: Íman de neodímio, Caixa"),
              ),
              const SizedBox(width: 12),
              Expanded(child: _text(_sizeLabel, "Tamanho", hint: "Ex.: 25 mm, S, A5")),
              const SizedBox(width: 12),
              Expanded(
                child: _number(_weight, "Peso de uma unidade", "g",
                    hint: "Conta para os portes."),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _number(_packPrice, "Preço do pack", "€",
                    hint: "O que pagaste pelo pack inteiro."),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _number(_units, "Unidades no pack", "",
                    hint: "Quantas peças traz o pack."),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Text("Custo por unidade "),
                Text(
                  euroPer(unitCost, "un.", decimals: 3),
                  style: AppTextStyles.mono.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                TextButton(onPressed: widget.onClose, child: const Text("Cancelar")),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _saving || problem != null ? null : _save,
                  child: _saving
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : Text(widget.initial == null ? "Adicionar à lista" : "Guardar"),
                ),
              ],
            ),
          ),
          if (problem != null) ...[
            const SizedBox(height: 8),
            Text(problem, style: const TextStyle(color: Color(0xFFB91C1C))),
          ],
        ],
      ),
    );
  }

  /// Um campo de texto.
  Widget _text(TextEditingController c, String label, {String? hint}) {
    return TextField(
      controller: c,
      decoration: InputDecoration(labelText: label, helperText: hint),
      onChanged: (_) => setState(() {}),
    );
  }

  /// Um campo de número, com a unidade à direita.
  Widget _number(TextEditingController c, String label, String unit, {String? hint}) {
    return TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: AppTextStyles.mono,
      decoration: InputDecoration(
        labelText: label,
        suffixText: unit.isEmpty ? null : unit,
        helperText: hint,
      ),
      onChanged: (_) => setState(() {}),
    );
  }
}

/// O nome de cada tipo, para o ecrã.
extension _ComponentKindLabel on ComponentKind {
  String get label => switch (this) {
    ComponentKind.component => "Componente",
    ComponentKind.packaging => "Embalagem",
  };
}