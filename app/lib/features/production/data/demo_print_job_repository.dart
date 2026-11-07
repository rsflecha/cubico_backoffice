import 'package:cubico_backoffice/features/production/domain/print_job.dart';
import 'package:cubico_backoffice/features/production/domain/print_job_repository.dart';

class DemoPrintJobRepository implements PrintJobRepository {
  static DateTime _hours(int n) => DateTime.now().add(Duration(hours: n));

  final List<PrintJob> _items = [
    // #1041 está "Em produção": a peça dela está a imprimir há 2 horas
    PrintJob(
      id: 1, orderId: 2, orderNumber: 1041, variantId: 2,
      status: PrintJobStatus.printing, estimatedMin: 300, startedAt: _hours(-2),
    ),
    // #1037 está "Pronta": a tarefa já acabou
    PrintJob(
      id: 2, orderId: 4, orderNumber: 1037, variantId: 1,
      status: PrintJobStatus.done, estimatedMin: 300,
      startedAt: _hours(-80), finishedAt: _hours(-74),
    ),
    // tarefas manuais, sem encomenda
    const PrintJob(
      id: 3, variantId: 3, quantity: 2, estimatedMin: 150,
      notes: "Stock para a feira de Natal",
    ),
    PrintJob(
      id: 4, variantId: 1, status: PrintJobStatus.postProcessing, estimatedMin: 300,
      startedAt: _hours(-10), finishedAt: _hours(-5), notes: "Limpar suportes",
    ),
  ];

  int _nextId = 100;

  @override
  Future<PrintJob> create(PrintJob draft) async {
    await _latency();
    final created = draft.copyWith(id: _nextId++);
    _items.add(created);
    return created;
  }

  Future<void> _latency() => Future.delayed(const Duration(milliseconds: 300));

  @override
  Future<List<PrintJob>> fetchAll() async {
    await _latency();
    return List<PrintJob>.of(_items);
  }

  @override
  Future<PrintJob> update(PrintJob job) async {
    await _latency();
    final index = _items.indexWhere((j) => j.id == job.id);
    if (index == -1) throw StateError("Tarefa ${job.id} não existe.");
    _items[index] = job;
    return job;
  }
}