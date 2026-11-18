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

  /// Quanto já imprimiu, de 0 a 1, calculado pelo tempo desde o início.
  /// 0 se ainda não começou; nunca passa de 1.
  double progressAt(DateTime now) {
    final start = startedAt;
    if (start == null || estimatedMin <= 0) return 0;
    final elapsed = now.difference(start).inSeconds / 60;
    return (elapsed / estimatedMin).clamp(0.0, 1.0);
  }

  /// Os minutos que faltam, nunca menos de 0.
  int minutesLeftAt(DateTime now) {
    final left = estimatedMin * (1 - progressAt(now));
    return left.round();
  }
}

/// Quanto tempo uma tarefa concluída fica à vista no quadro.
const doneVisibleFor = Duration(days: 1);

/// As tarefas concluídas que o quadro ainda mostra: as acabadas nas últimas 24 horas,
/// das mais recentes para as mais antigas. As outras não se apagam: só saem do quadro.
/// Uma concluída sem hora de fim (dados antigos) conta como antiga.
List<PrintJob> recentlyDone(Iterable<PrintJob> jobs, DateTime now) {
  final since = now.subtract(doneVisibleFor);
  return jobs
      .where((j) => j.status == PrintJobStatus.done && j.finishedAt != null && j.finishedAt!.isAfter(since))
      .toList()
    ..sort((a, b) => b.finishedAt!.compareTo(a.finishedAt!));
}
