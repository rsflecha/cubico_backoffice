import 'product.dart';

abstract interface class ProductRepository {
  Future<List<Product>> fetchAll();

  Future<Product> create({
    required String name,
    required String baseSku,
    required int categoryId,
  });

  Future<Product> update(Product product);
}