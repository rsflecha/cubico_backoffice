import 'package:freezed_annotation/freezed_annotation.dart';

part 'order.freezed.dart';
part 'order.g.dart';

/// Em que ponto está a encomenda.
enum OrderStatus {
  @JsonValue("pending")
  pending,
  @JsonValue("in_production")
  inProduction,
  @JsonValue("ready")
  ready,
  @JsonValue("shipped")
  shipped,
  @JsonValue("delivered")
  delivered,
  @JsonValue("cancelled")
  cancelled,
}

/// Se o cliente já pagou.
enum PaymentStatus {
  @JsonValue("unpaid")
  unpaid,
  @JsonValue("paid")
  paid,
  @JsonValue("refunded")
  refunded,
}

/// Como chega ao cliente.
enum DeliveryMethod {
  @JsonValue("carrier")
  carrier, // transportadora (CTT…)
  @JsonValue("hand")
  hand, // entrega em mão
  @JsonValue("pickup")
  pickup, // levantamento
  @JsonValue("other")
  other,
}

@freezed
abstract class Order with _$Order {
  const Order._(); // permite ter getters (contas) dentro do modelo

  const factory Order({
    required int id,
    required int orderNumber, // o número que se vê: #1042
    required int channelId,
    String? externalRef, // nº da encomenda na Etsy
    int? customerId, // null = sem ficha de cliente
    required String customerName,
    String? customerContact,
    @Default(OrderStatus.pending) OrderStatus status,
    @Default(PaymentStatus.unpaid) PaymentStatus paymentStatus,
    String? paymentMethod,
    @Default(DeliveryMethod.carrier) DeliveryMethod deliveryMethod,
    String? carrierName,
    String? trackingCode,
    @Default(0) double shippingCharged, // portes que o cliente pagou
    @Default(0) double shippingPaid, // portes que custaram mesmo
    DateTime? shipByDate, // prazo de envio
    String? notes,
    @Default(false) bool createdManually,
    @Default(false) bool isSeen,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default([]) List<OrderLine> lines,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  /// Quantas peças tem a encomenda.
  int get itemCount => lines.fold(0, (sum, l) => sum + l.quantity);

  /// Artigos: quantidade × preço, menos descontos.
  double get itemsTotal =>
      lines.fold(0.0, (sum, l) => sum + l.quantity * l.unitPrice - l.discount);

  /// Produção: quantidade × custo de cada linha.
  double get productionCost =>
      lines.fold(0.0, (sum, l) => sum + l.quantity * l.unitCost);

  /// Taxas do canal, somadas.
  double get channelFees => lines.fold(0.0, (sum, l) => sum + l.channelFee);

  double get total {
    if (status == OrderStatus.cancelled) return 0;
    return itemsTotal + shippingCharged;
  }

  double get cost {
    if (status == OrderStatus.cancelled) return 0;
    return productionCost + channelFees + shippingPaid;
  }

  /// O que sobrou.
  double get profit => total - cost;

  /// Atrasada: o prazo de envio já passou e ainda não foi enviada.
  bool get isOverdue {
    final deadline = shipByDate;
    if (deadline == null) return false;
    final stillToShip =
        status == OrderStatus.pending ||
        status == OrderStatus.inProduction ||
        status == OrderStatus.ready;
    return stillToShip && deadline.isBefore(DateTime.now());
  }

  /// O passo seguinte no fluxo normal. null = já acabou (entregue) ou foi cancelada.
  OrderStatus? get nextStatus => switch (status) {
    OrderStatus.pending => OrderStatus.inProduction,
    OrderStatus.inProduction => OrderStatus.ready,
    OrderStatus.ready => OrderStatus.shipped,
    OrderStatus.shipped => OrderStatus.delivered,
    OrderStatus.delivered || OrderStatus.cancelled => null,
  };
}

/// Uma linha da encomenda: uma variante, quantas, e as "fotografias" de preço e custo.
@freezed
abstract class OrderLine with _$OrderLine {
  const factory OrderLine({
    required int id,
    required int variantId,
    @Default(1) int quantity,
    required double unitPrice, // preço de venda de cada unidade
    @Default(0) double discount,
    String? customization, // "nome: Ana", "cor: azul"…
    required double unitCost, // custo de produção, no dia da venda
    @Default(0) double channelFee, // taxa do canal desta linha
  }) = _OrderLine;

  factory OrderLine.fromJson(Map<String, dynamic> json) =>
      _$OrderLineFromJson(json);
}
