import 'package:cubico_backoffice/app/theme.dart';
import 'package:cubico_backoffice/features/costs/domain/sales_channel.dart';
import 'package:cubico_backoffice/features/costs/presentation/costs_providers.dart';
import 'package:cubico_backoffice/features/orders/domain/order.dart';
import 'package:cubico_backoffice/features/orders/presentation/order_labels.dart';
import 'package:cubico_backoffice/features/products/domain/product.dart';
import 'package:cubico_backoffice/features/products/domain/variant.dart';
import 'package:cubico_backoffice/features/products/presentation/products_providers.dart';
import 'package:cubico_backoffice/core/formatting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

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
  var _delivery = DeliveryMethod.hand;
  DateTime? _shipByDate;
  var _paymentMethod = _paymentMethods.first;
  var _paymentStatus = PaymentStatus.paid;
  final _notes = TextEditingController();
  final List<_DraftLine> _lines = [];

  @override
  void dispose() {
    for (final c in [_customerName, _customerContact, _notes]) {
      c.dispose();
    }
    for (final line in _lines) {
      line.dispose();
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

  @override
  Widget build(BuildContext context) {
    // só os canais manuais: a Etsy entra sozinha
    final channels = (ref.watch(salesChannelsProvider).value ?? <SalesChannel>[])
        .where((c) => !c.isAutomatic)
        .toList();
    final channel = channels.where((c) => c.id == _channelId).firstOrNull ?? channels.firstOrNull;
    final products = ref.watch(productsProvider).value ?? <Product>[];
    final variants = ref.watch(allVariantsProvider).value ?? <Variant>[];

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

    final summary = _summaryCard(channel);

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

  /// O resumo à direita. As contas e o botão a sério vêm no passo 7c.
  Widget _summaryCard(SalesChannel? channel) {
    final name = _customerName.text.trim();
    Widget line(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
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
            line("Para quem", name.isEmpty ? "—" : name),
            const SizedBox(height: 16),
            const FilledButton(onPressed: null, child: Text("Criar encomenda")),
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