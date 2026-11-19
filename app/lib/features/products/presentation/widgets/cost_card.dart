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
///
/// Um campo por coisa: as gramas (que são também o peso, para os portes) e o tempo.
/// As cores escolhem-se à esquerda, nas "Cores disponíveis"; o custo do filamento
/// faz-se com a MAIS CARA delas, para nenhuma cor dar prejuízo.
class CostCard extends ConsumerStatefulWidget {
  const CostCard({super.key, this.variant, this.showName = false, this.colorIds = const []});

  /// A variante a editar. null = produto novo (os campos começam vazios).
  final Variant? variant;

  /// Mostrar o campo "Nome da variante"? Só quando o produto tem variantes (Hamilton, Verstappen…).
  final bool showName;

  /// As cores disponíveis do produto (ids dos filamentos), escolhidas na ficha.
  final List<int> colorIds;

  @override
  ConsumerState<CostCard> createState() => CostCardState();
}

class CostCardState extends ConsumerState<CostCard> {
  static const _calc = CostCalculator();

  // Quantidade de cada componente: id do componente → quantidade.
  final Map<int, int> _componentQty = {};
  // vazios num produto novo: valores de exemplo podiam ficar gravados sem se dar por isso
  final _gramsController = TextEditingController();
  final _minutesController = TextEditingController();
  final _priceController = TextEditingController();
  // o nome da variante (só com variantes); o SKU sai do nome
  final _nameController = TextEditingController();

