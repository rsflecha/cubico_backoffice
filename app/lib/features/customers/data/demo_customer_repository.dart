import 'package:cubico_backoffice/features/customers/domain/customer.dart';
import 'package:cubico_backoffice/features/customers/domain/customer_repository.dart';

class DemoCustomerRepository implements CustomerRepository {
  static DateTime _days(int n) => DateTime.now().add(Duration(days: n));

  final List<Customer> _items = [
    Customer(
      id: 1,
      name: "Ana Martins",
      email: "ana.martins@exemplo.pt",
      phone: "912 000 001",
      notes: "Prefere embalagem sem plástico.",
      createdAt: _days(-60),
      addresses: const [
        Address(id: 1, line1: "Rua das Flores 12, 2.º Esq.", postalCode: "4700-000", city: "Braga"),
      ],
    ),
    Customer(
      id: 2,
      name: "João Pereira",
      instagram: "joao.p",
      createdAt: _days(-30),
    ),
    Customer(
      id: 3,
      name: "Pedro Sousa",
      phone: "912 000 003",
      notes: "Vizinho; entrega em mão.",
      createdAt: _days(-20),
    ),
  ];

  Future<void> _latency() => Future.delayed(const Duration(milliseconds: 300));

  @override
  Future<List<Customer>> fetchAll() async {
    await _latency();
    final copy = List<Customer>.of(_items);
    copy.sort((a, b) => a.name.compareTo(b.name)); // por ordem alfabética
    return copy;
  }
}