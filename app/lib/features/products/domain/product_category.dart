import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';   // o gerador cria estes dois ficheiros;
part 'product_category.g.dart';         // enquanto nao os criar, o analyzer queixa-se — e normal

@freezed
abstract class Category with _$Category {
  const factory Category({
    required int id,
    required String name,
    // o valor por omissao vive aqui: o JSON pode nao trazer o campo
    @Default('#A1A1AA') String color,
    @Default(0) int sortOrder,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}