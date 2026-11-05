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
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // canal · referência · data
          Text(
            [
              channel?.name ?? "—",
              if (order.externalRef != null) "ref. ${order.externalRef}",
              shortDate(order.createdAt),
            ].join(" · "),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          _itemsCard(context, order, variants),
          const SizedBox(height: 16),
          _moneyCard(context, order, channel?.name ?? "canal"),
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
}