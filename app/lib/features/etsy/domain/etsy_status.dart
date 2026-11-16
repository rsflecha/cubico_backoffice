import 'package:freezed_annotation/freezed_annotation.dart';

part 'etsy_status.freezed.dart';
part 'etsy_status.g.dart';

/// O estado da ligação à loja Etsy (os tokens nunca chegam à app).
@freezed
abstract class EtsyStatus with _$EtsyStatus {
  const EtsyStatus._(); // para poder ter getters

  const factory EtsyStatus({
    /// A chave da app Etsy está no .env do servidor?
    @Default(false) bool configured,

    /// A loja já foi autorizada?
    @Default(false) bool connected,
    String? shopName,
    DateTime? connectedAt,

    /// Depois disto (90 dias sem sincronizar) é preciso ligar outra vez.
    DateTime? refreshExpiresAt,
  }) = _EtsyStatus;

  factory EtsyStatus.fromJson(Map<String, dynamic> json) => _$EtsyStatusFromJson(json);

  /// Faltam menos de 14 dias para a ligação expirar?
  bool expiresSoon(DateTime now) =>
      refreshExpiresAt != null && refreshExpiresAt!.difference(now).inDays < 14;
}
