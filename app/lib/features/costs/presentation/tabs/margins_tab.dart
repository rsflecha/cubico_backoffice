import 'package:cubico_backoffice/app/theme.dart';
import 'package:cubico_backoffice/core/formatting.dart';
import 'package:cubico_backoffice/features/costs/domain/cost_settings.dart';
import 'package:cubico_backoffice/features/costs/presentation/costs_providers.dart';
import 'package:cubico_backoffice/features/costs/presentation/widgets/fixed_costs_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Separador "Margens e custos fixos": espera pelas definições e depois mostra o formulário.
class MarginsTab extends ConsumerWidget {
  const MarginsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // aqui só precisamos das definições (na energia eram duas coisas)
    final settings = ref.watch(costSettingsProvider).value;

    if (settings == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return _MarginsForm(settings: settings);
  }
}

/// O formulário: nasce já com as definições.
class _MarginsForm extends ConsumerStatefulWidget {
  const _MarginsForm({required this.settings});

  final CostSettings settings;

  @override
  ConsumerState<_MarginsForm> createState() => _MarginsFormState();
}

class _MarginsFormState extends ConsumerState<_MarginsForm> {
  late final _target = TextEditingController(
    text: widget.settings.targetMarginPct.toStringAsFixed(0),
  );
  late final _min = TextEditingController(
    text: widget.settings.minMarginPct.toStringAsFixed(0),
  );
  late final _rounding = TextEditingController(
    text: decimalField(widget.settings.rounding),
  );

  var _saving = false;

  @override
  void dispose() {
    for (final c in [_target, _min, _rounding]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    await ref.read(costSettingsRepositoryProvider).save(
      widget.settings.copyWith(
        targetMarginPct: parseDecimal(_target.text),
        minMarginPct: parseDecimal(_min.text),
        rounding: parseDecimal(_rounding.text),
      ),
    );
    ref.invalidate(costSettingsProvider);

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Margens guardadas. A calculadora já as usa.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final target = parseDecimal(_target.text);
    final minimum = parseDecimal(_min.text);
    final rounding = parseDecimal(_rounding.text);

    // as regras que tornam os valores inválidos (novo em relação à energia)
    final String? problem;
    if (target <= 0 || target >= 100) {
      problem = "A margem alvo tem de estar entre 0% e 100%.";
    } else if (minimum >= target) {
      problem = "A margem mínima tem de ser menor do que a margem alvo.";
    } else if (rounding <= 0) {
      problem = "O arredondamento tem de ser maior do que 0.";
    } else {
      problem = null;
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        ConstrainedBox(
          // num ecrã largo, o formulário não estica até às bordas
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _card(
                title: "Margens",
                children: [
                  _field(_target, "Margem alvo", "%",
                      hint: "O preço sugerido é calculado para esta margem."),
                  const SizedBox(height: 12),
                  _field(_min, "Margem mínima", "%",
                      hint: "Abaixo disto, a margem aparece a vermelho."),
                ],
              ),
              const SizedBox(height: 16),
              _card(
                title: "Preço sugerido",
                children: [
                  _field(_rounding, "Arredondamento", "€",
                      hint: "0,50 arredonda a 23,50 €; 1 arredonda a 24 €."),
                ],
              ),
              if (problem != null) ...[
                const SizedBox(height: 12),
                Text(
                  problem,
                  style: const TextStyle(
                    color: Color(0xFFB91C1C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton(
                  // desligado enquanto grava OU enquanto houver um problema
                  onPressed: _saving || problem != null ? null : _save,
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
          ),
        ),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: const FixedCostsCard(),
        ),
      ],
    );
  }

  /// Um cartão com título (igual ao da energia).
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

  /// Um campo de número (igual ao da energia).
  Widget _field(TextEditingController controller, String label, String unit, {String? hint}) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: AppTextStyles.mono,
      decoration: InputDecoration(labelText: label, suffixText: unit, helperText: hint),
      onChanged: (_) => setState(() {}),
    );
  }
}