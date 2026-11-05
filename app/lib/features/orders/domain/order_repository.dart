import 'package:cubico_backoffice/features/orders/domain/order.dart';

abstract interface class OrderRepository {
  Future<List<Order>> fetchAll();

  /// Grava as alterações de uma encomenda (estado, notas…).
  Future<Order> update(Order order);
}