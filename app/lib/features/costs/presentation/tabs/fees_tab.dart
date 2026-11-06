import 'package:cubico_backoffice/app/theme.dart';
import 'package:cubico_backoffice/core/formatting.dart';
import 'package:cubico_backoffice/features/costs/domain/cost_calculator.dart';
import 'package:cubico_backoffice/features/costs/domain/sales_channel.dart';
import 'package:cubico_backoffice/features/costs/presentation/costs_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Separador "Taxas": o que cada canal de venda cobra, e o formulário para editar.
class FeesTab extends ConsumerStatefulWidget {
  const FeesTab({super.key});

  @override
  ConsumerState<FeesTab> createState() => _FeesTabState();
}

class _FeesTabState extends ConsumerState<FeesTab> {
  SalesChannel? _editing; // o canal em edição (null = formulário fechado)

  @override
  Widget build(BuildContext context) {
    final channels = ref.watch(salesChannelsProvider);

    return channels.when(
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
                  Text("Taxas dos canais de venda",
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    "O que cada canal fica de uma venda. Toca num canal para mudar as taxas. "
                        "As encomendas já feitas guardam as taxas da altura e não mudam.",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (_editing != null) ...[
                    const SizedBox(height: 16),
                    _FeesForm(
                      key: ValueKey(_editing!.id),
                      channel: _editing!,
                      onClose: () => setState(() => _editing = null),
                    ),
                  ],
                  const SizedBox(height: 8),
                  _table(list),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _table(List<SalesChannel> list) {
    const calc = CostCalculator();

    String pct(double v) => "${v.toStringAsFixed(1).replaceAll(".", ",")}%";

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
              DataColumn(label: Text("Canal")),
              DataColumn(label: Text("Transação"), numeric: true),
              DataColumn(label: Text("Processamento"), numeric: true),
              DataColumn(label: Text("Fixo por venda"), numeric: true),
              DataColumn(label: Text("Listagem"), numeric: true),
              DataColumn(label: Text("Numa venda de 20 €"), numeric: true),
            ],
            rows: [
              for (final c in list)
                DataRow(
                  selected: _editing?.id == c.id,
                  onSelectChanged: (_) => setState(() => _editing = c),
                  cells: [
                    DataCell(Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text(pct(c.transactionFee), style: AppTextStyles.mono)),
                    DataCell(Text(pct(c.processingFee), style: AppTextStyles.mono)),
                    DataCell(Text(euro(c.flatFee), style: AppTextStyles.mono)),
                    DataCell(Text(euro(c.listingFee), style: AppTextStyles.mono)),
                    DataCell(Text(
                      euro(calc.channelFees(
                        price: 20,
                        transactionPct: c.transactionFee,
                        processingPct: c.processingFee,
                        flatFee: c.flatFee,
                        listingFee: c.listingFee,
                      )),
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

/// O formulário de editar as taxas de um canal.
class _FeesForm extends ConsumerStatefulWidget {
  const _FeesForm({super.key, required this.channel, required this.onClose});

  final SalesChannel channel;
  final VoidCallback onClose;

  @override
  ConsumerState<_FeesForm> createState() => _FeesFormState();
}

class _FeesFormState extends ConsumerState<_FeesForm> {
  static const _calc = CostCalculator();

  late final _transaction = TextEditingController(text: _decimal(widget.channel.transactionFee));
  late final _processing = TextEditingController(text: _decimal(widget.channel.processingFee));
  late final _flat = TextEditingController(text: decimalField(widget.channel.flatFee));
  late final _listing = TextEditingController(text: decimalField(widget.channel.listingFee));

  var _saving = false;

  /// 6.5 → "6,5" (sem zeros a mais nas percentagens)
  static String _decimal(double v) =>
      v.toStringAsFixed(v == v.roundToDouble() ? 0 : 1).replaceAll(".", ",");

  @override
  void dispose() {
    for (final c in [_transaction, _processing, _flat, _listing]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Junta o que está escrito no canal. Serve para o exemplo E para gravar.
  SalesChannel _draft() => widget.channel.copyWith(
    transactionFee: parseDecimal(_transaction.text),
    processingFee: parseDecimal(_processing.text),
    flatFee: parseDecimal(_flat.text),
    listingFee: parseDecimal(_listing.text),
  );

  String? _problem(SalesChannel d) {
    if (d.transactionFee < 0 || d.processingFee < 0 || d.flatFee < 0 || d.listingFee < 0) {
      return "As taxas não podem ser negativas.";
    }
    if (d.transactionFee + d.processingFee >= 100) {
      return "As percentagens juntas têm de ficar abaixo de 100%.";
    }
    return null;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(salesChannelRepositoryProvider).update(_draft());
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Não foi possível guardar: $error")),
      );
      return;
    }
    ref.invalidate(salesChannelsProvider);
    if (!mounted) return;
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = _draft();
    final problem = _problem(draft);
    final example = _calc.channelFees(
      price: 20,
      transactionPct: draft.transactionFee,
      processingPct: draft.processingFee,
      flatFee: draft.flatFee,
      listingFee: draft.listingFee,
    );

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
                child: Text("Taxas · ${widget.channel.name}",
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              IconButton(onPressed: widget.onClose, icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _number(_transaction, "Taxa de transação", "%",
                    hint: "Sobre o preço de venda."),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _number(_processing, "Taxa de processamento", "%",
                    hint: "O pagamento, também sobre o preço."),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _number(_flat, "Fixo por venda", "€",
                    hint: "Cobrado em cada venda."),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _number(_listing, "Listagem", "€",
                    hint: "O custo de pôr o anúncio."),
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
                const Text("Numa venda de 20 €, o canal fica com "),
                Text(
                  euro(example),
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
                      : const Text("Guardar"),
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

  Widget _number(TextEditingController c, String label, String unit, {String? hint}) {
    return TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: AppTextStyles.mono,
      decoration: InputDecoration(labelText: label, suffixText: unit, helperText: hint),
      onChanged: (_) => setState(() {}),
    );
  }
}