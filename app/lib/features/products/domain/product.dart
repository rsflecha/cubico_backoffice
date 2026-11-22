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
    // as cores em que se vende (ids dos filamentos): o menu "Cor" da encomenda mostra só estas.
    // Vazio = todas as cores ativas.
    @Default([]) List<int> colorIds,
    // quantas cores o cliente escolhe por peça: 1, ou 2 (a árvore de Natal: "Cor 1" e "Cor 2")
    @Default(1) int colorsPerPiece,
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

/// As cores de um produto, na encomenda.
extension ProductColors on Product {
  /// As cores vêm fixas em cada variante (o suporte F1: a Red Bull leva sempre branco, preto,
  /// vermelho e amarelo). Na encomenda não se escolhe cor; o custo é a receita, cor a cor.
  /// Guarda-se como "0 cores a escolher" (colors_per_piece = 0): não precisa de coluna nova.
  bool get hasFixedColors => colorsPerPiece == 0;
}
