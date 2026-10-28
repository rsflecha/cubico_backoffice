import 'package:freezed_annotation/freezed_annotation.dart';

part 'variant.freezed.dart';   // o gerador cria estes dois ficheiros;
part 'variant.g.dart';         // enquanto nao os criar, o analyzer queixa-se — e normal

@freezed
abstract class Variant with _$Variant {
  const factory Variant({
    required int id,
    required int productId,
    required String name,
    required String sku,
    required double salePrice,
    int? printerId,
    String? modelFile,
    String? etsyListingId,


    // o valor por omissao vive aqui: o JSON pode nao trazer o campo
    @Default(0) int printTimeMin,  // se nao vier, assume este valor
    @Default(1) int plateCount,  // se nao vier, assume este valor
    @Default(0) int weightG,  // se nao vier, assume este valor
    @Default(true) bool isActive,

  }) = _Variant;

  factory Variant.fromJson(Map<String, dynamic> json) =>
      _$VariantFromJson(json);

}