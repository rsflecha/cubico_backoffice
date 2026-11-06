import 'package:cubico_backoffice/features/orders/domain/order.dart';

abstract interface class OrderRepository {
  Future<List<Order>> fetchAll();

  /// Grava as alterações de uma encomenda (estado, notas…).
  Future<Order> update(Order order);

  /// Cria uma encomenda a partir de um rascunho. O id, o número
  /// e os ids das linhas são dados por quem grava (como faria a base de dados).
  Future<Order> create(Order draft);
}
