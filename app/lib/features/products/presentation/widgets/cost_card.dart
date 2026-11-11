import 'dart:math' as math;

import 'package:cubico_backoffice/core/formatting.dart';
import 'package:cubico_backoffice/app/theme.dart';
import 'package:cubico_backoffice/features/costs/domain/cost_calculator.dart';
import 'package:material_ui/material_ui.dart';
import 'package:cubico_backoffice/features/costs/presentation/costs_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cubico_backoffice/features/costs/domain/component.dart';
import 'package:cubico_backoffice/features/products/domain/variant.dart';
import 'package:cubico_backoffice/features/products/presentation/products_providers.dart';

class CostCard extends ConsumerStatefulWidget {
  const CostCard({super.key, this.variant});

  /// A variante a editar. null = calculadora livre (produto novo).
  final Variant? variant;

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
  var _savingVariant = false; // desliga o botão enquanto grava


  final _gramsController = TextEditingController(text: "180");
  final _minutesController = TextEditingController(text: "540");
  final _priceController = TextEditingController(text: "29");
  // o nome, o SKU e o peso da variante (só quando há uma variante escolhida)
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _gramsController, _minutesController, _priceController,
      _nameController, _skuController, _weightController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final v = widget.variant;
    if (v == null) return; // sem variante: ficam os valores de exemplo

    _minutesController.text = "${v.printTimeMin}";
    _priceController.text = decimalField(v.salePrice);
    _nameController.text = v.name;
    _skuController.text = v.sku;
    _weightController.text = "${v.weightG}";

    final firstFilament = v.filaments.firstOrNull;
    if (firstFilament != null) {
      _filamentId = firstFilament.filamentId;
      _gramsController.text = "${firstFilament.grams}";
    }

