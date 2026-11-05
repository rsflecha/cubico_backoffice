import 'package:freezed_annotation/freezed_annotation.dart';

part 'sales_channel.freezed.dart';
part 'sales_channel.g.dart';

@freezed
abstract class SalesChannel with _$SalesChannel {
  const factory SalesChannel({
    required int id,
    required String code, // "etsy", "instagram"...
    required String name, // o que aparece no ecrã
    @Default(0) double transactionFee, // em %
    @Default(0) double processingFee, // em %
    @Default(0) double flatFee, // em € por venda
    @Default(0) double listingFee, // em € por venda
    @Default(false)
    bool isAutomatic, // true = as encomendas entram sozinhas (Etsy)
  }) = _SalesChannel;

  factory SalesChannel.fromJson(Map<String, dynamic> json) =>
      _$SalesChannelFromJson(json);
}
