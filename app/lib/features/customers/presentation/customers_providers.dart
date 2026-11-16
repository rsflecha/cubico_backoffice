import 'package:cubico_backoffice/core/api/api_client.dart';
import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:cubico_backoffice/features/customers/data/api_customer_repository.dart';
import 'package:cubico_backoffice/features/customers/data/demo_customer_repository.dart';
import 'package:cubico_backoffice/features/customers/data/api_postal_code_repository.dart';
import 'package:cubico_backoffice/features/customers/data/demo_postal_code_repository.dart';
import 'package:cubico_backoffice/features/customers/domain/customer.dart';
import 'package:cubico_backoffice/features/customers/domain/customer_repository.dart';
import 'package:cubico_backoffice/features/customers/domain/postal_code.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Qual é o repositório dos clientes.
final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  if (ref.watch(demoModeProvider)) return DemoCustomerRepository();
  return ApiCustomerRepository(ref.watch(dioProvider));
});

/// A lista de clientes.
final customersProvider = FutureProvider<List<Customer>>((ref) {
  return ref.watch(customerRepositoryProvider).fetchAll();
});
/// Onde se procura a localidade de um código postal (a API, ou uns poucos no modo demo).
final postalCodeRepositoryProvider = Provider<PostalCodeRepository>((ref) {
  if (ref.watch(demoModeProvider)) return DemoPostalCodeRepository();
  return ApiPostalCodeRepository(ref.watch(dioProvider));
});
