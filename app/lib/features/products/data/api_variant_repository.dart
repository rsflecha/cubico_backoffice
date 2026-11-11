import 'package:cubico_backoffice/core/api/api_exception.dart';
import 'package:cubico_backoffice/features/products/domain/variant.dart';
import 'package:cubico_backoffice/features/products/domain/variant_repository.dart';
import 'package:dio/dio.dart';

/// As variantes, vindas da API. Cada uma traz a receita (filamentos e componentes) dentro dela.
class ApiVariantRepository implements VariantRepository {
  ApiVariantRepository(this._dio);

  final Dio _dio;

  List<Variant> _list(List<dynamic> data) => [
        for (final item in data) Variant.fromJson(item as Map<String, dynamic>),
      ];

  @override
  Future<List<Variant>> fetchByProduct(int productId) => apiCall(() async {
        final response = await _dio.get<List<dynamic>>(
          "/variants",
          queryParameters: {"product_id": productId}, // fica /variants?product_id=3
        );
        return _list(response.data!);
      });

  @override
  Future<List<Variant>> fetchAll() => apiCall(() async {
        final response = await _dio.get<List<dynamic>>("/variants");
        return _list(response.data!);
      });

  @override
  Future<Variant> create({required int productId}) => apiCall(() async {
        final response = await _dio.post<Map<String, dynamic>>(
          "/variants",
          data: {"product_id": productId},
        );
        return Variant.fromJson(response.data!);
      });

  @override
  Future<Variant> update(Variant variant) => apiCall(() async {
        final response = await _dio.put<Map<String, dynamic>>(
          "/variants/${variant.id}",
          data: variant.toJson(), // inclui a receita: filaments e components
        );
        return Variant.fromJson(response.data!);
      });

  @override
  Future<void> delete(int id) => apiCall(() async {
    await _dio.delete<void>("/variants/$id");
  });
}
