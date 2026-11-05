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