import 'package:cubico_backoffice/features/orders/domain/order.dart';
import 'package:cubico_backoffice/features/orders/domain/order_repository.dart';
import 'package:cubico_backoffice/features/production/domain/print_job.dart';
import 'package:cubico_backoffice/features/production/domain/print_job_repository.dart';
import 'package:cubico_backoffice/features/products/domain/variant.dart';

/// As regras que ligam as encomendas à produção.
class ProductionService {
  ProductionService(this._jobs, this._orders);

  final PrintJobRepository _jobs;
  final OrderRepository _orders;

  /// Envia uma encomenda para produção: cria uma tarefa por linha
  /// e muda a encomenda para "Em produção".
  Future<void> sendToProduction(Order order, List<Variant> variants) async {
    for (final line in order.lines) {
      final variant = variants.where((v) => v.id == line.variantId).firstOrNull;
      await _jobs.create(
        PrintJob(
          id: 0,
          orderLineId: line.id,
          orderId: order.id,
          orderNumber: order.orderNumber,
          variantId: line.variantId,
          quantity: line.quantity,
          estimatedMin: (variant?.printTimeMin ?? 0) * line.quantity,
          notes: line.customization == null ? null : "«${line.customization}»",
        ),
      );
    }
    await _orders.update(
      order.copyWith(status: OrderStatus.inProduction, updatedAt: DateTime.now()),
    );
  }

  /// Acerta o estado da encomenda depois de mexer numa tarefa dela:
  /// todas concluídas → "Pronta"; alguma por concluir → volta a "Em produção".
  Future<void> syncOrder(int orderId) async {
    final jobs = (await _jobs.fetchAll()).where((j) => j.orderId == orderId).toList();
    if (jobs.isEmpty) return;

    final order = (await _orders.fetchAll()).where((o) => o.id == orderId).firstOrNull;
    if (order == null) return;

    final allDone = jobs.every((j) => j.status == PrintJobStatus.done);
    final OrderStatus? newStatus;
    if (allDone && order.status == OrderStatus.inProduction) {
      newStatus = OrderStatus.ready;
    } else if (!allDone && order.status == OrderStatus.ready) {
      newStatus = OrderStatus.inProduction;
    } else {
      newStatus = null; // nada a mudar
    }

    if (newStatus != null) {
      await _orders.update(order.copyWith(status: newStatus, updatedAt: DateTime.now()));
    }
  }
}