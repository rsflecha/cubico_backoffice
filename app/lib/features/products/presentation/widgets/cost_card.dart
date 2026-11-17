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

/// A receita e o preço de UMA variante. Não grava nada sozinho: quem grava é a ficha do
/// produto, com o seu único "Guardar", que lê o que está aqui por uma `GlobalKey<CostCardState>`
/// (applyTo, isChangedFrom e problem).
class CostCard extends ConsumerStatefulWidget {
  const CostCard({super.key, this.variant, this.showName = false});

  /// A variante a editar. null = produto novo (os campos começam vazios).
  final Variant? variant;

  /// Mostrar o campo "Nome da variante"? Só quando o produto tem variantes (Hamilton, Verstappen…).
  final bool showName;

  @override
  ConsumerState<CostCard> createState() => CostCardState();
}

class CostCardState extends ConsumerState<CostCard> {
  static const _calc = CostCalculator();

  // As cores da peça: uma linha por filamento, cada uma com as suas gramas.
  // Uma peça de uma cor só tem uma linha (como era antes).
  final List<_ColorLine> _lines = [];
  // Quantidade de cada componente: id do componente → quantidade.
  final Map<int, int> _componentQty = {};
  // vazios num produto novo: valores de exemplo podiam ficar gravados sem se dar por isso
  final _minutesController = TextEditingController();
  final _priceController = TextEditingController();
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
    // sem receita: uma linha com o primeiro filamento, e as gramas por escrever
    if (_lines.isEmpty) _lines.add(_ColorLine(null, ""));
    if (v == null) return; // produto novo: campos vazios

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

  /// A variante [base] com o que está escrito no cartão (ainda por gravar).
  Variant applyTo(Variant base) {
    final filaments = ref.read(filamentsProvider).value ?? <Filament>[];
    return base.copyWith(
      // vazio = o próprio produto ("Modelo único"); o SKU é a API que o calcula a partir do nome
      name: widget.showName ? _nameController.text.trim() : base.name,
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
  }

  /// Há alguma coisa escrita que ainda não está gravada em [base]?
  /// (null = produto novo: conta como mudado se já se escreveu alguma coisa)
  bool isChangedFrom(Variant? base) {
    if (base == null) {
      return [_minutesController, _priceController, _weightController, ..._lines.map((l) => l.grams)]
              .any((c) => c.text.trim().isNotEmpty) ||
          _componentQty.values.any((q) => q > 0);
    }
    final now = applyTo(base);
    // a ordem das linhas da receita não conta: compara-se ordenado
    String key(Iterable<String> items) => (items.toList()..sort()).join(",");
    return now.name != base.name ||
        now.weightG != base.weightG ||
        (now.salePrice - base.salePrice).abs() > 0.001 ||
        now.printTimeMin != base.printTimeMin ||
        key(now.filaments.map((f) => "${f.filamentId}:${f.grams}")) !=
            key(base.filaments.map((f) => "${f.filamentId}:${f.grams}")) ||
        key(now.components.map((c) => "${c.componentId}:${c.quantity}")) !=
            key(base.components.map((c) => "${c.componentId}:${c.quantity}"));
  }

  /// O primeiro problema que impede de gravar a variante, ou null.
  /// Sem preço, a encomenda chegava a 0,00 €; sem gramas nem tempo, o custo ficava a 0.
  String? problem() {
    final filaments = ref.read(filamentsProvider).value ?? <Filament>[];
    if (_recipe(filaments).isEmpty) return "Escreve as gramas de filamento.";
    if (_read(_minutesController) <= 0) return "Escreve o tempo de impressão.";
    if (_read(_weightController) <= 0) return "Escreve o peso da peça (para os portes).";
    if (_read(_priceController) <= 0) return "Escreve o preço de venda.";
    return null;
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
            // o nome (só com variantes) e o peso; o SKU por baixo, só para ler (sai do nome)
            ...[
              LayoutBuilder(
                builder: (context, constraints) {
                  if (!widget.showName) return _weightField();
                  final name = TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Nome da variante",
                      hintText: "Ex.: Hamilton",
                      helperText: "Vazio = o produto não tem variantes.",
                    ),
                    onChanged: (_) => setState(() {}), // o SKU por baixo acompanha
                  );
                  final weight = _weightField();

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
              if (widget.showName && widget.variant != null) ...[
                _skuLine(),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 8),
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
          ],
        ),
      ),
    );
  }

  /// O peso da peça, para os portes.
  Widget _weightField() => TextField(
        controller: _weightController,
        keyboardType: TextInputType.number,
        style: AppTextStyles.mono,
        decoration: const InputDecoration(
          labelText: "Peso da peça",
          suffixText: "g",
          helperText: "Para os portes.",
        ),
        onChanged: (_) => setState(() {}),
      );

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
