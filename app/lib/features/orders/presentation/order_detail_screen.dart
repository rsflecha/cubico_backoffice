import 'package:cubico_backoffice/app/theme.dart';
import 'package:cubico_backoffice/features/costs/presentation/costs_providers.dart';
import 'package:cubico_backoffice/features/orders/domain/order.dart';
import 'package:cubico_backoffice/features/orders/presentation/order_labels.dart';
import 'package:cubico_backoffice/features/orders/presentation/orders_providers.dart';
import 'package:cubico_backoffice/features/orders/presentation/widgets/status_badge.dart';
import 'package:cubico_backoffice/features/products/domain/variant.dart';
import 'package:cubico_backoffice/features/products/presentation/products_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider).value ?? [];
    final order = orders.where((o) => o.id == orderId).firstOrNull;

    if (order == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text("Encomenda não encontrada.")),
      );
    }

    final channels = ref.watch(salesChannelsProvider).value ?? [];
    final channel = channels.where((c) => c.id == order.channelId).firstOrNull;
    final variants = ref.watch(allVariantsProvider).value ?? <Variant>[];

    final isWide = MediaQuery.sizeOf(context).width >= 1100;

// coluna da esquerda: o que se vendeu e as contas
    final leftCards = <Widget>[
      _itemsCard(context, order, variants),
      const SizedBox(height: 16),
      _moneyCard(context, order, channel?.name ?? "canal"),
    ];

// coluna da direita: quem, como chega, como pagou
    final rightCards = <Widget>[
      _customerCard(context, order),
      const SizedBox(height: 16),
      _shippingCard(context, order),
      const SizedBox(height: 16),
      _paymentCard(context, order),
    ];

