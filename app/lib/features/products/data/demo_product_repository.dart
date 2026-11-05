import 'package:cubico_backoffice/features/products/domain/product.dart';
import 'package:cubico_backoffice/features/products/domain/product_repository.dart';

class DemoProductRepository implements ProductRepository {
  int _nextId = 4;
  final List<Product> _items = [
    Product(
      id: 1,
      name: "Suporte de auscultadores",
      baseSku: "CD3-SDA-01",
      categoryId: 1,
      status: ProductStatus.active,
      createdAt: DateTime(2026, 10, 1),
      updatedAt: DateTime(2026, 10, 1),
    ),
    Product(
      id: 2,
      name: "Árvore de Natal",
      baseSku: "CD3-ADN-01",
      categoryId: 2,
      status: ProductStatus.active,
      createdAt: DateTime(2026, 09, 15),
      updatedAt: DateTime(2026, 09, 15),
    ),
    Product(
      id: 3,
      name: "Bolas de Natal",
      baseSku: "CD3-BDN-01",
      categoryId: 2,
      status: ProductStatus.active,
      createdAt: DateTime(2026, 09, 25),
      updatedAt: DateTime(2026, 09, 25),
    ),
  ];

  Future<void> _latency() => Future.delayed(const Duration(milliseconds: 300));

  @override
  Future<List<Product>> fetchAll() async {
    await _latency();
    return List<Product>.of(_items);
  }

  @override
  Future<Product> create({
    required String name,
    required String baseSku,
    required int categoryId,
  }) async {
    await _latency();
    final now = DateTime.now();
    final created = Product(
      id: _nextId++,
      name: name,
      baseSku: baseSku,
      categoryId: categoryId,
      createdAt: now,
      updatedAt: now,
    );
    _items.add(created);
    return created;
  }

  @override
  Future<Product> update(Product product) async {
    await _latency();
    final index = _items.indexWhere((p) => p.id == product.id);
    if (index == -1) throw StateError("Produto ${product.id} não existe.");
    _items[index] = product;
    return product;
  }

  @override
  Future<void> delete(int id) async {
    await _latency();
    _items.removeWhere((p) => p.id == id);
  }
}
