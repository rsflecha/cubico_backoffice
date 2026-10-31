import 'product_category.dart';


abstract interface class ProductCategoryRepository {
  Future<List<ProductCategory>> fetchAll();
  Future<ProductCategory> create({
    required String name,
    String color = '#A1A1AA',
    int sortOrder = 0,
  });
  Future<ProductCategory> update(ProductCategory category);
  Future<void> delete(int id);
}