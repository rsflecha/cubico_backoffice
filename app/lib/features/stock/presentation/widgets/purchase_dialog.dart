import 'package:cubico_backoffice/core/api/api_exception.dart';
import 'package:cubico_backoffice/core/formatting.dart';
import 'package:cubico_backoffice/features/costs/domain/filament.dart';
import 'package:cubico_backoffice/features/stock/presentation/stock_providers.dart';
import 'package:cubico_backoffice/features/stock/presentation/stock_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Abre a janela de registar uma compra. [filamentId] pré-escolhe o filamento.
Future<bool?> showPurchaseDialog(
  BuildContext context, {
  required List<Filament> filaments,
  int? filamentId,
}) {
  return showDialog<bool>(
    context: context,
    builder: (_) => PurchaseDialog(filaments: filaments, filamentId: filamentId),
  );
}

/// Registar uma compra de rolos fechados. Os controllers nascem e morrem aqui.
class PurchaseDialog extends ConsumerStatefulWidget {
  const PurchaseDialog({super.key, required this.filaments, this.filamentId});

  final List<Filament> filaments;
  final int? filamentId;

  @override
  ConsumerState<PurchaseDialog> createState() => _PurchaseDialogState();
}

class _PurchaseDialogState extends ConsumerState<PurchaseDialog> {
  final _spools = TextEditingController(text: "1");
  final _price = TextEditingController();
  final _shipping = TextEditingController(text: "0");
  late int _filamentId = widget.filamentId ?? widget.filaments.first.id;
  var _saving = false;
  String? _error;

  @override
  void dispose() {
    _spools.dispose();
    _price.dispose();
    _shipping.dispose();
    super.dispose();
  }

  /// Um valor escrito: vazio = 0; texto que não é número = null.
  double? _number(String text) {
    if (text.trim().isEmpty) return 0;
    return double.tryParse(text.trim().replaceAll(",", "."));
  }

  /// O que está mal no formulário, ou null. Valida aqui porque o modo demo não o faz.
  String? _problem() {
    final spools = int.tryParse(_spools.text.trim());
    if (spools == null || spools < 1 || spools > 255) {
      return "Os rolos têm de ser um número inteiro entre 1 e 255.";
    }
    final price = _number(_price.text);
    if (price == null || price < 0) return "O preço pago tem de ser um número, zero ou mais.";
    final shipping = _number(_shipping.text);
    if (shipping == null || shipping < 0) return "Os portes têm de ser um número, zero ou mais.";
    return null;
  }

  Future<void> _save() async {
    if (_saving) return; // um segundo toque não grava outra vez
    final problem = _problem();
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    setState(() {
      _saving = true; // antes do primeiro await
      _error = null;
    });
    try {
      await ref.read(stockRepositoryProvider).recordPurchase(
        _filamentId,
        spools: int.parse(_spools.text.trim()),
        paidPrice: parseDecimal(_price.text),
        shippingCost: parseDecimal(_shipping.text),
      );
      ref.invalidate(filamentStockProvider);
      ref.invalidate(filamentMovementsProvider(_filamentId));
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      _fail(e.message);
    } on StateError catch (e) {
      _fail(e.message); // o modo demo avisa assim
    } catch (_) {
      _fail("Não foi possível gravar a compra.");
    }
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() {
      _saving = false;
      _error = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final spools = int.tryParse(_spools.text.trim());
    final price = _number(_price.text);
    return AlertDialog(
      title: const Text("Registar compra"),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<int>(
                initialValue: _filamentId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: "Filamento"),
                items: [
                  for (final f in widget.filaments)
                    DropdownMenuItem(value: f.id, child: Text(filamentLabel(f), overflow: TextOverflow.ellipsis)),
                ],
                onChanged: _saving ? null : (value) => setState(() => _filamentId = value ?? _filamentId),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _spools,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Rolos"),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _price,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: "Preço pago (total dos rolos)", suffixText: "€"),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _shipping,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: "Portes", suffixText: "€"),
              ),
              if (spools != null && spools > 0 && price != null && price > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text("Preço por rolo: ${euro(price / spools)}"),
                ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text("Cancelar")),
        FilledButton(onPressed: _saving ? null : _save, child: const Text("Gravar")),
      ],
    );
  }
}
