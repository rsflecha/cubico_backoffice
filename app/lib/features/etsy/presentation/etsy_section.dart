import 'package:cubico_backoffice/core/api/api_exception.dart';
import 'package:cubico_backoffice/features/etsy/domain/etsy_status.dart';
import 'package:cubico_backoffice/features/etsy/presentation/etsy_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

/// dd/mm/aaaa, para as datas da ligação.
String _date(DateTime d) =>
    "${d.day.toString().padLeft(2, "0")}/${d.month.toString().padLeft(2, "0")}/${d.year}";

/// A ligação à loja Etsy, nas Definições (só o administrador a vê).
///
/// Ligar é feito em três tempos: a API prepara o pedido, o browser abre a Etsy
/// e o Rui autoriza; a Etsy volta à API, que guarda a ligação. A app só precisa
/// de ir buscar o estado outra vez ("Atualizar").
class EtsySection extends ConsumerWidget {
  const EtsySection({super.key});

  /// Mostra um erro numa barra em baixo.
  void _error(BuildContext context, Object error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error is ApiException ? error.message : "Não foi possível falar com o servidor."),
    ));
  }

  /// Pede o endereço à API e abre a Etsy noutra janela.
  Future<void> _connect(BuildContext context, WidgetRef ref) async {
    final Uri url;
    try {
      url = await ref.read(etsyRepositoryProvider).startConnect();
    } catch (error) {
      if (context.mounted) _error(context, error);
      return;
    }
    // no browser, uma janela aberta depois de um "await" pode ser bloqueada:
    // se não abriu, mostra um botão (aí o clique é do Rui e já não bloqueia)
    final opened = await launchUrl(url, mode: LaunchMode.externalApplication, webOnlyWindowName: "_blank");
    if (!context.mounted) return;
    if (!opened) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Abrir a Etsy"),
          content: const Text("O browser não abriu a janela da Etsy sozinho. Carrega no botão."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            FilledButton(
              onPressed: () {
                launchUrl(url, mode: LaunchMode.externalApplication, webOnlyWindowName: "_blank");
                Navigator.pop(context);
              },
              child: const Text("Abrir a Etsy"),
            ),
          ],
        ),
      );
      if (!context.mounted) return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Autoriza na Etsy (tens 10 minutos). Depois volta aqui e carrega em «Atualizar»."),
      duration: Duration(seconds: 8),
    ));
  }

  /// Desliga a loja, depois de confirmar.
  Future<void> _disconnect(BuildContext context, WidgetRef ref, String shop) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Desligar a Etsy?"),
        content: Text("As encomendas da loja «$shop» deixam de entrar sozinhas até voltares a ligar."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text("Desligar")),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(etsyRepositoryProvider).disconnect();
    } catch (error) {
      if (context.mounted) _error(context, error);
      return;
    }
    ref.invalidate(etsyStatusProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(etsyStatusProvider);
    final refresh = IconButton(
      tooltip: "Atualizar",
      onPressed: () => ref.invalidate(etsyStatusProvider),
      icon: const Icon(Icons.refresh),
    );

    return status.when(
      loading: () => const ListTile(
        leading: Icon(Icons.storefront_outlined),
        title: Text("Etsy"),
        subtitle: LinearProgressIndicator(),
      ),
      error: (error, _) => ListTile(
        leading: const Icon(Icons.error_outline),
        title: const Text("Etsy"),
        subtitle: Text(error is ApiException ? error.message : "Não foi possível ver o estado."),
        trailing: refresh,
      ),
      data: (s) => _body(context, ref, s, refresh),
    );
  }

  Widget _body(BuildContext context, WidgetRef ref, EtsyStatus s, Widget refresh) {
    // 1. falta a chave da app no servidor: só o Rui a pode pôr (no .env)
    if (!s.configured) {
      return ListTile(
        leading: const Icon(Icons.key_off_outlined),
        title: const Text("Etsy: falta a chave da app"),
        subtitle: const Text(
          "Põe ETSY_KEYSTRING, ETSY_SHARED_SECRET e ETSY_REDIRECT_URI no .env do servidor.",
        ),
        trailing: refresh,
      );
    }

    // 2. ainda não ligada
    if (!s.connected) {
      return ListTile(
        leading: const Icon(Icons.storefront_outlined),
        title: const Text("Etsy: loja por ligar"),
        subtitle: const Text("Liga uma vez e as encomendas da Etsy passam a entrar sozinhas."),
        trailing: Wrap(
          spacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            refresh,
            FilledButton(onPressed: () => _connect(context, ref), child: const Text("Ligar à Etsy")),
          ],
        ),
      );
    }

    // 3. ligada (com aviso se a ligação está quase a expirar)
    final shop = s.shopName ?? "";
    final soon = s.expiresSoon(DateTime.now());
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.check_circle_outline, color: soon ? Colors.amber.shade800 : Colors.green.shade700),
          title: Text("Etsy: ligada à loja «$shop»"),
          subtitle: Text([
            if (s.connectedAt != null) "Desde ${_date(s.connectedAt!)}.",
            if (s.refreshExpiresAt != null)
              soon
                  ? "A ligação expira a ${_date(s.refreshExpiresAt!)}: sincroniza ou liga outra vez."
                  : "Renova-se sozinha a cada sincronização.",
          ].join(" ")),
          trailing: refresh,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [
              TextButton(onPressed: () => _disconnect(context, ref, shop), child: const Text("Desligar")),
              OutlinedButton(onPressed: () => _connect(context, ref), child: const Text("Ligar outra vez")),
            ],
          ),
        ),
      ],
    );
  }
}
