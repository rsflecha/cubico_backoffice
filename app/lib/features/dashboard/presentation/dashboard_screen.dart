import 'package:cubico_backoffice/app/theme.dart';
import 'package:cubico_backoffice/core/formatting.dart';
import 'package:cubico_backoffice/features/orders/domain/order.dart';
import 'package:cubico_backoffice/features/orders/presentation/order_labels.dart';
import 'package:cubico_backoffice/features/orders/presentation/orders_providers.dart';
import 'package:cubico_backoffice/features/orders/presentation/widgets/status_badge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final canSeeCosts = ref.watch(sessionProvider)?.canSeeCosts ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            tooltip: "A minha conta",
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => _showAccount(context, ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
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
                if (canSeeCosts) ...[
                  _kpi(context, "Vendas do mês", euro(sales)),
                  _kpi(
                    context,
                    "Lucro do mês",
                    euro(profit),
                    color: profit >= 0 ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                  ),
                  _kpi(context, "Encomendas do mês", "${month.length}"),
                ],
                _kpi(context, "Por fazer", "${pending.length}"),
                _kpi(
                  context,
                  "Atrasadas",
                  "${overdue.length}",
                  color: overdue.isEmpty ? null : const Color(0xFFB91C1C),
                  ),
                ],
              ),
              if (canSeeCosts)
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Vendas e lucro · últimos 14 dias",
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 16),
                      SizedBox(height: 240, child: _chart(list)),
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          _Legend(color: AppColors.orange, label: "Vendas"),
                          SizedBox(width: 16),
                          _Legend(color: Color(0xFF15803D), label: "Lucro"),
                        ],
                      ),
                    ],
                  ),
                ),
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

  /// Uma folha que sobe do fundo, com quem está a usar a app e o botão de sair.
  void _showAccount(BuildContext context, WidgetRef ref) {
    final user = ref.read(sessionProvider);
    if (user == null) return;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(child: Text(user.name[0])),
                title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(
                  "${user.email} · ${user.isAdmin ? "Administrador" : "Colaborador"}",
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // fecha a folha
                  ref.read(sessionProvider.notifier).signOut();
                },
                icon: const Icon(Icons.logout),
                label: const Text("Terminar sessão"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// O gráfico: um ponto por dia, das vendas e do lucro.
  Widget _chart(List<Order> orders) {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 13));

    final sales = <FlSpot>[];
    final profit = <FlSpot>[];
    for (var i = 0; i < 14; i++) {
      final day = start.add(Duration(days: i));
      final ofDay = orders.where((o) =>
      o.createdAt.year == day.year &&
          o.createdAt.month == day.month &&
          o.createdAt.day == day.day);
      sales.add(FlSpot(i.toDouble(), ofDay.fold(0.0, (s, o) => s + o.total)));
      profit.add(FlSpot(i.toDouble(), ofDay.fold(0.0, (s, o) => s + o.profit)));
    }

    LineChartBarData line(List<FlSpot> spots, Color color) => LineChartBarData(
      spots: spots,
      color: color,
      barWidth: 3,
      isCurved: true,
      preventCurveOverShooting: true,
      dotData: const FlDotData(show: false),
    );

    return LineChart(
      LineChartData(
        minY: 0,
        lineBarsData: [
          line(sales, AppColors.orange),
          line(profit, const Color(0xFF15803D)),
        ],
        gridData: const FlGridData(drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        // a caixinha que aparece ao passar por cima: valores em euros, com 2 casas
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.black,
            getTooltipItems: (spots) => [
              for (final s in spots)
                LineTooltipItem(
                  "${s.barIndex == 0 ? "Vendas" : "Lucro"}: ${euro(s.y)}",
                  TextStyle(
                    color: s.barIndex == 0 ? AppColors.orange : const Color(0xFF4ADE80),
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (value, meta) =>
                  Text("${value.toInt()} €", style: const TextStyle(fontSize: 11)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2, // um dia sim, um dia não, para os textos não se atropelarem
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  shortDate(start.add(Duration(days: value.toInt()))),
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Um quadradinho de cor com o nome da linha.
class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}