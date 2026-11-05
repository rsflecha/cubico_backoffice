import 'package:cubico_backoffice/features/orders/data/demo_order_repository.dart';
import 'package:cubico_backoffice/features/orders/domain/order.dart';
import 'package:cubico_backoffice/features/orders/domain/order_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Placa 1: qual é o repositório das encomendas.
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return DemoOrderRepository();
});

/// Placa 2: a lista de encomendas.
final ordersProvider = FutureProvider<List<Order>>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.fetchAll();
});

/// Guarda o estado escolhido nos separadores. null = "Todas".
class SelectedOrderStatusNotifier extends Notifier<OrderStatus?> {
  @override
  OrderStatus? build() => null;

  void select(OrderStatus? status) {
    state = status;
  }
}

/// Placa 3: o estado escolhido nos separadores.
final selectedOrderStatusProvider =
NotifierProvider<SelectedOrderStatusNotifier, OrderStatus?>(
    SelectedOrderStatusNotifier.new);

/// Guarda o texto da pesquisa. "" = sem pesquisa.
class OrderSearchNotifier extends Notifier<String> {
  @override
  String build() => "";

  void set(String text) {
    state = text;
  }
}

/// Placa 4: o texto da pesquisa.
final orderSearchProvider =
NotifierProvider<OrderSearchNotifier, String>(OrderSearchNotifier.new);

/// Guarda o canal escolhido no filtro. null = todos.
class OrderChannelFilterNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void select(int? channelId) {
    state = channelId;
  }
}

/// Placa 5: o canal escolhido no filtro.
final orderChannelFilterProvider =
NotifierProvider<OrderChannelFilterNotifier, int?>(
    OrderChannelFilterNotifier.new);