// a linha do topo: canal · referência · data
    final subtitle = Text(
      [
        channel?.name ?? "—",
        if (order.externalRef != null) "ref. ${order.externalRef}",
        shortDate(order.createdAt),
      ].join(" · "),
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              "#${order.orderNumber}",
              style: AppTextStyles.mono.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 12),
            StatusBadge(order.status),
          ],
        ),
        actions: [
          if (order.nextStatus != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton(
                onPressed: () async {
                  final next = order.nextStatus!;
                  await ref.read(orderRepositoryProvider).update(
                    order.copyWith(status: next, updatedAt: DateTime.now()),
                  );
                  ref.invalidate(ordersProvider);
                },
                child: Text(order.nextStatus!.actionLabel),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: _statusSteps(context, order),
          ),
          Expanded(
            child: isWide
                ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [subtitle, const SizedBox(height: 16), ...leftCards],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(0, 24, 24, 24),
                    children: [const SizedBox(height: 32), ...rightCards],
                  ),
                ),
              ],
            )
            // a tua Row das duas colunas, igual
                : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                subtitle,
                const SizedBox(height: 16),
                ...leftCards,
                const SizedBox(height: 16),
                ...rightCards,
              ],
            ),  // o teu ListView do telemóvel, igual
          ),
        ],
      ),
    );
  }

  /// O cartão "Artigos": uma linha por artigo, com nome, SKU, quantidade e total.
  Widget _itemsCard(BuildContext context, Order order, List<Variant> variants) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Artigos", style: Theme.of(context).textTheme.titleMedium),
            for (final line in order.lines) ...[
              const Divider(height: 24),
              Builder(builder: (context) {
                final variant =
                    variants.where((v) => v.id == line.variantId).firstOrNull;
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            variant?.name ?? "Variante ${line.variantId}",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "SKU ${variant?.sku ?? "—"}",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (line.customization != null)
                            Text(
                              "Personalização: «${line.customization}»",
                              style: TextStyle(color: AppColors.orange),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      "${line.quantity} × ${line.unitPrice.toStringAsFixed(2)} €",
                      style: AppTextStyles.mono,
                    ),
                    const SizedBox(width: 24),
                    Text(
                      "${(line.quantity * line.unitPrice - line.discount).toStringAsFixed(2)} €",
                      style: AppTextStyles.mono.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  /// O cartão com o recebido (à esquerda) e os custos com o lucro (à direita).
  Widget _moneyCard(BuildContext context, Order order, String channelName) {
    final marginPct = order.total > 0 ? order.profit / order.total * 100 : 0;
    final title = Theme.of(context).textTheme.titleMedium;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Recebido", style: title),
                  const SizedBox(height: 8),
                  _moneyRow("Artigos", order.itemsTotal),
                  _moneyRow("Portes cobrados", order.shippingCharged),
                  const Divider(),
                  _moneyRow("Total", order.total, bold: true),
                ],
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Custos", style: title),
                  const SizedBox(height: 8),
                  _moneyRow("Produção", order.productionCost),
                  _moneyRow("Taxas $channelName", order.channelFees),
                  _moneyRow("Portes pagos", order.shippingPaid),
                  const Divider(),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Lucro",
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        "${order.profit.toStringAsFixed(2)} € · ${marginPct.toStringAsFixed(0)}%",
                        style: AppTextStyles.mono.copyWith(
                          fontWeight: FontWeight.w700,
                          color: profitColor(order),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Uma linha de dinheiro: nome à esquerda, valor em € à direita.
  Widget _moneyRow(String label, double value, {bool bold = false}) {
    final weight = bold ? FontWeight.w700 : FontWeight.normal;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(fontWeight: weight))),
          Text(
            "${value.toStringAsFixed(2)} €",
            style: AppTextStyles.mono.copyWith(fontWeight: weight),
          ),
        ],
      ),
    );
  }

  /// Uma linha de informação: nome à esquerda, valor à direita.
  Widget _infoRow(String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          value,
        ],
      ),
    );
  }

  /// As iniciais do nome: "Ana Martins" → "AM".
  String _initials(String name) {
    final parts = name.trim().split(" ").where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return "?";
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  /// Cartão "Cliente": iniciais, nome e contacto.
  Widget _customerCard(BuildContext context, Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Cliente", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.orange.withValues(alpha: 0.12),
                  child: Text(
                    _initials(order.customerName),
                    style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.customerName,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      if (order.customerContact != null) Text(order.customerContact!),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Cartão "Envio": forma de entrega, transportadora, prazo e seguimento.
  Widget _shippingCard(BuildContext context, Order order) {
    final deadline = order.shipByDate;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Envio", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _infoRow("Entrega", Text(order.deliveryMethod.label)),
            if (order.carrierName != null)
              _infoRow("Transportadora", Text(order.carrierName!)),
            if (deadline != null)
              _infoRow(
                "Prazo de envio",
                Text(
                  order.isOverdue
                      ? "${shortDate(deadline)} · atrasada"
                      : shortDate(deadline),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: order.isOverdue ? const Color(0xFFB91C1C) : null,
                  ),
                ),
              ),
            if (order.trackingCode != null)
              _infoRow(
                "Seguimento",
                Text(order.trackingCode!, style: AppTextStyles.mono),
              ),
          ],
        ),
      ),
    );
  }

  /// Cartão "Pagamento": método e estado.
  Widget _paymentCard(BuildContext context, Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Pagamento", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _infoRow("Método", Text(order.paymentMethod ?? "—")),
            _infoRow(
              "Estado",
              Text(
                order.paymentStatus.label,
                style: TextStyle(
                  color: order.paymentStatus.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// A barra com os 5 passos do fluxo, com o atual destacado.
  Widget _statusSteps(BuildContext context, Order order) {
    const flow = [
      OrderStatus.pending,
      OrderStatus.inProduction,
      OrderStatus.ready,
      OrderStatus.shipped,
      OrderStatus.delivered,
    ];

    // uma cancelada não está no fluxo: mostra só um aviso
    if (order.status == OrderStatus.cancelled) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            "Esta encomenda foi cancelada.",
            style: TextStyle(color: order.status.color, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    final current = flow.indexOf(order.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            for (var i = 0; i < flow.length; i++) ...[
              if (i > 0) const Expanded(child: Divider(indent: 8, endIndent: 8)),
              CircleAvatar(
                radius: 13,
                backgroundColor:
                i <= current ? AppColors.orange : Colors.grey.withValues(alpha: 0.2),
                child: i < current
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : Text(
                  "${i + 1}",
                  style: TextStyle(
                    fontSize: 12,
                    color: i <= current ? Colors.white : null,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                flow[i].label,
                style: TextStyle(
                  fontWeight: i == current ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}