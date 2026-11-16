import 'package:cubico_backoffice/features/products/domain/variant.dart';

abstract interface class VariantRepository {
  /// As variantes de um produto.
  Future<List<Variant>> fetchByProduct(int productId);

  /// Cria uma variante com este nome ("" = o próprio produto, sem variantes).
  /// O SKU sai do nome; se o produto já tiver variantes, a nova copia o preço,
  /// o tempo, o peso e a receita da primeira.
  Future<Variant> create({required int productId, String name = ""});

  /// Grava as alterações de uma variante (nome, preço, receita…). O SKU acompanha o nome.
  Future<Variant> update(Variant variant);

  /// Todas as variantes da loja.
  Future<List<Variant>> fetchAll();

  /// Apaga uma variante (com a receita). Falha se já tiver sido vendida.
  Future<void> delete(int id);
}
