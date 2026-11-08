import 'package:cubico_backoffice/app/theme.dart';
import 'package:cubico_backoffice/core/formatting.dart';
import 'package:cubico_backoffice/features/customers/domain/customer.dart';
import 'package:cubico_backoffice/features/customers/presentation/customers_providers.dart';
import 'package:cubico_backoffice/features/orders/domain/order.dart';
import 'package:cubico_backoffice/features/orders/presentation/order_labels.dart';
import 'package:cubico_backoffice/features/orders/presentation/orders_providers.dart';
import 'package:cubico_backoffice/features/orders/presentation/widgets/status_badge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class CustomerDetailScreen extends ConsumerWidget {
  const CustomerDetailScreen({super.key, required this.customerId});

  final int customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(customersProvider).value ?? <Customer>[];
    final customer = customers.where((c) => c.id == customerId).firstOrNull;

    if (customer == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text("Cliente não encontrado.")),
      );
    }

    // as encomendas deste cliente, das mais recentes para as mais antigas
    final orders = (ref.watch(ordersProvider).value ?? <Order>[])
        .where((o) => o.customerId == customer.id)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final spent = orders.fold(0.0, (sum, o) => sum + o.total);

    final isWide = MediaQuery.sizeOf(context).width >= 1100;

    final left = <Widget>[
      _numbers(context, customer, orders.length, spent),
      const SizedBox(height: 16),
      _history(context, orders),
    ];
    final right = <Widget>[
      _contacts(context, customer),
      const SizedBox(height: 16),
      _addresses(context, customer),
      if (customer.notes != null) ...[
        const SizedBox(height: 16),
        _card(context, "Notas", [Text(customer.notes!)]),
      ],
    ];

    return Scaffold(
      appBar: AppBar(title: Text(customer.name)),
      body: isWide
          ? Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: ListView(padding: const EdgeInsets.all(24), children: left),
          ),
          Expanded(
            flex: 2,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(0, 24, 24, 24),
              children: right,
            ),
          ),
        ],
      )
          : ListView(
        padding: const EdgeInsets.all(24),
        children: [...left, const SizedBox(height: 16), ...right],
      ),
    );
  }

  /// Um cartão com título.
  Widget _card(BuildContext context, String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  /// Os três números do cliente.
  Widget _numbers(BuildContext context, Customer c, int count, double spent) {
    Widget number(String label, String value) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.mono.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            number("Total gasto", euro(spent)),
            number("Encomendas", "$count"),
            number("Cliente desde", shortDate(c.createdAt)),
          ],
        ),
      ),
    );
  }

  /// O histórico das encomendas.
  Widget _history(BuildContext context, List<Order> orders) {
    return _card(context, "Histórico", [
      if (orders.isEmpty)
        const Text("Ainda não há encomendas deste cliente.")
      else
        for (final o in orders)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Text(
              "#${o.orderNumber}",
              style: AppTextStyles.mono.copyWith(
                color: AppColors.orange,
                fontWeight: FontWeight.w700,
              ),
            ),
            title: Text("${shortDate(o.createdAt)} · ${o.itemCount} artigo(s)"),
            subtitle: Align(alignment: Alignment.centerLeft, child: StatusBadge(o.status)),
            trailing: Text(euro(o.total), style: AppTextStyles.mono),
            onTap: () => context.push("/orders/${o.id}"),
          ),
    ]);
  }

  /// Os contactos: só os que existem.
  Widget _contacts(BuildContext context, Customer c) {
    Widget line(IconData icon, String text) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF71717A)),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );

    final hasAny = c.email != null || c.phone != null || c.instagram != null;
    return _card(context, "Contactos", [
      if (!hasAny) const Text("Sem contactos."),
      if (c.email != null) line(Icons.mail_outline, c.email!),
      if (c.phone != null) line(Icons.phone_outlined, c.phone!),
      if (c.instagram != null) line(Icons.alternate_email, c.instagram!),
    ]);
  }

  /// As moradas.
  Widget _addresses(BuildContext context, Customer c) {
    return _card(context, "Moradas", [
      if (c.addresses.isEmpty)
        const Text("Sem moradas.")
      else
        for (final a in c.addresses)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.place_outlined, size: 18, color: Color(0xFF71717A)),
                const SizedBox(width: 12),
                Expanded(child: Text(a.oneLine)),
              ],
            ),
          ),
    ]);
  }
}