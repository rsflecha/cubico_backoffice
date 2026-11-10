import 'package:cubico_backoffice/core/api/api_exception.dart';
import 'package:cubico_backoffice/features/products/domain/product_category.dart';
import 'package:cubico_backoffice/features/products/domain/product_category_repository.dart';
import 'package:dio/dio.dart';

/// As categorias, vindas da API.
class ApiProductCategoryRepository implements ProductCategoryRepository {
  ApiProductCategoryRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<ProductCategory>> fetchAll() => apiCall(() async {
        final response = await _dio.get<List<dynamic>>("/categories");
        return [
          for (final item in response.data!)
            ProductCategory.fromJson(item as Map<String, dynamic>),
        ];
      });

  @override
  Future<ProductCategory> create({
    required String name,
    String color = "#A1A1AA",
    int sortOrder = 0,
  }) =>
      apiCall(() async {
        final response = await _dio.post<Map<String, dynamic>>(
          "/categories",
          data: {"name": name, "color": color, "sort_order": sortOrder},
        );
        return ProductCategory.fromJson(response.data!);
      });

  @override
  Future<ProductCategory> update(ProductCategory category) => apiCall(() async {
        final response = await _dio.put<Map<String, dynamic>>(
          "/categories/${category.id}",
          data: category.toJson(), // os nomes já vêm em snake_case (sort_order)
        );
        return ProductCategory.fromJson(response.data!);
      });

  @override
  Future<void> delete(int id) => apiCall(() async {
        await _dio.delete<void>("/categories/$id");
      });
}
