import 'package:cubico_backoffice/core/api/api_client.dart';
import 'package:cubico_backoffice/core/api/api_exception.dart';
import 'package:cubico_backoffice/features/settings/data/push_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Os avisos de encomendas novas (a API e o browser). Nos testes troca-se por um falso.
final pushServiceProvider = Provider<PushService>((ref) => PushService(ref.watch(dioProvider)));

/// "Avisos de encomendas novas" nas Definições: ligar, testar e desligar NESTE aparelho.
/// Cada aparelho liga os seus (o iPhone e o iPad são dois).
class PushTile extends ConsumerStatefulWidget {
  const PushTile({super.key});

  @override
  ConsumerState<PushTile> createState() => _PushTileState();
}

class _PushTileState extends ConsumerState<PushTile> {
  PushState? _state; // null = a ver
  String? _publicKey; // pedida antes do toque (ver PushService.publicKey)
  String? _error;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final service = ref.read(pushServiceProvider);
    try {
      final state = await service.state();
      String? key;
      if (state == PushState.off) key = await service.publicKey();
      if (!mounted) return;
      setState(() {
        _state = state;
        _publicKey = key;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = PushState.off;
        _error = e is ApiException ? e.message : "Não consegui ver os avisos deste aparelho.";
      });
    }
  }

  /// Corre [action] com o botão ocupado; mostra o erro em português se falhar.
  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) setState(() => _error = e is ApiException ? e.message : "Não foi possível. Tenta outra vez.");
    }
    if (mounted) setState(() => _busy = false);
  }

  /// A mensagem nova toma o lugar da anterior (não fica na fila à espera).
  void _say(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));

  Future<void> _enable() => _run(() async {
        final key = _publicKey;
        if (key == null) throw const ApiException("Os avisos ainda não estão configurados no servidor.");
        final granted = await ref.read(pushServiceProvider).enable(key);
        if (!mounted) return;
        if (!granted) {
          setState(() => _state = PushState.denied);
          return;
        }
        setState(() => _state = PushState.on);
        _say("Avisos ligados neste aparelho.");
      });

  Future<void> _disable() => _run(() async {
        await ref.read(pushServiceProvider).disable();
        if (!mounted) return;
        setState(() => _state = PushState.off);
        _say("Avisos desligados neste aparelho.");
      });

  Future<void> _test() => _run(() async {
        final sent = await ref.read(pushServiceProvider).sendTest();
        if (!mounted) return;
        _say(sent == 0
            ? "Nenhum aparelho recebeu. Desliga e volta a ligar os avisos."
            : sent == 1
                ? "Aviso de teste enviado. Deve chegar em segundos."
                : "Aviso de teste enviado para $sent aparelhos.");
      });

  @override
  Widget build(BuildContext context) {
    final state = _state;
    final (subtitle, actions) = switch (state) {
      null => ("A ver…", <Widget>[]),
      PushState.unsupported => ("Este browser não recebe avisos. No iPhone e no iPad, usa o site no ecrã principal.", <Widget>[]),
      PushState.homeScreen => (
          "Para receber avisos: abre o site no Safari → Partilhar → «Adicionar ao ecrã principal», "
              "e entra pela app que aparece no ecrã principal.",
          <Widget>[]
        ),
      PushState.denied => (
          "Os avisos estão bloqueados neste aparelho. No iPhone: Definições → Notificações → Cubico. "
              "No computador: o cadeado ao lado do endereço.",
          <Widget>[]
        ),
      PushState.off => (
          "Recebe um aviso quando entra uma encomenda (Etsy, ou criada por outra pessoa).",
          [FilledButton.tonal(onPressed: _busy ? null : _enable, child: const Text("Ligar avisos neste aparelho"))]
        ),
      PushState.on => (
          "Ligados neste aparelho.",
          [
            FilledButton.tonal(onPressed: _busy ? null : _test, child: const Text("Enviar aviso de teste")),
            TextButton(onPressed: _busy ? null : _disable, child: const Text("Desligar")),
          ]
        ),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          leading: Icon(state == PushState.on ? Icons.notifications_active_outlined : Icons.notifications_outlined),
          title: const Text("Avisos de encomendas novas"),
          subtitle: Text(subtitle),
        ),
        if (actions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(72, 0, 16, 12),
            child: Wrap(spacing: 8, runSpacing: 8, children: actions),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(72, 0, 16, 12),
            child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
      ],
    );
  }
}
