import 'package:cubico_backoffice/core/api/api_table.dart';
import 'package:cubico_backoffice/features/customers/domain/customer.dart';
import 'package:cubico_backoffice/features/customers/domain/customer_repository.dart';
import 'package:dio/dio.dart';

/// Os clientes, vindos da API, cada um com as suas moradas.
class ApiCustomerRepository implements CustomerRepository {
  ApiCustomerRepository(Dio dio) : _table = ApiTable(dio, "/customers", Customer.fromJson);

  final ApiTable<Customer> _table;

  @override
  Future<List<Customer>> fetchAll() => _table.fetchAll();

  @override
  Future<Customer> create(Customer draft) => _table.create(draft.toJson());

  @override
  Future<Customer> update(Customer customer) => _table.update(customer.id, customer.toJson());
}
