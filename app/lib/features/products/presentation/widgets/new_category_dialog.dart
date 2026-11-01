import 'package:material_ui/material_ui.dart';

class NewCategoryDialog extends StatefulWidget {
  const NewCategoryDialog({super.key});

  @override
  State<NewCategoryDialog> createState() => _NewCategoryDialogState();
}

class _NewCategoryDialogState extends State<NewCategoryDialog> {
  // O ajudante que guarda o que está escrito no campo.
  final _controller = TextEditingController();

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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // fecha sem devolver nada
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text), // fecha e devolve o nome
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}