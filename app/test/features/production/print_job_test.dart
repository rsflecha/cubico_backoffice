import 'package:cubico_backoffice/features/production/domain/print_job.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final start = DateTime(2026, 11, 7, 10, 0);
  final job = PrintJob(id: 1, variantId: 1, estimatedMin: 300, startedAt: start);

  test("a meio do tempo, vai a meio", () {
    // 2 h 30 de 5 h = 50%, faltam 150 min
    final now = start.add(const Duration(minutes: 150));
    expect(job.progressAt(now), closeTo(0.5, 0.001));
    expect(job.minutesLeftAt(now), 150);
  });

  test("depois do tempo estimado, fica nos 100% e não falta nada", () {
    final now = start.add(const Duration(hours: 7));
    expect(job.progressAt(now), 1.0);
    expect(job.minutesLeftAt(now), 0);
  });

  test("sem hora de início, o progresso é 0", () {
    const notStarted = PrintJob(id: 2, variantId: 1, estimatedMin: 300);
    expect(notStarted.progressAt(DateTime.now()), 0);
  });
}