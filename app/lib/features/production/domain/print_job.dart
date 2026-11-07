import 'package:freezed_annotation/freezed_annotation.dart';

part 'print_job.freezed.dart';
part 'print_job.g.dart';

/// As colunas do quadro de produção.
enum PrintJobStatus {
  @JsonValue("queued")
  queued, // por imprimir
  @JsonValue("printing")
  printing, // a imprimir
  @JsonValue("post_processing")
  postProcessing, // pós-processamento (limpar suportes, montar…)
  @JsonValue("done")
  done, // concluído
}

/// Uma tarefa de impressão: uma variante, quantas unidades, e em que ponto está.
@freezed
abstract class PrintJob with _$PrintJob {
  const PrintJob._();

  const factory PrintJob({
    required int id,
    int? orderLineId, // null = tarefa manual (stock, protótipo)
    int? orderId, // a encomenda (vem da API, juntando à linha)
    int? orderNumber, // o número que se vê: #1041
    required int variantId,
    @Default(1) int quantity,
    @Default(PrintJobStatus.queued) PrintJobStatus status,
    required int estimatedMin, // tempo de impressão estimado, em minutos
    DateTime? startedAt,
    DateTime? finishedAt,
    String? notes, // "Limpar suportes", "Stock para a feira"…
  }) = _PrintJob;

  factory PrintJob.fromJson(Map<String, dynamic> json) => _$PrintJobFromJson(json);

  /// A coluna seguinte. null = já está concluída.
  PrintJobStatus? get nextStatus => switch (status) {
    PrintJobStatus.queued => PrintJobStatus.printing,
    PrintJobStatus.printing => PrintJobStatus.postProcessing,
    PrintJobStatus.postProcessing => PrintJobStatus.done,
    PrintJobStatus.done => null,
  };
}