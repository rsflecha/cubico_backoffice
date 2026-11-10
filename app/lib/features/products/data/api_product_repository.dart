import 'package:cubico_backoffice/core/api/api_exception.dart';
import 'package:cubico_backoffice/core/api/api_table.dart';
import 'package:cubico_backoffice/features/products/domain/product.dart';
import 'package:cubico_backoffice/features/products/domain/product_repository.dart';
import 'package:dio/dio.dart';

/// Os produtos, vindos da API.
class ApiProductRepository implements ProductRepository {
  ApiProductRepository(this._dio) : _table = ApiTable(_dio, "/products", Product.fromJson);

  final Dio _dio;
  final ApiTable<Product> _table;

  @override
  Future<List<Product>> fetchAll() => _table.fetchAll();

  @override
  Future<Product> create({
    required String name,
    required String baseSku,
    required int categoryId,
  }) =>
      _table.create({"name": name, "base_sku": baseSku, "category_id": categoryId});

  @override
  Future<Product> update(Product product) => _table.update(product.id, product.toJson());

  @override
  Future<void> delete(int id) => apiCall(() async {
        await _dio.delete<void>("/products/$id");
      });
}
