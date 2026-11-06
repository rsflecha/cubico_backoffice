import 'package:cubico_backoffice/app/theme.dart';
import 'package:cubico_backoffice/core/formatting.dart';
import 'package:cubico_backoffice/features/orders/domain/order.dart';
import 'package:cubico_backoffice/features/orders/presentation/order_labels.dart';
import 'package:cubico_backoffice/features/orders/presentation/orders_providers.dart';
import 'package:cubico_backoffice/features/orders/presentation/widgets/status_badge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: orders.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text("Erro: $error")),
        data: (list) {
          final now = DateTime.now();
          // as encomendas deste mês
          final month = list
              .where((o) => o.createdAt.year == now.year && o.createdAt.month == now.month)
              .toList();
          final sales = month.fold(0.0, (sum, o) => sum + o.total);
          final profit = month.fold(0.0, (sum, o) => sum + o.profit);
          final pending = list.where((o) =>
          o.status == OrderStatus.pending || o.status == OrderStatus.inProduction).toList();
          final overdue = list.where((o) => o.isOverdue).toList();

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _kpi(context, "Vendas do mês", euro(sales)),
                  _kpi(context, "Lucro do mês", euro(profit),
                      color: profit >= 0 ? const Color(0xFF15803D) : const Color(0xFFB91C1C)),
                  _kpi(context, "Encomendas do mês", "${month.length}"),
                  _kpi(context, "Por fazer", "${pending.length}"),
                  _kpi(context, "Atrasadas", "${overdue.length}",
                      color: overdue.isEmpty ? null : const Color(0xFFB91C1C)),
                ],
              ),
              const SizedBox(height: 24),
              Text("Precisam de atenção", style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (pending.isEmpty)
                const Text("Nada por fazer. 🎉")
              else
                Card(
                  child: Column(
                    children: [
                      // as atrasadas primeiro, depois pelo prazo
                      for (final o in [...pending]..sort(_byUrgency))
                        ListTile(
                          leading: Text(
                            "#${o.orderNumber}",
                            style: AppTextStyles.mono.copyWith(
                                color: AppColors.orange, fontWeight: FontWeight.w700),
                          ),
                          title: Text(o.customerName),
                          subtitle: Text(o.shipByDate == null
                              ? "Sem prazo"
                              : o.isOverdue
                              ? "Prazo ${shortDate(o.shipByDate!)} · atrasada"
                              : "Prazo ${shortDate(o.shipByDate!)}"),
                          trailing: StatusBadge(o.status),
                          onTap: () => context.push("/orders/${o.id}"),
                        ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Ordena: atrasadas primeiro; depois o prazo mais próximo; sem prazo no fim.
  static int _byUrgency(Order a, Order b) {
    if (a.isOverdue != b.isOverdue) return a.isOverdue ? -1 : 1;
    final da = a.shipByDate, db = b.shipByDate;
    if (da == null && db == null) return 0;
    if (da == null) return 1;
    if (db == null) return -1;
    return da.compareTo(db);
  }

  /// Um cartão com um número grande.
  Widget _kpi(BuildContext context, String label, String value, {Color? color}) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 6),
              Text(value,
                  style: AppTextStyles.mono
                      .copyWith(fontSize: 24, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}