  @override
  void dispose() {
    for (final c in [_gramsController, _minutesController, _priceController, _nameController]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final v = widget.variant;
    if (v == null) return; // produto novo: campos vazios

    // as gramas: a soma da receita (receitas antigas podiam ter várias cores);
    // sem receita, o peso que estava gravado
    final grams = v.filaments.fold<int>(0, (sum, f) => sum + f.grams);
    final shown = grams > 0 ? grams : v.weightG;
    _gramsController.text = shown > 0 ? "$shown" : "";
    _minutesController.text = "${v.printTimeMin}";
    _priceController.text = decimalField(v.salePrice);
    _nameController.text = v.name;

    for (final line in v.components) {
      _componentQty[line.componentId] = line.quantity;
    }
  }

  /// O filamento com que se faz o custo: a cor mais cara das disponíveis.
  /// Sem cores escolhidas (ainda), o da receita gravada, ou o primeiro da lista.
  Filament? _costFilament(List<Filament> filaments) {
    final priciest = _calc.priciestFilament(filaments, widget.colorIds);
    if (priciest != null) return priciest;
    final saved = widget.variant == null ? null : _calc.mainFilament(widget.variant!);
    return filaments.where((f) => f.id == saved?.filamentId).firstOrNull ?? filaments.firstOrNull;
  }

  /// A variante [base] com o que está escrito no cartão (ainda por gravar).
  Variant applyTo(Variant base) {
    final filaments = ref.read(filamentsProvider).value ?? <Filament>[];
    final grams = _read(_gramsController).round();
    final filament = _costFilament(filaments);
    return base.copyWith(
      // vazio = o próprio produto ("Modelo único"); o SKU é a API que o calcula a partir do nome
      name: widget.showName ? _nameController.text.trim() : base.name,
      weightG: grams, // o peso da peça é o filamento que leva
      salePrice: _read(_priceController),
      printTimeMin: _read(_minutesController).round(),
      // uma linha: as gramas, na cor mais cara (a da encomenda escolhe-se ao vender)
      filaments: [if (filament != null && grams > 0) VariantFilament(filamentId: filament.id, grams: grams)],
      components: [
        for (final entry in _componentQty.entries)
          if (entry.value > 0) VariantComponent(componentId: entry.key, quantity: entry.value),
      ],
    );
  }

  /// Há alguma coisa escrita que ainda não está gravada em [base]?
  /// (null = produto novo: conta como mudado se já se escreveu alguma coisa)
  bool isChangedFrom(Variant? base) {
    if (base == null) {
      return [_gramsController, _minutesController, _priceController].any((c) => c.text.trim().isNotEmpty) ||
          _componentQty.values.any((q) => q > 0);
    }
    final now = applyTo(base);
    // a ordem das linhas não conta: compara-se ordenado
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
    if (_read(_gramsController) <= 0) return "Escreve as gramas de filamento.";
    if (_read(_minutesController) <= 0) return "Escreve o tempo de impressão.";
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
    final components = allComponents.where((c) => c.kind == ComponentKind.component).toList();
    final packaging = allComponents.where((c) => c.kind == ComponentKind.packaging).toList();
    final settings = ref.watch(costSettingsProvider).value;
    final target = settings?.targetMarginPct ?? 60;
    final minimum = settings?.minMarginPct ?? 35;
    final rounding = settings?.rounding ?? 0.50;

    // 1. ler o que está escrito
    final grams = _read(_gramsController);
    final minutes = _read(_minutesController);
    final price = _read(_priceController);

    // 2. fazer as contas (sempre de novo, a cada desenho)
    // filamento: as gramas ao preço por kg da cor mais cara das disponíveis
    final costFilament = _costFilament(filaments);
    final filamentCost = costFilament == null ? 0.0 : _calc.filamentCost(grams: grams, filament: costFilament);
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
    final sliderMax = math.max(suggested * 2, savedPrice * 1.5).clamp(10.0, 1000.0);

    // 3. mostrar
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              // modelo único (sem nome): só "Custo e margem"; com variante, o nome dela
              widget.variant == null || widget.variant!.isUnnamed
                  ? "Custo e margem"
                  : "Custo e margem · ${widget.variant!.name}",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            // o nome (só com variantes); o SKU por baixo, só para ler (sai do nome)
            if (widget.showName) ...[
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nome da variante",
                  hintText: "Ex.: Hamilton",
                  helperText: "Vazio = o produto não tem variantes.",
                ),
                onChanged: (_) => setState(() {}), // o SKU por baixo acompanha
              ),
              if (widget.variant != null) ...[const SizedBox(height: 8), _skuLine()],
              const SizedBox(height: 16),
            ],
            // as gramas (são também o peso, para os portes) e o tempo, lado a lado
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _gramsController,
                    style: AppTextStyles.mono,
                    decoration: const InputDecoration(
                      labelText: "Gramas",
                      suffixText: "g",
                      helperText: "O peso da peça. Conta para os portes.",
                      helperMaxLines: 2,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _minutesController,
                    style: AppTextStyles.mono,
                    decoration: const InputDecoration(labelText: "Impressão", suffixText: "min"),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _row(
              costFilament == null
                  ? "Filamento"
                  : "Filamento (${costFilament.colorName}, ${euroPer(_calc.filamentPricePerKg(costFilament), "kg")})",
              filamentCost,
            ),
            if (widget.colorIds.length > 1)
              Text("Custo feito com a cor mais cara das disponíveis.", style: Theme.of(context).textTheme.bodySmall),
            _row("Impressão", printing),
            const SizedBox(height: 12),
            Text("Componentes", style: Theme.of(context).textTheme.labelLarge),
            for (final c in components) _componentRow(c),
            _row("Componentes", componentsCost),

            const SizedBox(height: 12),
            Text("Embalagem", style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            // telemóvel: uma embalagem por linha, com a largura toda (como as cores)
            if (MediaQuery.sizeOf(context).width < 600)
              for (final p in packaging)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text("${_withSize(p)} · ${euro(_calc.componentUnitCost(p))}"),
                  value: (_componentQty[p.id] ?? 0) > 0,
                  onChanged: (on) => _togglePackaging(p.id, on ?? false),
                )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final p in packaging)
                    FilterChip(
                      label: Text("${_withSize(p)} · ${euro(_calc.componentUnitCost(p))}"),
                      selected: (_componentQty[p.id] ?? 0) > 0,
                      onSelected: (on) => _togglePackaging(p.id, on),
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
                    decoration: const InputDecoration(labelText: "Preço de venda", suffixText: "€"),
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
                  "Venda direta",
                  directFees,
                  directProfit,
                  directMargin,
                  target,
                  minimum,
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
            _row("Preço sugerido (margem ${target.toStringAsFixed(0)}% na Etsy)", suggested),
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

  /// O SKU que a variante vai ter com o nome escrito, e um aviso se for diferente do gravado
  /// (a Etsy liga as encomendas pelo SKU: se mudar aqui, tem de mudar lá).
  Widget _skuLine() {
    final v = widget.variant!;
    final product = (ref.watch(productsProvider).value ?? []).where((p) => p.id == v.productId).firstOrNull;
    // como na API: mudar o nome não muda o SKU; só ganhar nome (número novo) ou perdê-lo (o do produto)
    final siblings = (ref.watch(allVariantsProvider).value ?? <Variant>[])
        .where((s) => s.productId == v.productId)
        .map((s) => s.sku);
    final named = _nameController.text.trim().isNotEmpty;
    final next = product == null
        ? v.sku
        : !named
            ? product.baseSku
            : v.isUnnamed
                ? variantSku(product.baseSku, nextVariantNumber(product.baseSku, siblings))
                : v.sku;
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
        Expanded(child: Text("${_withSize(c)} · ${euroPer(_calc.componentUnitCost(c), "un.", decimals: 3)}")),
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

  /// O nome com o tamanho, para saber que caixa ou que saco é: "Caixa 15 × 10 × 5 cm".
  /// Sem tamanho escrito (Custos e preços → Componentes), só o nome.
  /// Marca ou desmarca uma embalagem (1 unidade).
  void _togglePackaging(int id, bool on) => setState(() {
        if (on) {
          _componentQty[id] = 1;
        } else {
          _componentQty.remove(id);
        }
      });

  String _withSize(Component c) {
    final size = c.sizeLabel?.trim() ?? "";
    return size.isEmpty ? c.name : "${c.name} $size";
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
        color: color.withValues(alpha: 0.10), // a mesma cor, muito clara, no fundo
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          if (hint != null && hint.isNotEmpty) Text(hint, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text("Taxas ${euro(fees)}", style: AppTextStyles.mono),
          const SizedBox(height: 4),
          Text(
            "${euro(profit)} · ${margin.toStringAsFixed(0)}%",
            style: AppTextStyles.mono.copyWith(fontSize: 22, fontWeight: FontWeight.w700, color: color),
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
