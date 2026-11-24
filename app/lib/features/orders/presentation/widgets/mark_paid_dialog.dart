import 'package:cubico_backoffice/features/orders/presentation/order_labels.dart';
import 'package:material_ui/material_ui.dart';

/// "Marcar como pago": escolhe-se o método (MB WAY, transferência, dinheiro) e confirma-se.
/// Devolve o método escolhido, ou null se cancelar.
///
/// [deliver]: a janela que aparece ao entregar uma encomenda por pagar. Aí há também
/// "Entregar sem pagamento", que devolve "" (texto vazio: entrega, mas fica por pagar).
class MarkPaidDialog extends StatefulWidget {
  const MarkPaidDialog({super.key, this.initialMethod, this.deliver = false});

  final String? initialMethod;
  final bool deliver;

  @override
  State<MarkPaidDialog> createState() => _MarkPaidDialogState();
}

class _MarkPaidDialogState extends State<MarkPaidDialog> {
  late String _method = paymentMethods.contains(widget.initialMethod) ? widget.initialMethod! : paymentMethods.first;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.deliver ? "Ainda está por pagar" : "Marcar como pago"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.deliver) ...[
            const Text("Esta encomenda ainda está por pagar. A cliente já pagou?"),
            const SizedBox(height: 16),
          ],
          DropdownButtonFormField<String>(
            initialValue: _method,
            decoration: const InputDecoration(labelText: "Método"),
            items: [for (final m in paymentMethods) DropdownMenuItem(value: m, child: Text(m))],
            onChanged: (m) => setState(() => _method = m ?? _method),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
        if (widget.deliver)
          TextButton(onPressed: () => Navigator.pop(context, ""), child: const Text("Entregar sem pagamento")),
        FilledButton(
          onPressed: () => Navigator.pop(context, _method),
          child: Text(widget.deliver ? "Já pagou: entregar" : "Confirmar"),
        ),
      ],
    );
  }
}
