import 'package:cubico_backoffice/app/theme.dart';
import 'package:cubico_backoffice/core/colors.dart';
import 'package:cubico_backoffice/core/formatting.dart';
import 'package:cubico_backoffice/features/costs/domain/cost_calculator.dart';
import 'package:cubico_backoffice/features/costs/domain/filament.dart';
import 'package:cubico_backoffice/features/costs/presentation/costs_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Separador "Filamentos": a tabela com o custo real de cada rolo, e o formulário para criar ou editar.
class FilamentsTab extends ConsumerStatefulWidget {
  const FilamentsTab({super.key});

  @override
  ConsumerState<FilamentsTab> createState() => _FilamentsTabState();
}

class _FilamentsTabState extends ConsumerState<FilamentsTab> {
  // NOVO: o que o formulário está a mostrar
  var _formOpen = false;   // o formulário está aberto?
  Filament? _editing;      // null = filamento novo; senão, o que se está a editar

  void _openNew() => setState(() {
    _formOpen = true;
    _editing = null;
  });

  void _openEdit(Filament f) => setState(() {
    _formOpen = true;
    _editing = f;
  });

  void _close() => setState(() {
    _formOpen = false;
    _editing = null;
  });

  @override
  Widget build(BuildContext context) {
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
                  Row(
                    children: [
                      Expanded(
                        child: Text("Filamentos", style: Theme.of(context).textTheme.titleMedium),
                      ),
                      // NOVO: o botão para criar
                      OutlinedButton.icon(
                        onPressed: _formOpen ? null : _openNew,
                        icon: const Icon(Icons.add),
                        label: const Text("Adicionar filamento"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "A app usa sempre o preço que pagaste, mais a parte dos portes de cada rolo. "
                        "O preço normal fica como referência, para veres quanto poupaste.",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  // NOVO: o formulário, quando está aberto
                  if (_formOpen) ...[
                    const SizedBox(height: 16),
                    _FilamentForm(
                      key: ValueKey(_editing?.id),
                      initial: _editing,
                      onClose: _close,
                    ),
                  ],
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
            showCheckboxColumn: false,
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
                  // NOVO: a linha em edição fica pintada, e tocar numa linha abre-a
                  selected: _editing?.id == f.id,
                  onSelectChanged: (_) => _openEdit(f),
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
                    DataCell(Text(_spoolLabel(f.spoolWeightG))),
                    DataCell(Text(
                      euro(f.listPrice),
                      style: AppTextStyles.mono.copyWith(
                        color: const Color(0xFF71717A),
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

/// 1000 → "1 kg"; 500 → "500 g".
String _spoolLabel(int grams) {
  if (grams >= 1000 && grams % 1000 == 0) return "${grams ~/ 1000} kg";
  if (grams >= 1000) return "${(grams / 1000).toStringAsFixed(1)} kg";
  return "$grams g";
}

/// NOVO: o formulário de criar ou editar um filamento.
class _FilamentForm extends ConsumerStatefulWidget {
  const _FilamentForm({super.key, this.initial, required this.onClose});

  final Filament? initial;     // null = novo
  final VoidCallback onClose;  // chamada para fechar (ao cancelar ou depois de guardar)

  @override
  ConsumerState<_FilamentForm> createState() => _FilamentFormState();
}

class _FilamentFormState extends ConsumerState<_FilamentForm> {
  static const _calc = CostCalculator();

  late final _material = TextEditingController(text: widget.initial?.material ?? "");
  late final _brand = TextEditingController(text: widget.initial?.brand ?? "");
  late final _colorName = TextEditingController(text: widget.initial?.colorName ?? "");
  late final _colorHex = TextEditingController(text: widget.initial?.colorHex ?? "");
  late final _weight = TextEditingController(text: "${widget.initial?.spoolWeightG ?? 1000}");
  late final _listPrice = TextEditingController(
      text: widget.initial == null ? "" : decimalField(widget.initial!.listPrice));
  late final _paidPrice = TextEditingController(
      text: widget.initial == null ? "" : decimalField(widget.initial!.paidPrice));
  late final _shipping = TextEditingController(
      text: decimalField(widget.initial?.shippingCost ?? 0));
  late final _spools = TextEditingController(text: "${widget.initial?.spoolsInOrder ?? 1}");

  var _saving = false;

  @override
  void dispose() {
    for (final c in [
      _material, _brand, _colorName, _colorHex,
      _weight, _listPrice, _paidPrice, _shipping, _spools,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Junta o que está escrito num filamento. Serve para a pré-visualização E para gravar.
  Filament _draft() {
    final brand = _brand.text.trim();
    final hex = _colorHex.text.trim();
    final paid = parseDecimal(_paidPrice.text);
    final list = parseDecimal(_listPrice.text);
    final spools = parseDecimal(_spools.text).round();

    return Filament(
      id: widget.initial?.id ?? 0,
      material: _material.text.trim(),
      brand: brand.isEmpty ? null : brand,
      colorName: _colorName.text.trim(),
      colorHex: hex.isEmpty ? null : hex,
      spoolWeightG: parseDecimal(_weight.text).round(),
      listPrice: list > 0 ? list : paid, // sem preço normal, conta como sem desconto
      paidPrice: paid,
      shippingCost: parseDecimal(_shipping.text),
      spoolsInOrder: spools < 1 ? 1 : spools,
      // os campos que o formulário não mostra ficam como estavam
      minStockG: widget.initial?.minStockG ?? 250,
      isActive: widget.initial?.isActive ?? true,
    );
  }

  /// O primeiro problema que impede de gravar, ou null se estiver tudo bem.
  String? _problem(Filament d) {
    if (d.material.isEmpty) return "Escreve o tipo (PLA, PETG…).";
    if (d.colorName.isEmpty) return "Escreve o nome da cor.";
    if (d.spoolWeightG <= 0) return "O peso do rolo tem de ser maior do que 0.";
    if (d.paidPrice <= 0) return "Escreve o preço que pagaste.";
    return null;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final repository = ref.read(filamentRepositoryProvider);
    final draft = _draft();

    if (widget.initial == null) {
      await repository.create(draft);
    } else {
      await repository.update(draft);
    }
    ref.invalidate(filamentsProvider);

    if (!mounted) return;
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = _draft();
    final problem = _problem(draft);
    final pricePerKg =
    draft.spoolWeightG > 0 && draft.paidPrice > 0 ? _calc.filamentPricePerKg(draft) : 0.0;

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
                  widget.initial == null ? "Novo filamento" : "Editar filamento",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(onPressed: widget.onClose, icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _text(_material, "Tipo", hint: "Ex.: PLA, PLA Silk, PETG, TPU")),
              const SizedBox(width: 12),
              Expanded(child: _text(_brand, "Marca")),
              const SizedBox(width: 12),
              Expanded(child: _text(_colorName, "Cor")),
              const SizedBox(width: 12),
              SizedBox(
                width: 130,
                child: _text(
                  _colorHex,
                  "Amostra",
                  hint: "Ex.: #1F2937",
                  prefix: CircleAvatar(radius: 7, backgroundColor: colorFromHex(_colorHex.text)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _number(_weight, "Peso do rolo", "g")),
              const SizedBox(width: 12),
              Expanded(
                child: _number(_listPrice, "Preço normal", "€",
                    hint: "O preço de tabela, sem promoção."),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _number(_paidPrice, "Preço pago", "€",
                    hint: "O que pagaste, com desconto."),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _number(_shipping, "Portes da compra", "€",
                    hint: "O total que pagaste de envio."),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _number(_spools, "Rolos nessa compra", "",
                    hint: "Os portes são repartidos por todos."),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // o resumo: custo real e poupança, enquanto se escreve
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Text("Custo real "),
                Text(
                  euroPer(pricePerKg, "kg"),
                  style: AppTextStyles.mono.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 12),
                if (draft.discountPct > 0) _DiscountBadge(draft.discountPct, saved: true),
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
  Widget _text(TextEditingController c, String label, {String? hint, Widget? prefix}) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        labelText: label,
        helperText: hint,
        prefixIcon: prefix == null
            ? null
            : Padding(padding: const EdgeInsets.all(12), child: prefix),
      ),
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

/// A etiqueta verde com a percentagem poupada: "-30%" (ou "Poupaste 30%").
class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge(this.pct, {this.saved = false});

  final double pct;
  final bool saved;

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
        saved ? "Poupaste ${pct.toStringAsFixed(0)}%" : "-${pct.toStringAsFixed(0)}%",
        style: const TextStyle(color: green, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}