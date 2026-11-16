import 'package:cubico_backoffice/features/auth/domain/auth_repository.dart';
import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// O mínimo de caracteres. Tem de ser o mesmo da API (routes/auth.php).
const minPasswordLength = 10;

/// Abre a janela e, se a palavra-passe mudar, avisa por baixo.
Future<void> showChangePasswordDialog(BuildContext context) async {
  final changed = await showDialog<bool>(
    context: context,
    builder: (context) => const ChangePasswordDialog(),
  );
  if (changed == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Palavra-passe mudada. As sessões noutros aparelhos foram terminadas."),
      ),
    );
  }
}

/// A janela "Mudar palavra-passe": a atual, a nova e a nova outra vez.
/// É um StatefulWidget que cria e deita fora os seus próprios controllers.
class ChangePasswordDialog extends ConsumerStatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  ConsumerState<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<ChangePasswordDialog> {
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _repeat = TextEditingController();
  var _show = false; // o "olho": mostrar as três
  var _submitted = false;
  var _saving = false;
  String? _apiError; // a mensagem da API ("A palavra-passe atual está errada.")

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _repeat.dispose();
    super.dispose();
  }

  /// O primeiro problema que impede de gravar, ou null.
  String? _problem() {
    if (_current.text.isEmpty) return "Escreve a palavra-passe atual.";
    if (_new.text.length < minPasswordLength) {
      return "A nova tem de ter pelo menos $minPasswordLength caracteres.";
    }
    if (_new.text == _current.text) return "A nova tem de ser diferente da atual.";
    if (_repeat.text != _new.text) return "A nova e a repetição não são iguais.";
    return null;
  }

  Future<void> _save() async {
    setState(() {
      _submitted = true;
      _apiError = null;
    });
    if (_problem() != null) return;

    setState(() => _saving = true);
    try {
      await ref.read(sessionProvider.notifier).changePassword(_current.text, _new.text);
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _apiError = error.message;
      });
      return;
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final problem = _submitted ? _problem() ?? _apiError : _apiError;

    TextField field(TextEditingController controller, String label, {String? helper}) =>
        TextField(
          controller: controller,
          obscureText: !_show,
          enabled: !_saving,
          decoration: InputDecoration(labelText: label, helperText: helper),
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _save(),
        );

    return AlertDialog(
      title: const Text("Mudar palavra-passe"),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            field(_current, "Palavra-passe atual"),
            const SizedBox(height: 12),
            field(_new, "Nova palavra-passe", helper: "Pelo menos $minPasswordLength caracteres."),
            const SizedBox(height: 12),
            field(_repeat, "Repetir a nova"),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _show,
              onChanged: (v) => setState(() => _show = v ?? false),
              title: const Text("Mostrar as palavras-passe"),
            ),
            if (problem != null)
              Text(problem, style: const TextStyle(color: Color(0xFFB91C1C))),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text("Cancelar"),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text("Mudar"),
        ),
      ],
    );
  }
}
