import 'dart:convert';
import 'dart:typed_data';

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

  /// A foto como "parte" de um formulário multipart (o formato dos envios com ficheiros).
  MultipartFile _photoPart(Uint8List photo) => MultipartFile.fromBytes(
        photo,
        filename: "photo.jpg",
        contentType: DioMediaType("image", "jpeg"),
      );

  @override
  Future<Product> create({
    required String name,
    required String baseSku,
    required int categoryId,
    required Uint8List photo,
  }) =>
      apiCall(() async {
        // duas partes: "product" (o JSON, como texto) e "photo" (o ficheiro)
        final form = FormData.fromMap({
          "product": jsonEncode({"name": name, "base_sku": baseSku, "category_id": categoryId}),
          "photo": _photoPart(photo),
        });
        final response = await _dio.post<Map<String, dynamic>>("/products", data: form);
        return Product.fromJson(response.data!);
      });

  @override
  Future<Product> update(Product product) => _table.update(product.id, product.toJson());

  @override
  Future<Product> replacePhoto(int productId, Uint8List photo) => apiCall(() async {
        final form = FormData.fromMap({"photo": _photoPart(photo)});
        final response = await _dio.post<Map<String, dynamic>>("/products/$productId/photo", data: form);
        return Product.fromJson(response.data!);
      });

  @override
  Future<void> delete(int id) => apiCall(() async {
        await _dio.delete<void>("/products/$id");
      });
}
