import 'dart:async';

import 'package:cubico_backoffice/features/auth/domain/passkey.dart';
import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// O nome que a pessoa conhece neste aparelho: Face ID no iPhone/iPad, Windows Hello…
String passkeyName() => switch (defaultTargetPlatform) {
  TargetPlatform.iOS || TargetPlatform.macOS => "Face ID",
  TargetPlatform.windows => "Windows Hello",
  _ => "impressão digital",
};

/// "19/11/2026"
String _date(DateTime d) => "${d.day.toString().padLeft(2, "0")}/${d.month.toString().padLeft(2, "0")}/${d.year}";

const _errorColor = Color(0xFFB91C1C);

// ═══════════════ Login: "Entrar com Face ID" ═══════════════

/// O botão do login. Pede o desafio à API logo ao aparecer (ver [PreparedPasskey]),
/// para que, no toque, o Face ID abra sem esperar pela rede.
class PasskeySignInButton extends ConsumerStatefulWidget {
  const PasskeySignInButton({super.key, required this.remember, required this.onSignedIn});

  /// O "Manter sessão" do ecrã de login.
  final bool remember;

  /// Entrou: o login muda de ecrã.
  final VoidCallback onSignedIn;

  @override
  ConsumerState<PasskeySignInButton> createState() => _PasskeySignInButtonState();
}

class _PasskeySignInButtonState extends ConsumerState<PasskeySignInButton> {
  PreparedPasskey? _prepared;
  var _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_prepare());
  }

  /// Pede um desafio novo. Sem rede, não faz mal: no toque volta a tentar.
  Future<void> _prepare() async {
    try {
      final prepared = await ref.read(passkeyRepositoryProvider).prepareSignIn();
      if (mounted) _prepared = prepared;
    } catch (_) {
      _prepared = null;
    }
  }

  Future<void> _signIn() async {
    // cada desafio só serve uma vez: tira-o já
    var prepared = _prepared;
    _prepared = null;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      // nada de "await" antes do Face ID, se o desafio estiver pronto (o Safari exige-o)
      if (prepared == null || !prepared.isFresh) {
        prepared = await ref.read(passkeyRepositoryProvider).prepareSignIn();
      }
      await ref.read(sessionProvider.notifier).signInWithPasskey(prepared, remember: widget.remember);
      if (!mounted) return;
      widget.onSignedIn();
      return;
    } on PasskeyException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = "Não foi possível entrar. Tenta outra vez.");
    }
    if (!mounted) return;
    setState(() => _busy = false);
    unawaited(_prepare()); // para a próxima tentativa
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: _busy ? null : _signIn,
          icon: const Icon(Icons.face_outlined),
          label: Text("Entrar com ${passkeyName()}"),
        ),
        if (_error != null) ...[const SizedBox(height: 8), Text(_error!, style: const TextStyle(color: _errorColor))],
      ],
    );
  }
}

// ═══════════════ Definições: ativar e remover ═══════════════

/// As linhas do "A minha conta": ativar neste aparelho e a lista dos aparelhos.
class PasskeysTile extends ConsumerStatefulWidget {
  const PasskeysTile({super.key});

  @override
  ConsumerState<PasskeysTile> createState() => _PasskeysTileState();
}

class _PasskeysTileState extends ConsumerState<PasskeysTile> {
  String? _error;

  /// Abre a janela de 2 passos (palavra-passe, depois o Face ID).
  Future<void> _activate() async {
    setState(() => _error = null);
    final activated = await showDialog<bool>(context: context, builder: (_) => const _ActivateDialog());
    if (activated != true || !mounted) return;
    ref.invalidate(passkeysProvider);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${passkeyName()} ativo neste aparelho.")));
  }

  Future<void> _remove(Passkey passkey) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Remover ${passkeyName()}?"),
        content: Text(
          "O ${passkey.label} deixa de entrar sem palavra-passe. "
          "Podes voltar a ativar quando quiseres.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text("Remover")),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(passkeyRepositoryProvider).remove(passkey.id);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
    ref.invalidate(passkeysProvider);
  }

  @override
  Widget build(BuildContext context) {
    final name = passkeyName();
    final passkeys = ref.watch(passkeysProvider).value ?? const <Passkey>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          leading: const Icon(Icons.face_outlined),
          title: Text(name),
          subtitle: const Text("Entrar sem palavra-passe neste aparelho."),
          trailing: FilledButton.tonal(onPressed: _activate, child: const Text("Ativar")),
        ),
        for (final p in passkeys)
          ListTile(
            contentPadding: const EdgeInsets.only(left: 72, right: 16),
            title: Text(p.label),
            subtitle: Text(
              p.lastUsedAt == null
                  ? "Ativado a ${_date(p.createdAt)}"
                  : "Ativado a ${_date(p.createdAt)} · usado a ${_date(p.lastUsedAt!)}",
            ),
            trailing: TextButton(onPressed: () => _remove(p), child: const Text("Remover")),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(72, 0, 16, 12),
            child: Text(_error!, style: const TextStyle(color: _errorColor)),
          ),
      ],
    );
  }
}

/// "Ativar Face ID", em 2 passos:
///   1. a palavra-passe (a API confere-a e só então dá o desafio);
///   2. o botão que abre o Face ID. Tem de ser um toque à parte: o Safari só abre o
///      Face ID logo a seguir a um toque, e o passo 1 teve de esperar pela API.
/// É um StatefulWidget que cria e deita fora o seu controller.
class _ActivateDialog extends ConsumerStatefulWidget {
  const _ActivateDialog();

  @override
  ConsumerState<_ActivateDialog> createState() => _ActivateDialogState();
}

class _ActivateDialogState extends ConsumerState<_ActivateDialog> {
  final _password = TextEditingController();
  PreparedPasskey? _prepared; // depois do passo 1
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _checkPassword() async {
    if (_password.text.isEmpty) {
      setState(() => _error = "Escreve a tua palavra-passe.");
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final prepared = await ref.read(passkeyRepositoryProvider).prepareRegister(password: _password.text);
      if (!mounted) return;
      setState(() {
        _prepared = prepared;
        _busy = false;
      });
    } on PasskeyException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e.message;
      });
    }
  }

  Future<void> _register() async {
    final prepared = _prepared!;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      // sem "await" antes disto: o Face ID abre logo a seguir ao toque
      await ref.read(passkeyRepositoryProvider).register(prepared);
      if (mounted) Navigator.pop(context, true);
      return;
    } on PasskeyException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = "Não foi possível ativar. Tenta outra vez.");
    }
    // o desafio já foi gasto: volta ao passo 1
    setState(() {
      _busy = false;
      _prepared = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = passkeyName();
    final step2 = _prepared != null;
    return AlertDialog(
      title: Text("Ativar $name"),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!step2) ...[
              const Text("Para confirmar que és tu, escreve a tua palavra-passe."),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: true,
                autofocus: true,
                decoration: const InputDecoration(labelText: "Palavra-passe"),
                onSubmitted: (_) => _busy ? null : _checkPassword(),
              ),
            ] else
              Text("Toca em «Usar $name» e confirma com a cara ou o dedo."),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: _errorColor)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
        FilledButton(
          onPressed: _busy ? null : (step2 ? _register : _checkPassword),
          child: Text(step2 ? "Usar $name" : "Continuar"),
        ),
      ],
    );
  }
}
