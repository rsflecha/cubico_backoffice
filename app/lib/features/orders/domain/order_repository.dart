import 'package:cubico_backoffice/features/orders/domain/order.dart';

abstract interface class OrderRepository {
  Future<List<Order>> fetchAll();
}