import 'package:cubico_backoffice/features/orders/domain/order.dart';
import 'package:cubico_backoffice/features/orders/domain/order_repository.dart';

class DemoOrderRepository implements OrderRepository {
  /// Uma data a contar de hoje: _days(-2) = há 2 dias; _days(3) = daqui a 3 dias.
  static DateTime _days(int n) => DateTime.now().add(Duration(days: n));

  final List<Order> _items = [
    Order(
      id: 1,
      orderNumber: 1042,
      channelId: 1,
      externalRef: "3412987001",
      customerName: "Ana Martins",
      status: OrderStatus.pending,
      paymentStatus: PaymentStatus.paid,
      paymentMethod: "Etsy Payments",
      carrierName: "CTT",
      shippingCharged: 4.00,
      shippingPaid: 3.90,
      shipByDate: _days(3),
      createdAt: _days(-1),
      updatedAt: _days(-1),
      lines: const [
        OrderLine(
          id: 1,
          variantId: 1,
          quantity: 1,
          unitPrice: 24.00,
          unitCost: 4.10,
          channelFee: 3.04,
        ),
        OrderLine(
          id: 2,
          variantId: 3,
          quantity: 1,
          unitPrice: 12.00,
          unitCost: 1.80,
          channelFee: 1.76,
        ),
      ],
    ),
    Order(
      id: 2,
      orderNumber: 1041,
      channelId: 2,
      customerName: "João Pereira",
      customerContact: "@joao.p",
      status: OrderStatus.inProduction,
      paymentStatus: PaymentStatus.paid,
      paymentMethod: "MB WAY",
      carrierName: "CTT",
      shippingCharged: 3.50,
      shippingPaid: 3.50,
      shipByDate: _days(2),
      createdAt: _days(-2),
      updatedAt: _days(-1),
      createdManually: true,
      lines: const [
        OrderLine(
          id: 3,
          variantId: 2,
          quantity: 1,
          unitPrice: 24.00,
          unitCost: 4.10,
        ),
      ],
    ),
    Order(
      id: 3,
      orderNumber: 1038,
      channelId: 1,
      externalRef: "3412986544",
      customerName: "Marta Costa",
      status: OrderStatus.pending,
      paymentStatus: PaymentStatus.paid,
      paymentMethod: "Etsy Payments",
      carrierName: "CTT",
      shippingCharged: 4.00,
      shippingPaid: 3.90,
      shipByDate: _days(-2), // prazo já passou: atrasada
      createdAt: _days(-8),
      updatedAt: _days(-8),
      lines: const [
        OrderLine(
          id: 4,
          variantId: 3,
          quantity: 3,
          unitPrice: 12.00,
          unitCost: 1.80,
          channelFee: 4.58,
        ),
      ],
    ),
    Order(
      id: 4,
      orderNumber: 1037,
      channelId: 4,
      customerName: "Pedro Sousa",
      customerContact: "912 345 678",
      status: OrderStatus.ready,
      paymentStatus: PaymentStatus.unpaid,
      paymentMethod: "Dinheiro",
      deliveryMethod: DeliveryMethod.hand,
      createdAt: _days(-9),
      updatedAt: _days(-3),
      createdManually: true,
      lines: const [
        OrderLine(
          id: 5,
          variantId: 1,
          quantity: 1,
          unitPrice: 24.00,
          unitCost: 4.10,
        ),
      ],
    ),
    Order(
      id: 5,
      orderNumber: 1040,
      channelId: 2,
      customerName: "Sofia Ribeiro",
      customerContact: "@sofiaribeiro",
      status: OrderStatus.shipped,
      paymentStatus: PaymentStatus.paid,
      paymentMethod: "MB WAY",
      carrierName: "CTT",
      trackingCode: "RR123456789PT",
      shippingCharged: 3.50,
      shippingPaid: 3.50,
      createdAt: _days(-4),
      updatedAt: _days(-1),
      createdManually: true,
      lines: const [
        OrderLine(
          id: 6,
          variantId: 3,
          quantity: 1,
          unitPrice: 12.00,
          unitCost: 1.80,
        ),
      ],
    ),
    Order(
      id: 6,
      orderNumber: 1039,
      channelId: 1,
      externalRef: "3412986910",
      customerName: "Tiago Lopes",
      status: OrderStatus.delivered,
      paymentStatus: PaymentStatus.paid,
      paymentMethod: "Etsy Payments",
      carrierName: "CTT",
      trackingCode: "RR987654321PT",
      shippingCharged: 4.00,
      shippingPaid: 3.90,
      createdAt: _days(-6),
      updatedAt: _days(-2),
      isSeen: true,
      lines: const [
        OrderLine(
          id: 7,
          variantId: 2,
          quantity: 1,
          unitPrice: 24.00,
          unitCost: 4.10,
          channelFee: 3.44,
        ),
      ],
    ),
    Order(
      id: 7,
      orderNumber: 1035,
      channelId: 3,
      customerName: "Rita Fonseca",
      status: OrderStatus.cancelled,
      paymentStatus: PaymentStatus.refunded,
      paymentMethod: "MB WAY",
      createdAt: _days(-12),
      updatedAt: _days(-11),
      createdManually: true,
      isSeen: true,
      lines: const [
        OrderLine(
          id: 8,
          variantId: 3,
          quantity: 1,
          unitPrice: 12.00,
          unitCost: 1.80,
        ),
      ],
    ),
  ];

  Future<void> _latency() => Future.delayed(const Duration(milliseconds: 300));

  @override
  Future<List<Order>> fetchAll() async {
    await _latency();
    // as mais recentes primeiro
    final copy = List<Order>.of(_items);
    copy.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return copy;
  }

  @override
  Future<Order> update(Order order) async {
    await _latency();
    final index = _items.indexWhere((o) => o.id == order.id);
    if (index == -1) throw StateError("Encomenda ${order.id} não existe.");
    _items[index] = order;
    return order;
  }
}
