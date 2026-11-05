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

  /// O que o cliente pagou: artigos (com desconto) + portes cobrados.
  double get total =>
      lines.fold(0.0, (sum, l) => sum + l.quantity * l.unitPrice - l.discount) +
          shippingCharged;

  /// O que a encomenda custou: produção + taxas do canal + portes reais.
  double get cost =>
      lines.fold(0.0, (sum, l) => sum + l.quantity * l.unitCost + l.channelFee) +
          shippingPaid;

  /// O que sobrou.
  double get profit => total - cost;
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