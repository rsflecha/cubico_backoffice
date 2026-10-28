import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_category.freezed.dart';   // o gerador cria estes dois ficheiros;
part 'product_category.g.dart';         // enquanto nao os criar, o analyzer queixa-se — e normal

@freezed
abstract class ProductCategory with _$ProductCategory {
  const factory ProductCategory({
    required int id,
    required String name,
    // o valor por omissao vive aqui: o JSON pode nao trazer o campo
    @Default('#A1A1AA') String color,
    @Default(0) int sortOrder,
  }) = _ProductCategory;

  factory ProductCategory.fromJson(Map<String, dynamic> json) =>
      _$ProductCategoryFromJson(json);
}