import 'product_category.dart';

abstract interface class ProductCategoryRepository {
  Future<List<ProductCategory>> fetchAll();

  /// Cria uma categoria. Sem [code], o código nasce das 3 letras do nome (SUP).
  Future<ProductCategory> create({
    required String name,
    String? code,
    String color = "#A1A1AA",
    int sortOrder = 0,
  });
  Future<ProductCategory> update(ProductCategory category);
  Future<void> delete(int id);
}
