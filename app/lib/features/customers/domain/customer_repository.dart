import 'package:cubico_backoffice/features/customers/domain/customer.dart';

abstract interface class CustomerRepository {
  Future<List<Customer>> fetchAll();
}