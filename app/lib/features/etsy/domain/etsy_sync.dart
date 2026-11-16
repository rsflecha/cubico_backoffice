import 'package:freezed_annotation/freezed_annotation.dart';

part 'etsy_sync.freezed.dart';
part 'etsy_sync.g.dart';

/// Uma sincronização com a Etsy, tal como ficou registada na API.
@freezed
abstract class EtsySyncRun with _$EtsySyncRun {
  const factory EtsySyncRun({
    required String status, // running, ok, error
    required DateTime startedAt,
    DateTime? finishedAt,
    @Default(0) int createdCount,
    @Default(0) int updatedCount,
    @Default(0) int skippedCount, // por associar: um SKU que não existe no backoffice
    String? errorMessage,
    String? notes, // quais ficaram por associar, uma por linha
  }) = _EtsySyncRun;

  factory EtsySyncRun.fromJson(Map<String, dynamic> json) => _$EtsySyncRunFromJson(json);
}

/// O que a barra das Encomendas precisa: a loja está ligada? e a última sincronização.
@freezed
abstract class EtsySyncInfo with _$EtsySyncInfo {
  const factory EtsySyncInfo({
    @Default(false) bool connected,
    EtsySyncRun? last,
  }) = _EtsySyncInfo;

  factory EtsySyncInfo.fromJson(Map<String, dynamic> json) => _$EtsySyncInfoFromJson(json);
}

/// "há 5 min", "há 2 h", "há 3 dias" — para a barra das Encomendas.
String timeAgo(DateTime when, DateTime now) {
  final d = now.difference(when);
  if (d.inMinutes < 1) return "agora mesmo";
  if (d.inMinutes < 60) return "há ${d.inMinutes} min";
  if (d.inHours < 24) return "há ${d.inHours} h";
  return d.inDays == 1 ? "há 1 dia" : "há ${d.inDays} dias";
}
