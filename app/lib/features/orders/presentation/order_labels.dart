import 'package:cubico_backoffice/features/orders/domain/order.dart';
import 'package:material_ui/material_ui.dart';

/// Texto e cores de cada estado da encomenda, para o ecrã.
extension OrderStatusLabels on OrderStatus {
  String get label => switch (this) {
    OrderStatus.pending => "Pendente",
    OrderStatus.inProduction => "Em produção",
    OrderStatus.ready => "Pronta",
    OrderStatus.shipped => "Enviada",
    OrderStatus.delivered => "Entregue",
    OrderStatus.cancelled => "Cancelada",
  };

  /// O nome no plural, para os separadores.
  String get pluralLabel => switch (this) {
    OrderStatus.pending => "Pendentes",
    OrderStatus.inProduction => "Em produção",
    OrderStatus.ready => "Prontas",
    OrderStatus.shipped => "Enviadas",
    OrderStatus.delivered => "Entregues",
    OrderStatus.cancelled => "Canceladas",
  };

  /// O texto do botão que leva a encomenda PARA este estado.
  String get actionLabel => switch (this) {
    OrderStatus.pending => "Voltar a pendente",
    OrderStatus.inProduction => "Enviar para produção",
    OrderStatus.ready => "Marcar como pronta",
    OrderStatus.shipped => "Marcar como enviada",
    OrderStatus.delivered => "Marcar como entregue",
    OrderStatus.cancelled => "Cancelar encomenda",
  };

  /// A cor do texto da etiqueta.
  Color get color => switch (this) {
    OrderStatus.pending => const Color(0xFF92400E),
    OrderStatus.inProduction => const Color(0xFF1E40AF),
    OrderStatus.ready => const Color(0xFF3730A3),
    OrderStatus.shipped => const Color(0xFF5B21B6),
    OrderStatus.delivered => const Color(0xFF166534),
    OrderStatus.cancelled => const Color(0xFF52525B),
  };
}

/// Texto e cor de cada estado de pagamento.
extension PaymentStatusLabels on PaymentStatus {
  String get label => switch (this) {
    PaymentStatus.unpaid => "Por pagar",
    PaymentStatus.paid => "Pago",
    PaymentStatus.refunded => "Reembolsado",
  };

  Color get color => switch (this) {
    PaymentStatus.unpaid => const Color(0xFFB45309),
    PaymentStatus.paid => const Color(0xFF15803D),
    PaymentStatus.refunded => const Color(0xFF71717A),
  };
}

/// Data curta em português: "19 out".
String shortDate(DateTime date) {
  const months = [
    "jan",
    "fev",
    "mar",
    "abr",
    "mai",
    "jun",
    "jul",
    "ago",
    "set",
    "out",
    "nov",
    "dez",
  ];
  return "${date.day} ${months[date.month - 1]}";
}

/// Texto de cada forma de entrega.
extension DeliveryMethodLabels on DeliveryMethod {
  String get label => switch (this) {
    DeliveryMethod.carrier => "Transportadora",
    DeliveryMethod.hand => "Entrega em mão",
    DeliveryMethod.pickup => "Levantamento",
    DeliveryMethod.other => "Outro",
  };
}

/// Cor do lucro: verde se ganhou, vermelho se perdeu, cinzento se foi cancelada.
Color profitColor(Order o) {
  if (o.status == OrderStatus.cancelled) return const Color(0xFF71717A);
  return o.profit >= 0 ? const Color(0xFF15803D) : const Color(0xFFB91C1C);
}
