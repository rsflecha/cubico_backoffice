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
  const months = ["jan", "fev", "mar", "abr", "mai", "jun",
    "jul", "ago", "set", "out", "nov", "dez"];
  return "${date.day} ${months[date.month - 1]}";
}