    for (final line in v.components) {
      _componentQty[line.componentId] = line.quantity;
    }
  }

  /// Junta o que está no cartão numa variante e grava-a.
  Future<void> _saveVariant(int? filamentId) async {
    final v = widget.variant!;
    setState(() => _savingVariant = true);

    // uma variante ainda sem nome próprio fica com o nome do filamento (a cor)
    final typedName = _nameController.text.trim();
    final filamentName = ref
        .read(filamentsProvider)
        .value
        ?.where((f) => f.id == filamentId)
        .firstOrNull
        ?.colorName;
    final name = (typedName.isEmpty || typedName == "Nova variante") && filamentName != null
        ? filamentName
        : typedName;
    final sku = _skuController.text.trim();
    if (name.isEmpty || sku.isEmpty) {
      setState(() => _savingVariant = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("A variante precisa de um nome e de um SKU.")),
      );
      return;
    }

    final updated = v.copyWith(
      name: name,
      sku: sku,
      weightG: _read(_weightController).round(),
      salePrice: _read(_priceController),
      printTimeMin: _read(_minutesController).round(),
      filaments: filamentId == null
          ? []
          : [
        VariantFilament(
          filamentId: filamentId,
          grams: _read(_gramsController).round(),
        ),
      ],
      components: [
        for (final entry in _componentQty.entries)
          if (entry.value > 0)
            VariantComponent(componentId: entry.key, quantity: entry.value),
      ],
    );

    try {
      await ref.read(variantRepositoryProvider).update(updated);
    } catch (error) {
      // por exemplo: "Já existe uma variante com esse SKU."
      if (!mounted) return;
      setState(() => _savingVariant = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Não foi possível guardar: $error")),
      );
      return;
    }
    ref.invalidate(variantsProvider(v.productId));
    ref.invalidate(allVariantsProvider);

    if (!mounted) return;
    setState(() => _savingVariant = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Variante \"$name\" guardada.")),
    );
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
    final settings = ref.watch(costSettingsProvider).value;
    final target = settings?.targetMarginPct ?? 60;
    final minimum = settings?.minMarginPct ?? 35;
    final rounding = settings?.rounding ?? 0.50;

    // 1. ler o que está escrito
    final grams = _read(_gramsController);
    final minutes = _read(_minutesController);
    final price = _read(_priceController);

    // 2. fazer as contas (sempre de novo, a cada desenho)
    final filamentCost = filament == null
        ? 0.0
        : _calc.filamentCost(grams: grams, filament: filament);
    final perHour = ref.watch(printerCostPerHourProvider);
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
      final qty = _componentQty[p.id] ?? 0;
      packagingCost += qty * _calc.componentUnitCost(p);
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
    final profit = price - production - fees;
    final suggested = _calc.suggestedPrice(
      productionCost: production,
      targetMarginPct: target,
      rounding: rounding,
      transactionPct: channel?.transactionFee ?? 0,
      processingPct: channel?.processingFee ?? 0,
      flatFee: channel?.flatFee ?? 0,
      listingFee: channel?.listingFee ?? 0,
    );
    // a barra vai até ao dobro do sugerido, ou 50% acima do preço guardado (o maior dos dois)
    final savedPrice = widget.variant?.salePrice ?? 0;
    final sliderMax = math.max(suggested * 2, savedPrice * 1.5).clamp(10.0, 1000.0);

    // 3. mostrar
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.variant == null
                  ? "Custo e margem"
                  : "Custo e margem · ${widget.variant!.name}",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            // o nome, o SKU e o peso da variante
            if (widget.variant != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Nome da variante",
                        hintText: "Ex.: Preto mate",
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _skuController,
                      style: AppTextStyles.mono,
                      decoration: const InputDecoration(labelText: "SKU"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      style: AppTextStyles.mono,
                      decoration: const InputDecoration(
                        labelText: "Peso",
                        suffixText: "g",
                        helperText: "Para os portes.",
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            DropdownButton<int>(
              value: filament?.id,
              isExpanded: true,
              hint: const Text("A carregar filamentos…"),
              items: [
                for (final f in filaments)
                  DropdownMenuItem(
                    value: f.id,
                    child: Text(
                      "${f.material} · ${f.colorName} — ${euroPer(_calc.filamentPricePerKg(f), "kg")}",
                    ),
                  ),
              ],
              onChanged: (id) => setState(() {
                final previous = filaments.where((f) => f.id == _filamentId).firstOrNull;
                final next = filaments.where((f) => f.id == id).firstOrNull;
                _filamentId = id;

                // o nome segue o filamento, enquanto não lhe deres um nome teu
                final name = _nameController.text.trim();
                if (next != null &&
                    (name.isEmpty || name == "Nova variante" || name == previous?.colorName)) {
                  _nameController.text = next.colorName;
                }
              }),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _gramsController,
                    decoration: const InputDecoration(labelText: "Filamento (g)"),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _minutesController,
                    decoration: const InputDecoration(labelText: "Impressão (minutos)"),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
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
                    label: Text("${p.name} · ${euro(_calc.componentUnitCost(p))}"),
                    selected: (_componentQty[p.id] ?? 0) > 0,
                    onSelected: (selected) => setState(() {
                      if (selected) {
                        _componentQty[p.id] = 1;
                      } else {
                        _componentQty.remove(p.id);
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
            Row(
              children: [
                SizedBox(
                  width: 140,
                  child: TextField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: "Preço de venda (€)"),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: price.clamp(0.0, sliderMax),
                    max: sliderMax,
                    divisions: (sliderMax / 0.5).round(),
                    label: euro(price),
                    onChanged: (value) => setState(() {
                      _priceController.text = decimalField(value);
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _marginBox(profit, margin, target, minimum),
            const SizedBox(height: 12),
            _row("Preço sugerido (margem ${target.toStringAsFixed(0)}%)", suggested),
            if (widget.variant != null) ...[
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _savingVariant ? null : () => _saveVariant(filament?.id),
                child: _savingVariant
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text("Guardar variante"),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Uma linha com o nome à esquerda e o valor em € à direita.
  Widget _row(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),   // era 4
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(euro(value), style: AppTextStyles.mono),
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
          child: Text("${c.name} · ${euroPer(_calc.componentUnitCost(c), "un.", decimals: 3)}"),
        ),
        IconButton(
          icon: const Icon(Icons.remove),
          iconSize: 18,
          visualDensity: VisualDensity.compact,
          onPressed: qty == 0 ? null : () => setState(() => _componentQty[c.id] = qty - 1),
        ),
        Text("$qty", style: AppTextStyles.mono),
        IconButton(
          icon: const Icon(Icons.add),
          iconSize: 18,
          visualDensity: VisualDensity.compact,
          onPressed: () => setState(() => _componentQty[c.id] = qty + 1),
        ),
      ],
    );
  }

  Widget _marginBox(double profit, double margin, double target, double minimum) {
    final Color color;
    final String message;
    if (margin >= target) {
      color = const Color(0xFF15803D);
      message = "Margem saudável.";
    } else if (margin >= minimum) {
      color = const Color(0xFFB45309);
      message = "Abaixo da margem alvo (${target.toStringAsFixed(0)}%).";
    } else {
      color = const Color(0xFFB91C1C);
      message = "Margem baixa: revê o preço.";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10), // a mesma cor, muito clara, no fundo
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Margem"),
          const SizedBox(height: 4),
          Text(
            "${euro(profit)} · ${margin.toStringAsFixed(0)}%",
            style: AppTextStyles.mono.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (margin / 100).clamp(0, 1),
            color: color,
            backgroundColor: color.withValues(alpha: 0.15),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 8),
          Text(message, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}