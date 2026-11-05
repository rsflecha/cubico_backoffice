import 'package:cubico_backoffice/app/theme.dart';
import 'package:cubico_backoffice/core/formatting.dart';
import 'package:cubico_backoffice/features/costs/domain/cost_calculator.dart';
import 'package:cubico_backoffice/features/costs/domain/cost_settings.dart';
import 'package:cubico_backoffice/features/costs/domain/printer.dart';
import 'package:cubico_backoffice/features/costs/presentation/costs_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Separador "Energia e impressoras": espera pelos dados e depois mostra o formulário.
class EnergyTab extends ConsumerWidget {
  const EnergyTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(costSettingsProvider).value;
    final printers = ref.watch(printersProvider).value;

    if (settings == null || printers == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final printer = printers.where((p) => p.isDefault).firstOrNull ?? printers.firstOrNull;
    if (printer == null) {
      return const Center(child: Text("Ainda não há impressoras."));
    }

    return _EnergyForm(settings: settings, printer: printer);
  }
}

/// O formulário: nasce já com os dados e não espera por nada.
class _EnergyForm extends ConsumerStatefulWidget {
  const _EnergyForm({required this.settings, required this.printer});

  final CostSettings settings;
  final Printer printer;

  @override
  ConsumerState<_EnergyForm> createState() => _EnergyFormState();
}

class _EnergyFormState extends ConsumerState<_EnergyForm> {

  late final _kwh = TextEditingController(text: "${widget.settings.kwhPrice}".replaceAll(".", ","));
  late final _power = TextEditingController(text: "${widget.printer.powerW}");
  late final _purchase = TextEditingController(text: decimalField(widget.printer.purchasePrice));
  late final _lifespan = TextEditingController(text: "${widget.printer.lifespanHours}");
  late final _maintenance = TextEditingController(text: decimalField(widget.printer.yearlyMaintenance));
  late final _yearlyHours = TextEditingController(text: "${widget.printer.yearlyHours}");

  var _saving = false;

  @override
  void dispose() {
    for (final c in [_kwh, _power, _purchase, _lifespan, _maintenance, _yearlyHours]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    await ref.read(costSettingsRepositoryProvider).save(
      widget.settings.copyWith(kwhPrice: parseDecimal(_kwh.text)),
    );
    await ref.read(printerRepositoryProvider).update(
      widget.printer.copyWith(
        powerW: parseDecimal(_power.text).round(),
        purchasePrice: parseDecimal(_purchase.text),
        lifespanHours: parseDecimal(_lifespan.text).round(),
        yearlyMaintenance: parseDecimal(_maintenance.text),
        yearlyHours: parseDecimal(_yearlyHours.text).round(),
      ),
    );
    ref.invalidate(costSettingsProvider);
    ref.invalidate(printersProvider);

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Valores guardados. A calculadora já os usa.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    // as contas, sempre de novo, a partir do que está escrito
    final kwh = parseDecimal(_kwh.text);
    final power = parseDecimal(_power.text);
    final lifespan = parseDecimal(_lifespan.text);
    final yearlyHours = parseDecimal(_yearlyHours.text);

    final electricity = power / 1000 * kwh;
    final wear = lifespan > 0 ? parseDecimal(_purchase.text) / lifespan : 0.0;
    final maintenance = yearlyHours > 0 ? parseDecimal(_maintenance.text) / yearlyHours : 0.0;
    final total = electricity + wear + maintenance;

    final isWide = MediaQuery.sizeOf(context).width >= 1100;

    final fields = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _card(
          title: "Eletricidade",
          children: [
            _field(_kwh, "Preço do kWh no contrato", "€/kWh",
                hint: "Está na tua fatura da luz, com IVA."),
          ],
        ),
        const SizedBox(height: 16),
        _card(
          title: widget.printer.name,
          children: [
            Row(
              children: [
                Expanded(child: _field(_power, "Consumo médio a imprimir", "W")),
                const SizedBox(width: 16),
                Expanded(child: _field(_purchase, "Preço de compra", "€")),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _field(_lifespan, "Vida útil estimada", "h")),
                const SizedBox(width: 16),
                Expanded(child: _field(_maintenance, "Manutenção por ano", "€")),
                const SizedBox(width: 16),
                Expanded(child: _field(_yearlyHours, "Horas de impressão por ano", "h")),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text("Guardar"),
          ),
        ),
      ],
    );

    final summary = _summary(electricity, wear + maintenance, total);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: fields),
              const SizedBox(width: 24),
              Expanded(flex: 2, child: summary),
            ],
          )
        else ...[
          summary,
          const SizedBox(height: 16),
          fields,
        ],
      ],
    );
  }

  /// Um cartão com título.
  Widget _card({required String title, required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  /// Um campo de número, com a unidade à direita e uma ajuda opcional por baixo.
  Widget _field(TextEditingController controller, String label, String unit, {String? hint}) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: AppTextStyles.mono,
      decoration: InputDecoration(labelText: label, suffixText: unit, helperText: hint),
      onChanged: (_) => setState(() {}),
    );
  }

  /// O cartão escuro com o custo por hora.
  Widget _summary(double electricity, double wear, double total) {
    const light = TextStyle(color: Colors.white70);
    final mono = AppTextStyles.mono.copyWith(color: Colors.white);

    Widget line(String label, double value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: light)),
          Text(euroPer(value, "h", decimals: 3), style: mono),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Custo por hora de impressão",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          line("Eletricidade", electricity),
          line("Desgaste e manutenção", wear),
          const Divider(color: Colors.white24),
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Total",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                euroPer(total, "h", decimals: 3),
                style: mono.copyWith(
                  color: AppColors.orange,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Uma impressão de 9 h custa ${euro(total * 9)} em luz e desgaste. "
                "Este valor entra sozinho na calculadora de cada produto.",
            style: light,
          ),
        ],
      ),
    );
  }
}