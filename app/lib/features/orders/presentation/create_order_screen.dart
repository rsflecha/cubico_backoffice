import 'package:cubico_backoffice/app/theme.dart';
import 'package:cubico_backoffice/features/costs/domain/component.dart';
import 'package:cubico_backoffice/features/costs/domain/cost_calculator.dart';
import 'package:cubico_backoffice/features/costs/domain/filament.dart';
import 'package:cubico_backoffice/features/costs/domain/sales_channel.dart';
import 'package:cubico_backoffice/features/costs/domain/shipping_rate.dart';
import 'package:cubico_backoffice/features/costs/presentation/costs_providers.dart';
import 'package:cubico_backoffice/features/customers/domain/customer.dart';
import 'package:cubico_backoffice/features/customers/presentation/customers_providers.dart';
import 'package:cubico_backoffice/features/orders/domain/order.dart';
import 'package:cubico_backoffice/features/orders/presentation/order_labels.dart';
import 'package:cubico_backoffice/features/orders/presentation/orders_providers.dart';
import 'package:cubico_backoffice/features/products/domain/product.dart';
import 'package:cubico_backoffice/features/products/domain/variant.dart';
import 'package:cubico_backoffice/features/products/presentation/products_providers.dart';
import 'package:cubico_backoffice/core/formatting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';

/// Os métodos de pagamento (do seed.sql). Mais tarde vêm das definições.
const _paymentMethods = ["MB WAY", "Transferência", "Dinheiro"];

/// Criar uma encomenda à mão: vendas pessoalmente, pelo Instagram ou pelo Facebook.
class CreateOrderScreen extends ConsumerStatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  ConsumerState<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends ConsumerState<CreateOrderScreen> {
  int? _channelId;
  final _customerName = TextEditingController();
  final _customerContact = TextEditingController();
  final _shippingCharged = TextEditingController(text: "0,00"); // o que o cliente paga de portes
  var _delivery = DeliveryMethod.hand;
  DateTime? _shipByDate;
  var _paymentMethod = _paymentMethods.first;
  var _paymentStatus = PaymentStatus.paid;
  final _notes = TextEditingController();
  final List<_DraftLine> _lines = [];
  var _submitted = false; // já se carregou em "Criar"? (para mostrar os problemas)
  var _saving = false;
  int? _customerId; // o cliente com ficha, se se associou um

  @override
  void dispose() {
    for (final c in [_customerName, _customerContact, _notes]) {
      c.dispose();
    }
    for (final line in _lines) {
      line.dispose();
    }
    for (final c in [_customerName, _customerContact, _notes, _shippingCharged]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Abre o calendário para escolher o prazo.
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _shipByDate ?? now.add(const Duration(days: 3)),
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _shipByDate = picked);
  }

