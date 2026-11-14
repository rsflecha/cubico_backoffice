import 'package:cubico_backoffice/core/formatting.dart';
import 'package:cubico_backoffice/app/theme.dart';
import 'package:cubico_backoffice/features/costs/presentation/costs_providers.dart';
import 'package:cubico_backoffice/features/orders/domain/order.dart';
import 'package:cubico_backoffice/features/orders/presentation/order_labels.dart';
import 'package:cubico_backoffice/features/orders/presentation/orders_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final canSeeCosts = ref.watch(sessionProvider)?.canSeeCosts ?? false;
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

    // no telemóvel: tabela → cartões, estados numa fila que desliza, botão "+" redondo
    final isPhone = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Encomendas"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: isPhone
                ? IconButton.filled(
                    tooltip: "Criar encomenda",
                    onPressed: () => context.push("/orders/new"),
                    // a cor vai no próprio ícone: a AppBar pinta os ícones das
                    // actions de escuro, e ficava escuro sobre o fundo escuro
                    icon: Icon(
                      Icons.add,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  )
                : FilledButton.icon(
                    onPressed: () => context.push("/orders/new"),
                    icon: const Icon(Icons.add),
                    label: const Text("Criar encomenda"),
                  ),
          ),
        ],
      ),
      body: orders.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text("Erro: $error")),
        data: (list) {
          // só as do estado escolhido (ou todas)
          final visible = list.where(matches).toList();

          final chips = [
            ChoiceChip(
              label: Text("Todas · ${list.length}"),
              selected: selected == null,
              onSelected: (_) =>
                  ref.read(selectedOrderStatusProvider.notifier).select(null),
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
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // os separadores: no telemóvel, numa só fila que desliza para o lado
              // (em Wrap ocupavam 4 linhas e empurravam a lista para fora do ecrã)
              if (isPhone)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      for (final chip in chips) ...[
                        chip,
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Wrap(spacing: 8, runSpacing: 8, children: chips),
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
                    : isPhone
                    ? ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: visible.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, i) => _OrderCard(
                          order: visible[i],
                          channelName: channelName(visible[i].channelId),
                          canSeeCosts: canSeeCosts,
                          deadline: _deadline(visible[i]),
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
                                columns: [
                                  const DataColumn(label: Text("Nº")),
                                  const DataColumn(label: Text("Data")),
                                  const DataColumn(label: Text("Cliente")),
                                  const DataColumn(label: Text("Canal")),
                                  const DataColumn(
                                    label: Text("Artigos"),
                                    numeric: true,
                                  ),
                                  const DataColumn(label: Text("Estado")),
                                  const DataColumn(label: Text("Pagamento")),
                                  const DataColumn(label: Text("Prazo")),
                                  const DataColumn(
                                    label: Text("Total"),
                                    numeric: true,
                                  ),
                                  if (canSeeCosts)
                                    const DataColumn(
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
                                            euro(o.total),
                                            style: AppTextStyles.mono.copyWith(
                                              color:
                                                  o.status ==
                                                      OrderStatus.cancelled
                                                  ? const Color(0xFF71717A)
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        if (canSeeCosts)
                                          DataCell(
                                            Text(
                                              euro(o.profit),
                                              style: AppTextStyles.mono
                                                  .copyWith(
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

/// Uma encomenda em cartão (telemóvel): o mesmo que uma linha da tabela, em 3 linhas.
///   #1042  Ana Martins                 40,00 €
///   13 nov · Etsy · 2 artigos     lucro 25,40 €
///   [Pendente]  Pago                 Prazo 17 nov
class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.channelName,
    required this.canSeeCosts,
    required this.deadline,
  });

  final Order order;
  final String channelName;
  final bool canSeeCosts;
  final Widget deadline;

  @override
  Widget build(BuildContext context) {
    final o = order;
    final small = Theme.of(context).textTheme.bodySmall;
    final cancelled = o.status == OrderStatus.cancelled;

    return Card(
      margin: EdgeInsets.zero,
      // as atrasadas ficam com o fundo avermelhado, como na tabela
      color: o.isOverdue
          ? Color.alphaBlend(
              Colors.red.withValues(alpha: 0.06),
              Theme.of(context).cardColor,
            )
          : null,
      clipBehavior:
          Clip.antiAlias, // o efeito do toque fica dentro dos cantos redondos
      child: InkWell(
        onTap: () => context.push("/orders/${o.id}"),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "#${o.orderNumber}",
                    style: AppTextStyles.mono.copyWith(
                      color: AppColors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      o.customerName,
                      overflow: TextOverflow
                          .ellipsis, // nomes compridos acabam em "…"
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    euro(o.total),
                    style: AppTextStyles.mono.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cancelled ? const Color(0xFF71717A) : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "${shortDate(o.createdAt)} · $channelName · "
                      "${o.itemCount} ${o.itemCount == 1 ? "artigo" : "artigos"}",
                      style: small,
                    ),
                  ),
                  if (canSeeCosts)
                    Text(
                      "lucro ${euro(o.profit)}",
                      style: AppTextStyles.mono.copyWith(
                        fontSize: 12,
                        color: profitColor(o),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _StatusBadge(o.status),
                  const SizedBox(width: 8),
                  Text(
                    o.paymentStatus.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: o.paymentStatus.color,
                    ),
                  ),
                  const Spacer(),
                  if (o.shipByDate != null)
                    DefaultTextStyle.merge(
                      style: const TextStyle(fontSize: 12),
                      child: Row(children: [const Text("Prazo "), deadline]),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
