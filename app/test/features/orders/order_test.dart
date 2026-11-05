import 'package:cubico_backoffice/features/orders/domain/order.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("total, custo e lucro de uma encomenda", () {
    // 2 × 15 € = 30 € + 4 € portes cobrados = 34 € recebidos
    // custos: 2 × 4 € produção + 3,55 € taxa Etsy + 3,90 € portes reais = 15,45 €
    // lucro: 34 − 15,45 = 18,55 €
    final order = Order(
      id: 1,
      orderNumber: 1042,
      channelId: 1,
      customerName: "Ana Martins",
      shippingCharged: 4,
      shippingPaid: 3.90,
      createdAt: DateTime(2026, 10, 19),
      updatedAt: DateTime(2026, 10, 19),
      lines: const [
        OrderLine(id: 1, variantId: 1, quantity: 2, unitPrice: 15, unitCost: 4, channelFee: 3.55),
      ],
    );

    expect(order.itemCount, 2);
    expect(order.total, closeTo(34, 0.001));
    expect(order.cost, closeTo(15.45, 0.001));
    expect(order.profit, closeTo(18.55, 0.001));
  });
}