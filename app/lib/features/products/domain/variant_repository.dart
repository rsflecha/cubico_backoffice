import 'package:cubico_backoffice/features/products/domain/variant.dart';

abstract interface class VariantRepository {
  /// As variantes de um produto.
  Future<List<Variant>> fetchByProduct(int productId);

  /// Cria uma variante nova, vazia ("Nova variante", preço 0), para depois se preencher.
  Future<Variant> create({required int productId});

  /// Grava as alterações de uma variante (preço, receita…).
  Future<Variant> update(Variant variant);

  /// Todas as variantes da loja.
  Future<List<Variant>> fetchAll();

  /// Apaga uma variante (com a receita). Falha se já tiver sido vendida.
  Future<void> delete(int id);
}
