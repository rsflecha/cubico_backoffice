import 'dart:math' as math;

import 'package:cubico_backoffice/core/formatting.dart';
import 'package:cubico_backoffice/app/theme.dart';
import 'package:cubico_backoffice/features/costs/domain/cost_calculator.dart';
import 'package:material_ui/material_ui.dart';
import 'package:cubico_backoffice/features/costs/presentation/costs_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cubico_backoffice/features/costs/domain/component.dart';
import 'package:cubico_backoffice/features/costs/domain/filament.dart';
import 'package:cubico_backoffice/features/costs/domain/sales_channel.dart';
import 'package:cubico_backoffice/features/products/domain/variant.dart';
import 'package:cubico_backoffice/features/products/domain/sku.dart';
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

  // As cores da peça: uma linha por filamento, cada uma com as suas gramas.
  // Uma peça de uma cor só tem uma linha (como era antes).
  final List<_ColorLine> _lines = [];
  // Quantidade de cada componente: id do componente → quantidade.
  final Map<int, int> _componentQty = {};
  var _savingVariant = false; // desliga o botão enquanto grava

  final _minutesController = TextEditingController(text: "540");
  final _priceController = TextEditingController(text: "29");
  // o nome e o peso da variante (só quando há uma variante escolhida); o SKU sai do nome
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void dispose() {
    for (final line in _lines) {
      line.grams.dispose();
    }
    for (final c in [
      _minutesController,
      _priceController,
      _nameController,
      _weightController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final v = widget.variant;
    // todas as cores da receita (antes só se lia a primeira)
    for (final f in v?.filaments ?? <VariantFilament>[]) {
      _lines.add(_ColorLine(f.filamentId, "${f.grams}"));
    }
    // sem receita: uma linha com o primeiro filamento e um valor de exemplo
    if (_lines.isEmpty) _lines.add(_ColorLine(null, "180"));
    if (v == null) return; // sem variante: ficam os valores de exemplo

    _minutesController.text = "${v.printTimeMin}";
    _priceController.text = decimalField(v.salePrice);
    _nameController.text = v.name;
    _weightController.text = "${v.weightG}";

    for (final line in v.components) {
      _componentQty[line.componentId] = line.quantity;
    }
  }

  /// O filamento de uma linha. Sem escolha feita, é o primeiro da lista (como antes).
  Filament? _filamentOf(_ColorLine line, List<Filament> filaments) =>
      filaments.where((f) => f.id == line.filamentId).firstOrNull ??
      filaments.firstOrNull;

  /// A receita para gravar: um filamento por linha, com as gramas.
  /// O mesmo filamento em duas linhas soma-se numa só: a base de dados
  /// só aceita cada filamento uma vez por variante (chave variant_id + filament_id).
  List<VariantFilament> _recipe(List<Filament> filaments) {
    final grams = <int, int>{};
    for (final line in _lines) {
      final filament = _filamentOf(line, filaments);
      final g = _read(line.grams).round();
      if (filament == null || g <= 0) continue; // linha vazia: não entra
      grams[filament.id] = (grams[filament.id] ?? 0) + g;
    }
    return [
      for (final entry in grams.entries)
        VariantFilament(filamentId: entry.key, grams: entry.value),
    ];
  }

  /// Muda as cores. (Antes, o nome da variante acompanhava as cores; agora a variante
  /// é um nome teu, como "Hamilton", e as cores são só a receita.)
  void _changeColors(List<Filament> filaments, void Function() change) => setState(change);

  /// Tira uma cor. O campo só se deita fora depois de sair do ecrã
  /// (deitá-lo fora já, com o campo ainda desenhado, dava erro).
  void _removeLine(_ColorLine line, List<Filament> filaments) {
    _changeColors(filaments, () => _lines.remove(line));
    WidgetsBinding.instance.addPostFrameCallback((_) => line.grams.dispose());
  }

  /// Junta o que está no cartão numa variante e grava-a.
  Future<void> _saveVariant() async {
    final v = widget.variant!;
    final filaments = ref.read(filamentsProvider).value ?? <Filament>[];
    setState(() => _savingVariant = true);

    // vazio = o próprio produto ("Modelo único"); o SKU é a API que o calcula a partir do nome
    final name = _nameController.text.trim();

    final updated = v.copyWith(
      name: name,
      weightG: _read(_weightController).round(),
      salePrice: _read(_priceController),
      printTimeMin: _read(_minutesController).round(),
      // todas as cores (antes gravava-se só uma, e uma 2.ª cor perdia-se sem aviso)
      filaments: _recipe(filaments),
      components: [
        for (final entry in _componentQty.entries)
          if (entry.value > 0)
            VariantComponent(componentId: entry.key, quantity: entry.value),
      ],
    );

    try {
      await ref.read(variantRepositoryProvider).update(updated);
    } catch (error) {
      // por exemplo: "Já existe uma variante com esse nome neste produto."
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Variante \"${name.isEmpty ? "Modelo único" : name}\" guardada.")));
  }

  /// Lê um número de um campo. Aceita vírgula ("29,90") e devolve 0 se estiver vazio.
  double _read(TextEditingController controller) {
    return double.tryParse(controller.text.replaceAll(",", ".")) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final filaments = ref.watch(filamentsProvider).value ?? <Filament>[];
    final channels = ref.watch(salesChannelsProvider).value ?? [];
    // a Etsy (as taxas); os outros canais são a venda direta
    final etsy = channels.where((c) => c.code == "etsy").firstOrNull;
    final direct = channels.where((c) => c.code != "etsy").toList();
    final allComponents = ref.watch(componentsProvider).value ?? [];
    final components = allComponents
        .where((c) => c.kind == ComponentKind.component)
        .toList();
    final packaging = allComponents
        .where((c) => c.kind == ComponentKind.packaging)
        .toList();
    final settings = ref.watch(costSettingsProvider).value;
    final target = settings?.targetMarginPct ?? 60;
    final minimum = settings?.minMarginPct ?? 35;
    final rounding = settings?.rounding ?? 0.50;

    // 1. ler o que está escrito
    final minutes = _read(_minutesController);
    final price = _read(_priceController);

    // 2. fazer as contas (sempre de novo, a cada desenho)
    // filamento: a soma de todas as cores, cada uma ao seu preço por kg
    // (a mesma conta que a lista de variantes faz, por isso batem certo)
    var filamentCost = 0.0;
    var totalGrams = 0.0;
    for (final line in _lines) {
      final filament = _filamentOf(line, filaments);
      final grams = _read(line.grams);
      totalGrams += grams;
      if (filament != null) {
        filamentCost += _calc.filamentCost(grams: grams, filament: filament);
      }
    }
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

    // um preço para todos os canais; mostram-se as duas contas lado a lado:
    // a Etsy (com as taxas) e a venda direta (Instagram, Facebook, em mão)
    final etsyFees = _feesFor(etsy, price);
    final directFees = direct.isEmpty
        ? 0.0
        : direct.map((c) => _feesFor(c, price)).reduce(math.max); // se algum tiver taxas, conta a maior
    final etsyProfit = price - production - etsyFees;
    final directProfit = price - production - directFees;
    final etsyMargin = _calc.marginPct(price: price, productionCost: production, fees: etsyFees);
    final directMargin = _calc.marginPct(price: price, productionCost: production, fees: directFees);
    // o preço sugerido conta com as taxas da Etsy (o canal mais caro):
    // assim a margem alvo vale na Etsy, e na venda direta fica acima
    final suggested = _calc.suggestedPrice(
      productionCost: production,
      targetMarginPct: target,
      rounding: rounding,
      transactionPct: etsy?.transactionFee ?? 0,
      processingPct: etsy?.processingFee ?? 0,
      flatFee: etsy?.flatFee ?? 0,
      listingFee: etsy?.listingFee ?? 0,
    );
    // a barra vai até ao dobro do sugerido, ou 50% acima do preço guardado (o maior dos dois)
    final savedPrice = widget.variant?.salePrice ?? 0;
    final sliderMax = math
        .max(suggested * 2, savedPrice * 1.5)
        .clamp(10.0, 1000.0);

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
                  : "Custo e margem · ${widget.variant!.label}",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            // o nome e o peso da variante; o SKU por baixo, só para ler (sai do nome)
            if (widget.variant != null) ...[
              LayoutBuilder(
                builder: (context, constraints) {
                  final name = TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Nome da variante",
                      hintText: "Ex.: Hamilton",
                      helperText: "Vazio = o produto não tem variantes.",
                    ),
                    onChanged: (_) => setState(() {}), // o SKU por baixo acompanha
                  );
                  final weight = TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.mono,
                    decoration: const InputDecoration(
                      labelText: "Peso",
                      suffixText: "g",
                      helperText: "Para os portes.",
                    ),
                  );

                  // com pouco espaço, o peso ficava espremido: passa para baixo do nome
                  if (constraints.maxWidth < 420) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [name, const SizedBox(height: 12), weight],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: name),
                      const SizedBox(width: 12),
                      Expanded(child: weight),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              _skuLine(),
              const SizedBox(height: 16),
            ],
            // as cores: uma linha por filamento (filamento + gramas)
            for (final (i, line) in _lines.indexed) ...[
              if (i > 0) const SizedBox(height: 12),
              _colorRow(line, i, filaments),
            ],
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _changeColors(filaments, () {
                  // começa no primeiro filamento que ainda não está na receita
                  final used = {for (final l in _lines) _filamentOf(l, filaments)?.id};
                  final next = filaments.where((f) => !used.contains(f.id)).firstOrNull;
                  _lines.add(_ColorLine(next?.id, ""));
                }),
                icon: const Icon(Icons.add),
                label: const Text("Adicionar cor"),
              ),
            ),
            if (_lines.length > 1)
              Text(
                "As gramas de cada cor estão no Bambu Studio, no consumo por filamento. "
                "Já incluem o que se gasta nas trocas de cor.",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minutesController,
                    style: AppTextStyles.mono,
                    decoration: const InputDecoration(
                      labelText: "Impressão",
                      suffixText: "min",
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                // o total das cores, para comparar com o peso da peça
                Expanded(
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: "Filamento total",
                      suffixText: "g",
                      filled: false,
                    ),
                    child: Text(totalGrams.round().toString(), style: AppTextStyles.mono),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _row(
              _lines.length > 1 ? "Filamento (${_lines.length} cores)" : "Filamento",
              filamentCost,
            ),
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
                    label: Text(
                      "${p.name} · ${euro(_calc.componentUnitCost(p))}",
                    ),
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
            const Divider(),
            _row("Custo de produção", production),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 150,
                  child: TextField(
                    controller: _priceController,
                    style: AppTextStyles.mono,
                    // o € como sufixo: a etiqueta curta cabe inteira no telemóvel
                    decoration: const InputDecoration(
                      labelText: "Preço de venda",
                      suffixText: "€",
                    ),
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
            // as duas contas lado a lado (uma por baixo da outra no telemóvel)
            LayoutBuilder(
              builder: (context, constraints) {
                final etsyBox = _marginBox("Etsy", etsyFees, etsyProfit, etsyMargin, target, minimum);
                final directBox = _marginBox(
                  "Venda direta", directFees, directProfit, directMargin, target, minimum,
                  hint: direct.map((c) => c.name).join(", "),
                );
                if (constraints.maxWidth < 480) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [etsyBox, const SizedBox(height: 12), directBox],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: etsyBox),
                    const SizedBox(width: 12),
                    Expanded(child: directBox),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            _row(
              "Preço sugerido (margem ${target.toStringAsFixed(0)}% na Etsy)",
              suggested,
            ),
            Text(
              "Um só preço para todos os canais: o sugerido já paga as taxas da Etsy; "
              "na venda direta ganhas mais.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (widget.variant != null) ...[
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _savingVariant
                    ? null
                    : _saveVariant,
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
  /// Uma cor: o menu do filamento, as gramas e (havendo mais do que uma) o ✕ para a tirar.
  Widget _colorRow(_ColorLine line, int index, List<Filament> filaments) {
    final filament = _filamentOf(line, filaments);

    return Row(
      // a key é a própria linha: ao tirar uma cor do meio, as outras não trocam de estado
      key: ObjectKey(line),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            // a key muda com o filamento: o menu acompanha quando muda por fora
            key: ValueKey(filament?.id),
            initialValue: filament?.id,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: _lines.length > 1 ? "Cor ${index + 1}" : "Filamento",
            ),
            hint: const Text("A carregar filamentos…"),
            // fechado mostra a cor primeiro: no telemóvel o texto é cortado, e
            // "PLA Blac…" em todas as linhas não deixava distinguir as cores
            selectedItemBuilder: (context) => [
              for (final f in filaments)
                Text("${f.colorName} · ${f.material}", overflow: TextOverflow.ellipsis),
            ],
            items: [
              for (final f in filaments)
                DropdownMenuItem(
                  value: f.id,
                  child: Text(
                    "${f.material} · ${f.colorName} — ${euroPer(_calc.filamentPricePerKg(f), "kg")}",
                  ),
                ),
            ],
            onChanged: (id) => _changeColors(filaments, () => line.filamentId = id),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 96,
          child: TextField(
            controller: line.grams,
            style: AppTextStyles.mono,
            decoration: const InputDecoration(labelText: "Gramas", suffixText: "g"),
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
          ),
        ),
        if (_lines.length > 1)
          IconButton(
            tooltip: "Tirar esta cor",
            onPressed: () => _removeLine(line, filaments),
            icon: const Icon(Icons.close),
          ),
      ],
    );
  }

  /// O SKU que a variante vai ter com o nome escrito, e um aviso se for diferente do gravado
  /// (a Etsy liga as encomendas pelo SKU: se mudar aqui, tem de mudar lá).
  Widget _skuLine() {
    final v = widget.variant!;
    final product = (ref.watch(productsProvider).value ?? [])
        .where((p) => p.id == v.productId)
        .firstOrNull;
    final next = product == null ? v.sku : variantSku(product.baseSku, _nameController.text);
    final changes = next != v.sku;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("SKU $next", style: AppTextStyles.mono),
        if (changes)
          Text(
            "O SKU muda (era ${v.sku}). Se esta variante está na Etsy, muda-o lá também.",
            style: const TextStyle(color: Color(0xFFB45309), fontSize: 12),
          ),
      ],
    );
  }

  Widget _row(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2), // era 4
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
          child: Text(
            "${c.name} · ${euroPer(_calc.componentUnitCost(c), "un.", decimals: 3)}",
          ),
        ),
        IconButton(
          icon: const Icon(Icons.remove),
          iconSize: 18,
          visualDensity: VisualDensity.compact,
          onPressed: qty == 0
              ? null
              : () => setState(() => _componentQty[c.id] = qty - 1),
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

  /// As taxas de um canal para uma unidade vendida a este preço (0 sem canal).
  double _feesFor(SalesChannel? c, double price) => c == null
      ? 0
      : _calc.channelFees(
          price: price,
          transactionPct: c.transactionFee,
          processingPct: c.processingFee,
          flatFee: c.flatFee,
          listingFee: c.listingFee,
        );

  /// A conta de um canal: taxas, lucro e margem, com a cor da margem.
  Widget _marginBox(
    String title,
    double fees,
    double profit,
    double margin,
    double target,
    double minimum, {
    String? hint,
  }) {
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
        color: color.withValues(
          alpha: 0.10,
        ), // a mesma cor, muito clara, no fundo
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          if (hint != null && hint.isNotEmpty)
            Text(hint, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text("Taxas ${euro(fees)}", style: AppTextStyles.mono),
          const SizedBox(height: 4),
          Text(
            "${euro(profit)} · ${margin.toStringAsFixed(0)}%",
            style: AppTextStyles.mono.copyWith(
              fontSize: 22,
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

/// Uma cor da peça: o filamento escolhido (null = o primeiro da lista) e as gramas.
class _ColorLine {
  _ColorLine(this.filamentId, String grams) : grams = TextEditingController(text: grams);

  int? filamentId;
  final TextEditingController grams;
}
