import 'package:cubico_backoffice/features/orders/domain/order.dart';
import 'package:cubico_backoffice/features/orders/presentation/order_labels.dart';
import 'package:material_ui/material_ui.dart';

/// A etiqueta colorida do estado: texto da cor do estado, fundo da mesma cor bem clara.
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