  /// Escolhe um cliente com ficha e preenche o nome e o contacto.
  Future<void> _pickCustomer() async {
    final customers = ref.read(customersProvider).value ?? <Customer>[];
    final chosen = await showDialog<Customer>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text("Associar a um cliente"),
        children: [
          if (customers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text("Ainda não há clientes com ficha."),
            ),
          for (final c in customers)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, c),
              child: ListTile(
                title: Text(c.name),
                subtitle: Text(c.email ?? c.phone ?? (c.instagram == null ? "" : "@${c.instagram}")),
              ),
            ),
        ],
      ),
    );
    if (chosen == null) return;
    setState(() {
      _customerId = chosen.id;
      _customerName.text = chosen.name;
      _customerContact.text =
          chosen.phone ?? chosen.email ?? (chosen.instagram == null ? "" : "@${chosen.instagram}");
    });
  }

  /// Abre a lista do catálogo e junta a variante escolhida às linhas.
  Future<void> _addProduct(List<Product> products, List<Variant> variants) async {
    final chosen = await showDialog<Variant>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text("Escolher produto"),
        children: [
          for (final product in products)
          // só os produtos que têm variantes
            if (variants.any((v) => v.productId == product.id)) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
                child: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              for (final v in variants.where((v) => v.productId == product.id))
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, v),
                  child: Row(
                    children: [
                      Expanded(child: Text(v.name)),
                      Text(euro(v.salePrice), style: AppTextStyles.mono),
                    ],
                  ),
                ),
            ],
        ],
      ),
    );
    if (chosen == null) return;
    setState(() => _lines.add(_DraftLine(chosen)));
  }

  /// Tira uma linha (e arruma os campos dela).
  void _removeLine(_DraftLine line) {
    setState(() => _lines.remove(line));
    line.dispose();
  }

  static const _calc = CostCalculator();

  /// O peso de envio de todas as linhas.
  int _totalWeight(List<Component> components) {
    var total = 0;
    for (final line in _lines) {
      final qty = parseDecimal(line.quantity.text).round();
      total += qty * _calc.variantShippingWeightG(variant: line.variant, components: components);
    }
    return total;
  }

  /// Junta tudo o que está escrito numa encomenda. Serve para o resumo E para gravar.
  Order _draftOrder(
      SalesChannel? channel,
      List<Filament> filaments,
      List<Component> components,
      double perHour,
      List<ShippingRate> rates,
      ) {
    final now = DateTime.now();
    final contact = _customerContact.text.trim();
    final notes = _notes.text.trim();
    final byCarrier = _delivery == DeliveryMethod.carrier;

    return Order(
      id: 0,
      orderNumber: 0,
      channelId: channel?.id ?? 0,
      customerId: _customerId,
      customerName: _customerName.text.trim(),
      customerContact: contact.isEmpty ? null : contact,
      paymentStatus: _paymentStatus,
      paymentMethod: _paymentMethod,
      deliveryMethod: _delivery,
      carrierName: byCarrier ? "CTT" : null,
      shippingCharged: byCarrier ? parseDecimal(_shippingCharged.text) : 0,
      // os portes reais: o escalão do Correio Registado (zona 1, Portugal) para o peso total
      shippingPaid: byCarrier
          ? _calc.shippingPrice(weightG: _totalWeight(components), zoneId: 1, rates: rates) ?? 0
          : 0,
      shipByDate: _shipByDate,
      notes: notes.isEmpty ? null : notes,
      createdManually: true,
      isSeen: true,
      createdAt: now,
      updatedAt: now,
      lines: [
        for (var i = 0; i < _lines.length; i++)
          _orderLine(_lines[i], isFirst: i == 0, channel, filaments, components, perHour),
      ],
    );
  }


  /// Uma linha da encomenda, com as "fotografias" do custo e da taxa do canal.
  OrderLine _orderLine(
      _DraftLine line,
      SalesChannel? channel,
      List<Filament> filaments,
      List<Component> components,
      double perHour, {
        required bool isFirst,
      }) {
    final qty = parseDecimal(line.quantity.text).round();
    final unitPrice = parseDecimal(line.price.text);
    final customization = line.customization.text.trim();

    return OrderLine(
      id: 0,
      variantId: line.variant.id,
      quantity: qty,
      unitPrice: unitPrice,
      customization: customization.isEmpty ? null : customization,
      // a fotografia do custo de produção, neste momento
      unitCost: _calc.variantProductionCost(
        variant: line.variant,
        filaments: filaments,
        components: components,
        costPerHour: perHour,
      ),
      // as percentagens do canal sobre esta linha; os valores fixos só uma vez, na primeira
      channelFee: _calc.channelFees(
        price: qty * unitPrice,
        transactionPct: channel?.transactionFee ?? 0,
        processingPct: channel?.processingFee ?? 0,
        flatFee: isFirst ? channel?.flatFee ?? 0 : 0,
        listingFee: isFirst ? channel?.listingFee ?? 0 : 0,
      ),
    );
  }

  /// O primeiro problema que impede de criar, ou null.
  String? _problem(
      Order draft,
      SalesChannel? channel,
      List<Component> components,
      List<ShippingRate> rates,
      ) {
    if (channel == null) return "Escolhe a origem.";
    if (draft.customerName.isEmpty) return "Escreve para quem é.";
    if (draft.lines.isEmpty) return "Junta pelo menos um artigo.";
    if (draft.lines.any((l) => l.quantity < 1)) return "Cada artigo tem de ter quantidade 1 ou mais.";
    if (draft.lines.any((l) => l.unitPrice <= 0)) return "Cada artigo tem de ter preço.";
    if (_delivery == DeliveryMethod.carrier &&
        _calc.shippingPrice(weightG: _totalWeight(components), zoneId: 1, rates: rates) == null) {
      return "O pacote é demasiado pesado para o correio (mais de 2 kg).";
    }
    return null;
  }

  /// Grava a encomenda e abre o detalhe dela.
  Future<void> _create(Order draft, String? problem) async {
    setState(() => _submitted = true);
    if (problem != null) return;

    setState(() => _saving = true);
    final Order created;
    try {
      created = await ref.read(orderRepositoryProvider).create(draft);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Não foi possível criar: $error")),
      );
      return;
    }
    ref.invalidate(ordersProvider);
    if (!mounted) return;
    // troca este ecrã pelo detalhe: o "voltar" do detalhe leva à lista, e não a este formulário
    context.pushReplacement("/orders/${created.id}");
  }

  @override
  Widget build(BuildContext context) {
    // só os canais manuais: a Etsy entra sozinha
    final channels = (ref.watch(salesChannelsProvider).value ?? <SalesChannel>[])
        .where((c) => !c.isAutomatic)
        .toList();
    final channel = channels.where((c) => c.id == _channelId).firstOrNull ?? channels.firstOrNull;
    final products = ref.watch(productsProvider).value ?? <Product>[];
    final variants = ref.watch(allVariantsProvider).value ?? <Variant>[];
    final filaments = ref.watch(filamentsProvider).value ?? <Filament>[];
    final components = ref.watch(componentsProvider).value ?? <Component>[];
    final perHour = ref.watch(printerCostPerHourProvider);
    final rates = ref.watch(shippingRatesProvider).value ?? <ShippingRate>[];
    final canSeeCosts = ref.watch(sessionProvider)?.canSeeCosts ?? false;

    final draft = _draftOrder(channel, filaments, components, perHour, rates);
    final problem = _problem(draft, channel, components, rates);

    final isWide = MediaQuery.sizeOf(context).width >= 1100;

    final form = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _section(
          "1 · Origem",
          [
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
          ],
        ),
        _section(
          "2 · Para quem?",
          [
            Text(
              "Só um nome para saberes de quem é. Não cria ficha de cliente.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _customerName,
                    decoration: const InputDecoration(
                      labelText: "Nome ou referência",
                      hintText: "Ex.: D. Lurdes, vizinha da tia",
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _customerContact,
                    decoration: const InputDecoration(
                      labelText: "Contacto (opcional)",
                      hintText: "Telemóvel ou @instagram",
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: _customerId == null
                  ? TextButton.icon(
                onPressed: _pickCustomer,
                icon: const Icon(Icons.person_search_outlined),
                label: const Text("Associar a um cliente existente"),
              )
                  : InputChip(
                avatar: const Icon(Icons.person_outline, size: 18),
                label: const Text("Associada à ficha do cliente"),
                onDeleted: () => setState(() => _customerId = null),
              ),
            ),
          ],
        ),
        _section(
          "3 · Artigos",
          [
            for (final line in _lines) _lineCard(line, products),
            OutlinedButton.icon(
              onPressed: () => _addProduct(products, variants),
              icon: const Icon(Icons.add),
              label: const Text("Adicionar produto do catálogo"),
            ),
          ],
        ),
        _section(
          "4 · Entrega",
          [
            Wrap(
              spacing: 8,
              children: [
                for (final method in [DeliveryMethod.hand, DeliveryMethod.pickup, DeliveryMethod.carrier])
                  ChoiceChip(
                    label: Text(method == DeliveryMethod.carrier ? "Envio CTT" : method.label),
                    selected: _delivery == method,
                    onSelected: (_) => setState(() => _delivery = method),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _delivery == DeliveryMethod.carrier
                  ? "Os portes entram no lucro: o que o cliente paga e o que custa enviar."
                  : "Sem portes. Fica «Pronta» quando a produção terminar.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (_delivery == DeliveryMethod.carrier) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: 220,
                child: TextField(
                  controller: _shippingCharged,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: AppTextStyles.mono,
                  decoration: const InputDecoration(
                    labelText: "Portes cobrados ao cliente",
                    suffixText: "€",
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.event_outlined),
                label: Text(_shipByDate == null ? "Escolher prazo" : "Prazo: ${shortDate(_shipByDate!)}"),
              ),
            ),
          ],
        ),
        _section(
          "5 · Pagamento e notas",
          [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _paymentMethod,
                    decoration: const InputDecoration(labelText: "Método"),
                    items: [
                      for (final m in _paymentMethods)
                        DropdownMenuItem(value: m, child: Text(m)),
                    ],
                    onChanged: (v) => setState(() => _paymentMethod = v ?? _paymentMethod),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<PaymentStatus>(
                    initialValue: _paymentStatus,
                    decoration: const InputDecoration(labelText: "Estado"),
                    items: [
                      for (final s in [PaymentStatus.paid, PaymentStatus.unpaid])
                        DropdownMenuItem(value: s, child: Text(s.label)),
                    ],
                    onChanged: (v) => setState(() => _paymentStatus = v ?? _paymentStatus),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Notas internas",
                hintText: "Algo a ter em conta nesta encomenda",
              ),
            ),
          ],
        ),
      ],
    );

    final summary = _summaryCard(channel, draft, problem, canSeeCosts);

    return Scaffold(
      appBar: AppBar(title: const Text("Criar encomenda")),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            "Para vendas feitas pessoalmente, pelo Instagram ou pelo Facebook. As da Etsy entram sozinhas.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: form),
                const SizedBox(width: 24),
                Expanded(flex: 2, child: summary),
              ],
            )
          else ...[
            form,
            summary,
          ],
        ],
      ),
    );
  }

  /// Uma secção numerada do formulário.
  Widget _section(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
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
      ),
    );
  }

  /// O cartão de uma linha: produto e variante, quantidade, preço, personalização.
  Widget _lineCard(_DraftLine line, List<Product> products) {
    final product = products.where((p) => p.id == line.variant.productId).firstOrNull;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE4E4E7)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product?.name ?? "Produto",
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      "Variante: ${line.variant.name} · ${line.variant.sku}",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: line.quantity,
                  keyboardType: TextInputType.number,
                  style: AppTextStyles.mono,
                  decoration: const InputDecoration(labelText: "Qtd."),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 120,
                child: TextField(
                  controller: line.price,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: AppTextStyles.mono,
                  decoration: const InputDecoration(labelText: "Preço un.", suffixText: "€"),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              IconButton(
                tooltip: "Tirar",
                onPressed: () => _removeLine(line),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: line.customization,
            decoration: const InputDecoration(
              labelText: "Personalização (opcional)",
              hintText: "Ex.: CARLA, NUNO",
            ),
          ),
        ],
      ),
    );
  }

  /// O resumo à direita: as contas vêm do próprio rascunho da encomenda.
  Widget _summaryCard(SalesChannel? channel, Order draft, String? problem, bool canSeeCosts) {
    final margin = draft.total > 0 ? draft.profit / draft.total * 100 : 0;

    Widget line(String label, String value, {bool bold = false, Color? color}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(fontWeight: bold ? FontWeight.w700 : null, color: color)),
          ),
          Text(value,
              style: AppTextStyles.mono.copyWith(
                  fontWeight: bold ? FontWeight.w700 : null, color: color)),
        ],
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Resumo", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            line("Origem", channel?.name ?? "—"),
            line("Para quem", draft.customerName.isEmpty ? "—" : draft.customerName),
            const Divider(),
            line("Artigos (${draft.itemCount})", euro(draft.itemsTotal)),
            line("Portes cobrados", euro(draft.shippingCharged)),
            line("Total", euro(draft.total), bold: true),
            // o custo e o lucro, só para quem pode ver
            if (canSeeCosts) ...[
              const SizedBox(height: 8),
              line("Custo estimado", euro(draft.cost)),
              line(
                "Lucro estimado",
                "${euro(draft.profit)} · ${margin.toStringAsFixed(0)}%",
                bold: true,
                color: profitColor(draft),
              ),
              if (_delivery == DeliveryMethod.carrier)
                Text(
                  "Inclui ${euro(draft.shippingPaid)} de portes reais (CTT Registado).",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
            const SizedBox(height: 16),
            if (_submitted && problem != null) ...[
              Text(problem, style: const TextStyle(color: Color(0xFFB91C1C))),
              const SizedBox(height: 8),
            ],
            FilledButton(
              onPressed: _saving ? null : () => _create(draft, problem),
              child: _saving
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text("Criar encomenda"),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar"),
            ),
          ],
        ),
      ),
    );
  }
}

/// Uma linha da encomenda enquanto se preenche: a variante e os seus campos.
class _DraftLine {
  _DraftLine(this.variant)
      : quantity = TextEditingController(text: "1"),
        price = TextEditingController(text: decimalField(variant.salePrice)),
        customization = TextEditingController();

  final Variant variant;
  final TextEditingController quantity;
  final TextEditingController price;
  final TextEditingController customization;

  void dispose() {
    quantity.dispose();
    price.dispose();
    customization.dispose();
  }
}