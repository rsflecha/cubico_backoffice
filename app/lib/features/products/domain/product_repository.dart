import 'dart:typed_data';

import 'product.dart';

abstract interface class ProductRepository {
  Future<List<Product>> fetchAll();

  /// Cria o produto JÁ com a foto (é obrigatória). [photo] é um JPG, já reduzido por preparePhoto().
  Future<Product> create({
    required String name,
    required String baseSku,
    required int categoryId,
    required Uint8List photo,
  });

  Future<Product> update(Product product);

  /// Troca a foto de um produto e devolve-o com o endereço novo.
  Future<Product> replacePhoto(int productId, Uint8List photo);

  Future<void> delete(int id);
}
