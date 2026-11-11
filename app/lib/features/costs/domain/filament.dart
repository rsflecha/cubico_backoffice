import 'package:freezed_annotation/freezed_annotation.dart';

part 'filament.freezed.dart'; // o gerador cria estes dois ficheiros;
part 'filament.g.dart'; // enquanto nao os criar, o analyzer queixa-se — e normal

@freezed
abstract class Filament with _$Filament {
  const Filament._();
  const factory Filament({
    required int id,
    required String material,
    String? brand,
    required String colorName,
    String? colorHex,
    required double listPrice,
    required double paidPrice,

    // o valor por omissao vive aqui: o JSON pode nao trazer o campo
    @Default(1000) int spoolWeightG, // se nao vier, assume este valor
    @Default(0) double shippingCost, // se nao vier, assume este valor
    @Default(1) int spoolsInOrder, // se nao vier, assume este valor
    @Default(250) int minStockG, // se nao vier, assume este valor
    @Default(true) bool isActive, // se nao vier, assume este valor
  }) = _Filament;

  factory Filament.fromJson(Map<String, dynamic> json) =>
      _$FilamentFromJson(json);

  /// Quanto se poupou em relação ao preço normal, em %. 0 se não houve desconto.
  double get discountPct {
    if (listPrice <= 0 || paidPrice >= listPrice) return 0;
    return (listPrice - paidPrice) / listPrice * 100;
  }

  /// O nome completo do filamento: "PLA Basic Black". É o nome que as variantes recebem.
  String get displayName => "$material $colorName";
}
