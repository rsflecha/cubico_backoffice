import 'package:cubico_backoffice/app/theme.dart';
import 'package:cubico_backoffice/features/costs/domain/cost_calculator.dart';
import 'package:material_ui/material_ui.dart';
import 'package:cubico_backoffice/features/costs/presentation/costs_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../costs/domain/component.dart';

class CostCard extends ConsumerStatefulWidget {
  const CostCard({super.key});

  @override
  ConsumerState<CostCard> createState() => _CostCardState();
}

class _CostCardState extends ConsumerState<CostCard> {
  static const _calc = CostCalculator();

  // Filamento escolhido na lista (null = usa o primeiro).
  int? _filamentId;
  // Canal escolhido (null = usa o primeiro, a Etsy).
  int? _channelId;
  // Quantidade de cada componente: id do componente → quantidade.
  final Map<int, int> _componentQty = {};
  // Embalagens escolhidas: os ids das que estão incluídas.
  final Set<int> _packagingIds = {};

  final _gramsController = TextEditingController(text: "180");
  final _minutesController = TextEditingController(text: "540");
  final _priceController = TextEditingController(text: "29");

  @override
  void dispose() {
    _gramsController.dispose();
    _minutesController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  /// Lê um número de um campo. Aceita vírgula ("29,90") e devolve 0 se estiver vazio.
  double _read(TextEditingController controller) {
    return double.tryParse(controller.text.replaceAll(",", ".")) ?? 0;
  }

  @override
  Widget build(BuildContext context) {

    final filaments = ref.watch(filamentsProvider).value ?? [];
    final filament = filaments.where((f) => f.id == _filamentId).firstOrNull
        ?? filaments.firstOrNull;
    final channels = ref.watch(salesChannelsProvider).value ?? [];
    final channel = channels.where((c) => c.id == _channelId).firstOrNull
        ?? channels.firstOrNull;
    final allComponents = ref.watch(componentsProvider).value ?? [];
    final components =
    allComponents.where((c) => c.kind == ComponentKind.component).toList();
    final packaging =
    allComponents.where((c) => c.kind == ComponentKind.packaging).toList();

    // 1. ler o que está escrito
    final grams = _read(_gramsController);
    final minutes = _read(_minutesController);
    final price = _read(_priceController);

    // 2. fazer as contas (sempre de novo, a cada desenho)
    final filamentCost = filament == null
        ? 0.0
        : _calc.filamentCost(grams: grams, filament: filament);
    final perHour = _calc.printerCostPerHour(
      powerW: 95,
      kwhPrice: 0.21,
      purchasePrice: 381.40,
      lifespanHours: 5000,
      yearlyMaintenance: 40,
      yearlyHours: 1500,
    );
    final printing = _calc.printingCost(minutes: minutes, costPerHour: perHour);
    // componentes: quantidade × custo por unidade, somado para todos
    var componentsCost = 0.0;
    for (final c in components) {
      final qty = _componentQty[c.id] ?? 0;
      componentsCost += qty * _calc.componentUnitCost(c);
    }

    // embalagem: soma o custo das que estão escolhidas
    var packagingCost = 0.0;
    for (final p in packaging) {
      if (_packagingIds.contains(p.id)) {
        packagingCost += _calc.componentUnitCost(p);
      }
    }
    final production = filamentCost + printing + componentsCost + packagingCost;
    final fees = _calc.channelFees(
      price: price,
      transactionPct: channel?.transactionFee ?? 0,
      processingPct: channel?.processingFee ?? 0,
      flatFee: channel?.flatFee ?? 0,
      listingFee: channel?.listingFee ?? 0,
    );
    final margin = _calc.marginPct(price: price, productionCost: production, fees: fees);
    final suggested = _calc.suggestedPrice(
      productionCost: production,
      targetMarginPct: 60,
      transactionPct: channel?.transactionFee ?? 0,
      processingPct: channel?.processingFee ?? 0,
      flatFee: channel?.flatFee ?? 0,
      listingFee: channel?.listingFee ?? 0,
    );

    // 3. mostrar
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Custo e margem", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            DropdownButton<int>(
              value: filament?.id,
              isExpanded: true,
              hint: const Text("A carregar filamentos…"),
              items: [
                for (final f in filaments)
                  DropdownMenuItem(
                    value: f.id,
                    child: Text(
                      "${f.material} · ${f.colorName} — "
                          "${_calc.filamentPricePerKg(f).toStringAsFixed(2)} €/kg",
                    ),
                  ),
              ],
              onChanged: (id) => setState(() => _filamentId = id),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _gramsController,
              decoration: const InputDecoration(labelText: "Filamento (g)"),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _minutesController,
              decoration: const InputDecoration(labelText: "Impressão (minutos)"),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                for (final c in channels)
                  ChoiceChip(
                    label: Text(c.name),
                    selected: c.id == channel?.id,
                    onSelected: (_) => setState(() => _channelId = c.id),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _row("Filamento", filamentCost),
            _row("Impressão", printing),
            const SizedBox(height: 12),
            Text("Componentes", style: Theme.of(context).textTheme.labelLarge),
            for (final c in components) _componentRow(c),
            _row("Componentes", componentsCost),

            const SizedBox(height: 12),
            Text("Embalagem", style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in packaging)
                  FilterChip(
                    label: Text("${p.name} · ${_calc.componentUnitCost(p).toStringAsFixed(2)} €"),
                    selected: _packagingIds.contains(p.id),
                    onSelected: (selected) => setState(() {
                      if (selected) {
                        _packagingIds.add(p.id);
                      } else {
                        _packagingIds.remove(p.id);
                      }
                    }),
                  ),
              ],
            ),
            _row("Embalagem", packagingCost),
            _row("Taxas ${channel?.name ?? ""}", fees),
            const Divider(),
            _row("Custo total", production + fees),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: "Preço de venda (€)"),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Text("Margem: ${margin.toStringAsFixed(0)}%"),
            Text("Preço sugerido (60%): ${suggested.toStringAsFixed(2)} €"),
          ],
        ),
      ),
    );
  }

  /// Uma linha com o nome à esquerda e o valor em € à direita.
  Widget _row(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text("${value.toStringAsFixed(2)} €", style: AppTextStyles.mono),
        ],
      ),
    );
  }

  /// Uma linha de componente: nome e custo por unidade, botões − e + e a quantidade.
  Widget _componentRow(Component c) {
    final qty = _componentQty[c.id] ?? 0;
    return Row(
      children: [
        Expanded(
          child: Text("${c.name} · ${_calc.componentUnitCost(c).toStringAsFixed(3)} €/un."),
        ),
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: qty == 0 ? null : () => setState(() => _componentQty[c.id] = qty - 1),
        ),
        Text("$qty", style: AppTextStyles.mono),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => setState(() => _componentQty[c.id] = qty + 1),
        ),
      ],
    );
  }
}