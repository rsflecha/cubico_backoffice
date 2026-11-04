import 'package:cubico_backoffice/features/products/domain/variant.dart';

abstract interface class VariantRepository {
  /// As variantes de um produto.
  Future<List<Variant>> fetchByProduct(int productId);

  /// Grava as alterações de uma variante (preço, receita…).
  Future<Variant> update(Variant variant);
}