import 'dart:typed_data';

import 'product.dart';

abstract interface class ProductRepository {
  Future<List<Product>> fetchAll();

  /// Cria o produto JÁ com a foto (é obrigatória). [photo] é um JPG, já reduzido por preparePhoto().
  /// O SKU (CD3-SEC-01) não se escolhe: é dado pela categoria e pela ordem.
  Future<Product> create({
    required String name,
    required int categoryId,
    required Uint8List photo,
    List<int> colorIds = const [],
    int colorsPerPiece = 1,
  });

  Future<Product> update(Product product);

  /// Troca a foto de um produto e devolve-o com o endereço novo.
  Future<Product> replacePhoto(int productId, Uint8List photo);

  Future<void> delete(int id);
}
