import 'package:cubico_backoffice/core/api/api_exception.dart';
import 'package:cubico_backoffice/core/api/api_table.dart';
import 'package:cubico_backoffice/features/orders/domain/order.dart';
import 'package:cubico_backoffice/features/orders/domain/order_event.dart';
import 'package:cubico_backoffice/features/orders/domain/order_repository.dart';
import 'package:dio/dio.dart';

/// As encomendas, vindas da API.
/// Ao criar, a API refaz as contas (custo, taxas, portes) e é o valor dela que fica gravado.
class ApiOrderRepository implements OrderRepository {
  ApiOrderRepository(this._dio) : _table = ApiTable(_dio, "/orders", Order.fromJson);

  final Dio _dio;
  final ApiTable<Order> _table;

  @override
  Future<List<Order>> fetchAll() => _table.fetchAll();

  @override
  Future<Order> create(Order draft) => _table.create(draft.toJson());

  @override
  Future<Order> update(Order order) => _table.update(order.id, order.toJson());

  @override
  Future<List<OrderEvent>> fetchEvents(int orderId) => apiCall(() async {
        final response = await _dio.get<List<dynamic>>("/orders/$orderId/events");
        return response.data!.map((e) => OrderEvent.fromJson(e as Map<String, dynamic>)).toList();
      });
}
