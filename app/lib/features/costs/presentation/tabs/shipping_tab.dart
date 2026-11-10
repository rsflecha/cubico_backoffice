import 'package:cubico_backoffice/app/theme.dart';
import 'package:cubico_backoffice/core/formatting.dart';
import 'package:cubico_backoffice/features/costs/domain/cost_calculator.dart';
import 'package:cubico_backoffice/features/costs/domain/shipping_rate.dart';
import 'package:cubico_backoffice/features/costs/presentation/costs_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// O nome de cada zona e o serviço usado. Mais tarde vêm da base de dados (shipping_zones).
const _zones = {
  1: "Portugal · CTT Correio Registado",
  2: "Europa · CTT Correio Azul Internacional",
  3: "Estados Unidos · CTT Correio Azul Internacional",
  4: "Resto do mundo · CTT Correio Azul Internacional",
};

/// Separador "Portes de envio": o simulador e os escalões de cada zona.
class ShippingTab extends ConsumerStatefulWidget {
  const ShippingTab({super.key});

  @override
  ConsumerState<ShippingTab> createState() => _ShippingTabState();
}

class _ShippingTabState extends ConsumerState<ShippingTab> {
  static const _calc = CostCalculator();
  final _weight = TextEditingController(text: "250");

  @override
  void dispose() {
    _weight.dispose();
    super.dispose();
  }

  /// Abre a janela para mudar o preço de um escalão.
  Future<void> _editPrice(ShippingRate rate) async {
    final newPrice = await showDialog<double>(
      context: context,
      builder: (context) => _PriceDialog(
        title: "Até ${_grams(rate.maxWeightG)}",
        initialPrice: rate.price,
      ),
    );

    if (newPrice == null || newPrice <= 0) return;

    try {
      await ref.read(shippingRateRepositoryProvider).update(rate.copyWith(price: newPrice));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Não foi possível guardar: $error")),
      );
      return;
    }
    ref.invalidate(shippingRatesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final rates = ref.watch(shippingRatesProvider);

    return rates.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text("Erro: $error")),
      data: (list) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _simulator(list),
          const SizedBox(height: 16),
          for (final zone in _zones.entries) ...[
            _zoneCard(zone.value, list.where((r) => r.zoneId == zone.key).toList()),
            const SizedBox(height: 16),
          ],
          Text(
            "Preços base dos CTT para pacote postal (2026). "
                "Os portes de cada encomenda guardam o valor da altura e não mudam.",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  /// O simulador: um peso, e o preço em cada zona.
  Widget _simulator(List<ShippingRate> list) {
    final weight = parseDecimal(_weight.text).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Quanto custa enviar?", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(
              width: 220,
              child: TextField(
                controller: _weight,
                keyboardType: TextInputType.number,
                style: AppTextStyles.mono,
                decoration: const InputDecoration(
                  labelText: "Peso do pacote",
                  suffixText: "g",
                  helperText: "Peça + componentes + embalagem.",
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 12),
            for (final zone in _zones.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Expanded(child: Text(zone.value)),
                    Builder(builder: (context) {
                      final price = _calc.shippingPrice(
                        weightG: weight,
                        zoneId: zone.key,
                        rates: list,
                      );
                      return Text(
                        price == null ? "acima do limite" : euro(price),
                        style: AppTextStyles.mono.copyWith(
                          fontWeight: FontWeight.w700,
                          color: price == null ? const Color(0xFFB91C1C) : null,
                        ),
                      );
                    }),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Um cartão com os escalões de uma zona, do mais leve para o mais pesado.
  Widget _zoneCard(String title, List<ShippingRate> rates) {
    final sorted = [...rates]..sort((a, b) => a.maxWeightG.compareTo(b.maxWeightG));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            if (sorted.isEmpty)
              const Text("Sem escalões.")
            else
              for (var i = 0; i < sorted.length; i++)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    i == 0
                        ? "Até ${_grams(sorted[i].maxWeightG)}"
                        : "${_grams(sorted[i - 1].maxWeightG)} – ${_grams(sorted[i].maxWeightG)}",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        euro(sorted[i].price),
                        style: AppTextStyles.mono.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.edit_outlined, size: 18),
                    ],
                  ),
                  onTap: () => _editPrice(sorted[i]),
                ),
          ],
        ),
      ),
    );
  }
}

/// 100 → "100 g"; 2000 → "2 kg"
String _grams(int g) => g >= 1000 && g % 1000 == 0 ? "${g ~/ 1000} kg" : "$g g";

/// A janela do preço: tem o seu próprio controller, e deita-o fora no momento certo.
class _PriceDialog extends StatefulWidget {
  const _PriceDialog({required this.title, required this.initialPrice});

  final String title;
  final double initialPrice;

  @override
  State<_PriceDialog> createState() => _PriceDialogState();
}

class _PriceDialogState extends State<_PriceDialog> {
  late final _controller = TextEditingController(text: decimalField(widget.initialPrice));

  @override
  void dispose() {
    _controller.dispose(); // só quando a janela desaparece de vez, depois da animação
    super.dispose();
  }

  void _submit() => Navigator.pop(context, parseDecimal(_controller.text));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(labelText: "Preço", suffixText: "€"),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
        FilledButton(onPressed: _submit, child: const Text("Guardar")),
      ],
    );
  }
}