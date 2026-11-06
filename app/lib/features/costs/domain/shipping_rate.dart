import 'package:freezed_annotation/freezed_annotation.dart';

part 'shipping_rate.freezed.dart';
part 'shipping_rate.g.dart';

/// Um escalão de portes: até X gramas, custa Y euros.
@freezed
abstract class ShippingRate with _$ShippingRate {
  const factory ShippingRate({
    required int id,
    @Default(1) int carrierId, // 1 = CTT Correio Registado (PT); 2 = CTT Correio Azul Internacional
    @Default(1) int zoneId,    // 1 = Portugal; 2 = Europa; 3 = EUA; 4 = Resto do mundo
    required int maxWeightG,   // o peso máximo deste escalão, incluído
    required double price,
  }) = _ShippingRate;

  factory ShippingRate.fromJson(Map<String, dynamic> json) =>
      _$ShippingRateFromJson(json);
}