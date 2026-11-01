import 'package:material_ui/material_ui.dart';

class CategoryDialog extends StatefulWidget {
  const CategoryDialog({
    super.key,
    this.title = 'Nova categoria',
    this.confirmLabel = 'Adicionar',
    this.initialName = '',
  });

  final String title;
  final String confirmLabel;
  final String initialName;

  @override
  State<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  // O ajudante que guarda o que está escrito no campo.
  late final _controller = TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    _controller.dispose(); // deitar fora quando a janela fecha
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova categoria'),
      content: TextField(
        controller: _controller,
        autofocus: true, // o cursor já aparece no campo
        decoration: const InputDecoration(hintText: 'Ex.: Decoração'),
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // fecha sem devolver nada
          child: Text(widget.title),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text), // fecha e devolve o nome
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

