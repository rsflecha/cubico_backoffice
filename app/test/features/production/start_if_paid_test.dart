import 'package:cubico_backoffice/features/orders/data/demo_order_repository.dart';
import 'package:cubico_backoffice/features/orders/domain/order.dart';
import 'package:cubico_backoffice/features/production/data/demo_print_job_repository.dart';
import 'package:cubico_backoffice/features/production/domain/print_job.dart';
import 'package:cubico_backoffice/features/production/domain/production_service.dart';
import 'package:cubico_backoffice/features/products/domain/variant.dart';
import 'package:flutter_test/flutter_test.dart';

// Regra: uma encomenda paga vai sozinha para produção ("Por imprimir").
// Com a API é a API que o faz (testado à parte); aqui é o modo demo.
void main() {
  const variants = [
    Variant(id: 901, productId: 1, name: "A", sku: "CD3-TST-90-A", salePrice: 10, printTimeMin: 30),
  ];

  Order draft(PaymentStatus payment) => Order(
        id: 0,
        orderNumber: 0,
        channelId: 2,
        customerName: "Teste",
        paymentStatus: payment,
        createdAt: DateTime(2026, 11, 16),
        updatedAt: DateTime(2026, 11, 16),
        lines: const [OrderLine(id: 0, variantId: 901, quantity: 2, unitPrice: 10, unitCost: 3, channelFee: 0, customization: "ANA")],
      );

  Future<(ProductionService, DemoOrderRepository, DemoPrintJobRepository, Order)> setUp(PaymentStatus p) async {
    final orders = DemoOrderRepository();
    final jobs = DemoPrintJobRepository();
    final created = await orders.create(draft(p));
    return (ProductionService(jobs, orders), orders, jobs, created);
  }

  test("paga: vai para produção, com uma tarefa por artigo em Por imprimir", () async {
    final (service, orders, jobs, order) = await setUp(PaymentStatus.paid);
    final before = (await jobs.fetchAll()).length;

    expect(await service.startIfPaid(order, variants), isTrue);

    final mine = (await jobs.fetchAll()).where((j) => j.orderId == order.id).toList();
    expect((await jobs.fetchAll()).length, before + 1);
    expect(mine.single.status, PrintJobStatus.queued);
    expect(mine.single.quantity, 2);
    expect(mine.single.estimatedMin, 60); // 30 min × 2
    expect(mine.single.notes, "«ANA»");
    final saved = (await orders.fetchAll()).firstWhere((o) => o.id == order.id);
    expect(saved.status, OrderStatus.inProduction);
  });

  test("por pagar: fica Pendente e sem tarefas (espera pelo botão)", () async {
    final (service, orders, jobs, order) = await setUp(PaymentStatus.unpaid);
    expect(await service.startIfPaid(order, variants), isFalse);
    expect((await jobs.fetchAll()).where((j) => j.orderId == order.id), isEmpty);
    expect((await orders.fetchAll()).firstWhere((o) => o.id == order.id).status, OrderStatus.pending);
  });

  test("já em produção (o que a API devolve): não duplica as tarefas", () async {
    final (service, _, jobs, order) = await setUp(PaymentStatus.paid);
    final fromApi = order.copyWith(status: OrderStatus.inProduction);
    expect(await service.startIfPaid(fromApi, variants), isFalse);
    expect((await jobs.fetchAll()).where((j) => j.orderId == order.id), isEmpty);
  });
}
