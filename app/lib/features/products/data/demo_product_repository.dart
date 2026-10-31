import '../domain/product.dart';
import '../domain/product_repository.dart';

class DemoProductRepository implements ProductRepository {
  final List<Product> _items = [
    Product(
      id: 1,
      name: 'Suporte de auscultadores',
      baseSku: 'CD3-SDA-01',
      categoryId: 1,
      status: ProductStatus.active,
      createdAt: DateTime(2026, 10, 1),
      updatedAt: DateTime(2026, 10, 1),
    ),
    Product(
      id: 2,
      name: 'Árvore de Natal',
      baseSku: 'CD3-ADN-01',
      categoryId: 2,
      status: ProductStatus.active,
      createdAt: DateTime(2026, 09, 15),
      updatedAt: DateTime(2026, 09, 15),
    ),
    Product(
      id: 3,
      name: 'Bolas de Natal',
      baseSku: 'CD3-BDN-01',
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
}