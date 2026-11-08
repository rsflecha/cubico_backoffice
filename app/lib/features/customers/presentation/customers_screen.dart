import 'package:cubico_backoffice/app/theme.dart';
import 'package:cubico_backoffice/core/formatting.dart';
import 'package:cubico_backoffice/features/customers/domain/customer.dart';
import 'package:cubico_backoffice/features/customers/presentation/customers_providers.dart';
import 'package:cubico_backoffice/features/orders/domain/order.dart';
import 'package:cubico_backoffice/features/orders/presentation/orders_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  var _search = "";

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customersProvider);
    final orders = ref.watch(ordersProvider).value ?? <Order>[];

    return Scaffold(
      appBar: AppBar(title: const Text("Clientes")),
      body: customers.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text("Erro: $error")),
        data: (list) {
          final text = _search.trim().toLowerCase();
          final visible = text.isEmpty
              ? list
              : list.where((c) =>
          c.name.toLowerCase().contains(text) ||
              (c.email ?? "").toLowerCase().contains(text) ||
              (c.instagram ?? "").toLowerCase().contains(text) ||
              (c.phone ?? "").contains(text)).toList();

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: "Nome, email, telemóvel ou Instagram",
                ),
                onChanged: (value) => setState(() => _search = value),
              ),
              const SizedBox(height: 16),
              if (visible.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text("Nenhum cliente encontrado."),
                )
              else
                Card(
                  child: Column(
                    children: [
                      for (final c in visible) _tile(c, orders),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Uma linha da lista: o cliente, o contacto, e o que já comprou.
  Widget _tile(Customer c, List<Order> orders) {
    // as encomendas deste cliente (as canceladas contam 0 no total, pela regra do modelo)
    final mine = orders.where((o) => o.customerId == c.id).toList();
    final spent = mine.fold(0.0, (sum, o) => sum + o.total);
    final contact = c.email ?? c.phone ?? (c.instagram == null ? null : "@${c.instagram}");

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.orange.withValues(alpha: 0.12),
        child: Text(
          c.name.isEmpty ? "?" : c.name[0],
          style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.w700),
        ),
      ),
      title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(contact ?? "Sem contacto"),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(euro(spent), style: AppTextStyles.mono.copyWith(fontWeight: FontWeight.w700)),
          Text(
            mine.length == 1 ? "1 encomenda" : "${mine.length} encomendas",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      onTap: () {}, // a ficha vem no C2
    );
  }
}