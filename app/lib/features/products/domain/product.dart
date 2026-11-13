import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart'; // o gerador cria estes dois ficheiros;
part 'product.g.dart'; // enquanto nao os criar, o analyzer queixa-se — e normal

@freezed
abstract class Product with _$Product {
  const factory Product({
    required int id,
    required String name,
    required String baseSku,
    String? description,
    int? categoryId,
    // o endereço da foto (obrigatória ao criar; os produtos antigos podem não ter → null)
    // no modo demo é um "data:" URI, com a imagem dentro do próprio texto
    String? photoUrl,
    required DateTime createdAt,
    required DateTime updatedAt,

    // o valor por omissao vive aqui: o JSON pode nao trazer o campo
    @Default(ProductStatus.draft)
    ProductStatus status, // se nao vier, assume este valor
    @Default(false) bool isCustomizable, // se nao vier, assume este valor
    @Default(false) bool isPack, // se nao vier, assume este valor
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}

/// Os tres estados possiveis de um produto na tabela `products`.
/// O @JsonValue diz qual e o texto que viaja no JSON; sem ele,
/// o gerador usaria o nome do campo em Dart.
enum ProductStatus {
  @JsonValue("active")
  active,
  @JsonValue("draft")
  draft,
  @JsonValue("archived")
  archived,
}
