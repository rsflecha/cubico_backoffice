import 'package:cubico_backoffice/core/api/api_exception.dart';
import 'package:cubico_backoffice/core/formatting.dart';
import 'package:cubico_backoffice/features/costs/domain/filament.dart';
import 'package:cubico_backoffice/features/stock/domain/weighing.dart';
import 'package:cubico_backoffice/features/stock/presentation/stock_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Abre a janela de acertar o stock de um filamento pesando.
Future<bool?> showAdjustmentDialog(
  BuildContext context, {
  required Filament filament,
  required double currentStockG,
}) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AdjustmentDialog(filament: filament, currentStockG: currentStockG),
  );
}

/// Acertar pesando: rolos fechados + o peso na balança de cada rolo aberto (com o carretel).
/// A conta que se vê aqui é só uma pré-visualização; a API refaz a conta.
class AdjustmentDialog extends ConsumerStatefulWidget {
  const AdjustmentDialog({super.key, required this.filament, required this.currentStockG});

  final Filament filament;
  final double currentStockG;

  @override
  ConsumerState<AdjustmentDialog> createState() => _AdjustmentDialogState();
}

class _AdjustmentDialogState extends ConsumerState<AdjustmentDialog> {
  final _closed = TextEditingController(text: "0");
  final _note = TextEditingController();
  late final List<TextEditingController> _open;
  var _saving = false;
  String? _saveError;

  /// Com a tara a 0 não se pesam rolos abertos: só os fechados.
  bool get _hasTare => widget.filament.emptySpoolG > 0;

  @override
  void initState() {
    super.initState();
    _open = [if (_hasTare) TextEditingController()];
  }

  @override
  void dispose() {
    _closed.dispose();
    _note.dispose();
    for (final c in _open) {
      c.dispose();
    }
    super.dispose();
  }

  /// Os rolos fechados escritos; null se não for um número inteiro.
  int? get _closedSpools => int.tryParse(_closed.text.trim().isEmpty ? "0" : _closed.text.trim());

  /// Os pesos escritos nos rolos abertos (as linhas vazias não contam).
  List<double> get _openGross => [
    for (final c in _open)
      if (c.text.trim().isNotEmpty) parseDecimal(c.text),
  ];

  String? get _problem {
    final closed = _closedSpools;
    if (closed == null) return "Os rolos fechados têm de ser um número inteiro.";
    return weighingProblem(
      closedSpools: closed,
      openGrossG: _openGross,
      emptySpoolG: widget.filament.emptySpoolG,
    );
  }

  Future<void> _save() async {
    if (_saving || _problem != null) return;
    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      await ref.read(stockRepositoryProvider).recordAdjustment(
        widget.filament.id,
        closedSpools: _closedSpools!,
        openGrossG: _openGross,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );
      ref.invalidate(filamentStockProvider);
      ref.invalidate(filamentMovementsProvider(widget.filament.id));
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      _fail(e.message);
    } on StateError catch (e) {
      _fail(e.message); // o modo demo avisa assim
    } catch (_) {
      _fail("Não foi possível gravar o acerto.");
    }
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() {
      _saving = false;
      _saveError = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.filament;
    final problem = _problem;
    final closed = _closedSpools;
    final error = Theme.of(context).colorScheme.error;

    Widget? preview;
    if (problem == null && closed != null) {
      final total = weighedTotal(
        closedSpools: closed,
        spoolWeightG: f.spoolWeightG,
        openGrossG: _openGross,
        emptySpoolG: f.emptySpoolG,
      );
      final diff = roundGrams(total - widget.currentStockG);
      final sign = diff > 0 ? "+" : (diff < 0 ? "−" : "");
      preview = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Total real: ${gramsText(total)}", style: const TextStyle(fontWeight: FontWeight.w600)),
          Text("Diferença: $sign${gramsText(diff.abs())}"),
        ],
      );
    }

    return AlertDialog(
      title: const Text("Acertar o stock"),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Em stock agora: ${gramsText(widget.currentStockG)}"),
              const SizedBox(height: 12),
              TextField(
                controller: _closed,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Rolos fechados",
                  helperText: "Contam ${f.spoolWeightG} g cada um",
                ),
                onChanged: (_) => setState(() {}),
              ),
              if (_hasTare) ...[
                for (var i = 0; i < _open.length; i++) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _open[i],
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: "Rolo aberto ${i + 1} (peso na balança, g)",
                      helperText: i == 0 ? "Com o carretel: desconta-se o carretel vazio (${f.emptySpoolG} g)" : null,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: _saving ? null : () => setState(() => _open.add(TextEditingController())),
                    child: const Text("+ outro rolo aberto"),
                  ),
                ),
              ] else
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    "Para pesar rolos abertos falta o peso do carretel vazio deste filamento: "
                    "preenche-o em Custos e preços. Por agora só se acertam rolos fechados.",
                  ),
                ),
              const SizedBox(height: 12),
              TextField(
                controller: _note,
                decoration: const InputDecoration(labelText: "Nota (opcional)"),
              ),
              const SizedBox(height: 12),
              ?preview,
              if (problem != null) Text(problem, style: TextStyle(color: error)),
              if (_saveError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_saveError!, style: TextStyle(color: error)),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text("Cancelar")),
        FilledButton(onPressed: (_saving || problem != null) ? null : _save, child: const Text("Gravar")),
      ],
    );
  }
}
