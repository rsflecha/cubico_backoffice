import 'package:cubico_backoffice/app/theme.dart';
import 'package:cubico_backoffice/features/products/domain/sku.dart';
import 'package:material_ui/material_ui.dart';

/// O que a janela devolve: o nome e (só ao criar) o código que entra no SKU.
typedef CategoryInput = ({String name, String code});

class CategoryDialog extends StatefulWidget {
  const CategoryDialog({
    super.key,
    this.title = "Nova categoria",
    this.confirmLabel = "Adicionar",
    this.initialName = "",
    this.takenCodes,
  });

  final String title;
  final String confirmLabel;
  final String initialName;

  /// Os códigos já usados. Com eles, a janela mostra o campo do código (só ao criar:
  /// depois de haver produtos, o código já não muda, porque está nos SKU).
  final Iterable<String>? takenCodes;

  @override
  State<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  // Os ajudantes que guardam o que está escrito nos campos.
  late final _controller = TextEditingController(text: widget.initialName);
  final _code = TextEditingController();
  var _codeTouched = false; // escreveste no código? então deixa de seguir o nome

  bool get _withCode => widget.takenCodes != null;

  @override
  void initState() {
    super.initState();
    if (_withCode) _code.text = newCategoryCode(_controller.text, widget.takenCodes!);
  }

  @override
  void dispose() {
    _controller.dispose(); // deitar fora quando a janela fecha
    _code.dispose();
    super.dispose();
  }

  /// O problema do código, ou null se estiver bom.
  String? _codeProblem() {
    if (!_withCode) return null;
    final code = plainUpper(_code.text);
    if (!isValidCategoryCode(code)) return "2 a 5 letras ou algarismos, sem espaços.";
    if (code == noCategoryCode) return "$noCategoryCode é dos produtos sem categoria.";
    if (widget.takenCodes!.contains(code)) return "Já há uma categoria com $code.";
    return null;
  }

  void _confirm() {
    if (_codeProblem() != null) return;
    Navigator.pop<CategoryInput>(context, (name: _controller.text, code: plainUpper(_code.text)));
  }

  @override
  Widget build(BuildContext context) {
    final problem = _codeProblem();
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              autofocus: true, // o cursor já aparece no campo
              decoration: const InputDecoration(hintText: "Ex.: Decoração"),
              // enquanto não mexeres no código, ele acompanha o nome (Decoração → DEC)
              onChanged: (name) {
                if (_withCode && !_codeTouched) {
                  setState(() => _code.text = newCategoryCode(name, widget.takenCodes!));
                }
              },
              onSubmitted: (_) => _confirm(),
            ),
            if (_withCode) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _code,
                style: AppTextStyles.mono,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: "Código no SKU",
                  helperText: problem == null
                      ? "Os produtos ficam CD3-${plainUpper(_code.text)}-01, -02… Depois de haver produtos, já não muda."
                      : null,
                  helperMaxLines: 2,
                  errorText: problem,
                ),
                onChanged: (_) => setState(() => _codeTouched = true),
                onSubmitted: (_) => _confirm(),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // fecha sem devolver nada
          child: const Text("Cancelar"),
        ),
        FilledButton(
          onPressed: problem == null ? _confirm : null, // fecha e devolve o nome (e o código)
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
