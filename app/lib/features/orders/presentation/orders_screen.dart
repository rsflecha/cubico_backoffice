import 'package:cubico_backoffice/app/theme.dart';
import 'package:cubico_backoffice/features/costs/presentation/costs_providers.dart';
import 'package:cubico_backoffice/features/orders/domain/order.dart';
import 'package:cubico_backoffice/features/orders/presentation/order_labels.dart';
import 'package:cubico_backoffice/features/orders/presentation/orders_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final channels = ref.watch(salesChannelsProvider).value ?? [];
    final selected = ref.watch(selectedOrderStatusProvider);
    final search = ref.watch(orderSearchProvider);
    final channelFilter = ref.watch(orderChannelFilterProvider);

    // o nome do canal a partir do id: 1 → "Etsy"
    String channelName(int id) =>
        channels.where((c) => c.id == id).firstOrNull?.name ?? "—";

    // passa nos três filtros: estado, canal e pesquisa
    bool matches(Order o) {
      if (selected != null && o.status != selected) return false;
      if (channelFilter != null && o.channelId != channelFilter) return false;

      final text = search.trim().toLowerCase();
      if (text.isEmpty) return true;
      return "${o.orderNumber}".contains(text) ||
          o.customerName.toLowerCase().contains(text) ||
          (o.externalRef ?? "").contains(text);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Encomendas")),
      body: orders.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text("Erro: $error")),
        data: (list) {
          // só as do estado escolhido (ou todas)
          final visible = list.where(matches).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // os separadores
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text("Todas · ${list.length}"),
                      selected: selected == null,
                      onSelected: (_) => ref
                          .read(selectedOrderStatusProvider.notifier)
                          .select(null),
                    ),
                    for (final status in OrderStatus.values)
                      ChoiceChip(
                        label: Text(
                          "${status.pluralLabel} · "
                          "${list.where((o) => o.status == status).length}",
                        ),
                        selected: selected == status,
                        onSelected: (_) => ref
                            .read(selectedOrderStatusProvider.notifier)
                            .select(status),
                      ),
                  ],
                ),
              ),

              // pesquisa e filtro por canal
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: search,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: "Nº, cliente ou referência Etsy",
                        ),
                        onChanged: (text) =>
                            ref.read(orderSearchProvider.notifier).set(text),
                      ),
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<int?>(
                      value: channelFilter,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text("Canal: todos"),
                        ),
                        for (final c in channels)
                          DropdownMenuItem(value: c.id, child: Text(c.name)),
                      ],
                      onChanged: (id) => ref
                          .read(orderChannelFilterProvider.notifier)
                          .select(id),
                    ),
                  ],
                ),
              ),

              // a tabela, ou uma mensagem se não houver nenhuma
              Expanded(
                child: visible.isEmpty
                    ? const Center(
                        child: Text(
                          "Nenhuma encomenda corresponde aos filtros.",
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) => SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: constraints.maxWidth - 32,
                              ),
                              child: DataTable(
                                showCheckboxColumn: false,
                                columnSpacing: 24,
                                horizontalMargin: 12,
                                columns: const [
                                  DataColumn(label: Text("Nº")),
                                  DataColumn(label: Text("Data")),
                                  DataColumn(label: Text("Cliente")),
                                  DataColumn(label: Text("Canal")),
                                  DataColumn(
                                    label: Text("Artigos"),
                                    numeric: true,
                                  ),
                                  DataColumn(label: Text("Estado")),
                                  DataColumn(label: Text("Pagamento")),
                                  DataColumn(label: Text("Prazo")),
                                  DataColumn(
                                    label: Text("Total"),
                                    numeric: true,
                                  ),
                                  DataColumn(
                                    label: Text("Lucro"),
                                    numeric: true,
                                  ),
                                ],
                                rows: [
                                  for (final o in visible)
                                    DataRow(
                                      onSelectChanged: (_) =>
                                          context.push("/orders/${o.id}"),
                                      // as atrasadas ficam com o fundo avermelhado
                                      color: o.isOverdue
                                          ? WidgetStatePropertyAll(
                                              Colors.red.withValues(
                                                alpha: 0.06,
                                              ),
                                            )
                                          : null,
                                      cells: [
                                        DataCell(
                                          Text(
                                            "#${o.orderNumber}",
                                            style: AppTextStyles.mono.copyWith(
                                              color: AppColors.orange,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        DataCell(Text(shortDate(o.createdAt))),
                                        DataCell(Text(o.customerName)),
                                        DataCell(
                                          Text(channelName(o.channelId)),
                                        ),
                                        DataCell(Text("${o.itemCount}")),
                                        DataCell(_StatusBadge(o.status)),
                                        DataCell(
                                          Text(
                                            o.paymentStatus.label,
                                            style: TextStyle(
                                              color: o.paymentStatus.color,
                                            ),
                                          ),
                                        ),
                                        DataCell(_deadline(o)),
                                        DataCell(
                                          Text(
                                            "${o.total.toStringAsFixed(2)} €",
                                            style: AppTextStyles.mono.copyWith(
                                              color:
                                                  o.status ==
                                                      OrderStatus.cancelled
                                                  ? const Color(0xFF71717A)
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            "${o.profit.toStringAsFixed(2)} €",
                                            style: AppTextStyles.mono.copyWith(
                                              color: profitColor(o),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// O que aparece na coluna "Prazo".
  Widget _deadline(Order o) {
    final deadline = o.shipByDate;
    if (deadline == null) return const Text("—");
    if (o.isOverdue) {
      return Text(
        "${shortDate(deadline)} · atrasada",
        style: const TextStyle(
          color: Color(0xFFB91C1C),
          fontWeight: FontWeight.w600,
        ),
      );
    }
    return Text(shortDate(deadline));
  }
}

/// A etiqueta colorida do estado: texto da cor do estado, fundo da mesma cor bem clara.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge(this.status);

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
