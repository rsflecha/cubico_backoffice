import 'package:cubico_backoffice/core/api/api_exception.dart';
import 'package:cubico_backoffice/features/etsy/domain/etsy_listings_check.dart';
import 'package:cubico_backoffice/features/etsy/presentation/etsy_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

/// "Conferir os SKU": cada anúncio ativo da Etsy, e se uma venda dele entra sozinha na app.
///
/// Uma encomenda da Etsy só entra se o SKU de cada artigo for igual ao de uma variante
/// (ou, sem SKU, se o anúncio estiver ligado a uma só variante). Este ecrã mostra,
/// antes de haver vendas, quais iam ficar de fora. Só lê: não muda nada na Etsy.
class EtsyListingsCheckScreen extends ConsumerWidget {
  const EtsyListingsCheckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final check = ref.watch(etsyListingsCheckProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Conferir os SKU"),
        actions: [
          IconButton(
            tooltip: "Conferir outra vez",
            onPressed: check.isLoading ? null : () => ref.invalidate(etsyListingsCheckProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: check.when(
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("A ler os anúncios da Etsy…"),
            ],
          ),
        ),
        error: (error, _) => _ErrorView(
          message: error is ApiException ? error.message : "Não foi possível falar com o servidor.",
          onRetry: () => ref.invalidate(etsyListingsCheckProvider),
        ),
        data: (c) => _Result(check: c),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text("Tentar outra vez")),
          ],
        ),
      ),
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({required this.check});

  final EtsyListingsCheck check;

  @override
  Widget build(BuildContext context) {
    final listings = check.sorted;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _Summary(check: check),
            const SizedBox(height: 16),
            if (listings.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text("A loja não tem anúncios ativos.", textAlign: TextAlign.center),
              ),
            for (final l in listings) _ListingCard(listing: l, variants: check.variants),
            if (check.unlistedVariants.isNotEmpty) ...[
              const SizedBox(height: 8),
              Card(
                child: ExpansionTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: Text("Variantes da app sem anúncio na Etsy (${check.unlistedVariants.length})"),
                  subtitle: const Text("Não é um erro: só quer dizer que não estão à venda na Etsy."),
                  children: [
                    for (final v in check.unlistedVariants)
                      ListTile(
                        dense: true,
                        title: Text(v.label),
                        subtitle: Text(v.sku ?? ""),
                        onTap: v.productId == null ? null : () => context.go("/products/${v.productId}"),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// O resumo no topo: está tudo bem, ou quantos ficavam de fora.
class _Summary extends StatelessWidget {
  const _Summary({required this.check});

  final EtsyListingsCheck check;

  @override
  Widget build(BuildContext context) {
    final allOk = check.problems == 0;
    final color = allOk ? Colors.green.shade700 : Colors.red.shade700;
    return Card(
      child: ListTile(
        leading: Icon(allOk ? Icons.check_circle_outline : Icons.warning_amber_rounded, color: color, size: 32),
        title: Text(
          allOk
              ? "Tudo certo: ${check.ok} ${check.ok == 1 ? "artigo liga" : "artigos ligam"} a uma variante."
              : "${check.problems} ${check.problems == 1 ? "artigo ficava" : "artigos ficavam"} de fora numa venda.",
          style: TextStyle(fontWeight: FontWeight.w600, color: allOk ? null : color),
        ),
        subtitle: Text([
          allOk
              ? "As vendas destes anúncios entram sozinhas na app."
              : "Uma encomenda com um destes artigos não entra na app. "
                  "Põe na Etsy (Anúncio → Variações → SKU) o mesmo SKU da variante na app. "
                  "${check.ok} ${check.ok == 1 ? "artigo já liga" : "artigos já ligam"}.",
          if (check.digitalSkipped > 0)
            "${check.digitalSkipped} ${check.digitalSkipped == 1 ? "anúncio digital ignorado" : "anúncios digitais ignorados"} "
                "(os downloads não entram na app).",
        ].join(" ")),
      ),
    );
  }
}

/// Um anúncio e os seus produtos (um por variação).
class _ListingCard extends StatelessWidget {
  const _ListingCard({required this.listing, required this.variants});

  final EtsyListingCheck listing;
  final List<EtsyVariantRef> variants; // para associar à mão

  @override
  Widget build(BuildContext context) {
    final hasProblems = listing.problems > 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              title: Text(listing.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(hasProblems
                  ? "Anúncio ${listing.listingId} · ${listing.problems} por ligar"
                  : "Anúncio ${listing.listingId}"),
              trailing: listing.url.isEmpty
                  ? null
                  : IconButton(
                      tooltip: "Abrir na Etsy",
                      icon: const Icon(Icons.open_in_new),
                      onPressed: () => launchUrl(Uri.parse(listing.url),
                          mode: LaunchMode.externalApplication, webOnlyWindowName: "_blank"),
                    ),
            ),
            for (final p in listing.products) _ProductRow(product: p, listingId: listing.listingId, variants: variants),
          ],
        ),
      ),
    );
  }
}

class _ProductRow extends ConsumerWidget {
  const _ProductRow({required this.product, required this.listingId, required this.variants});

  final EtsyProductCheck product;
  final String listingId;
  final List<EtsyVariantRef> variants;

  /// Abre a janela para escolher a variante; se gravar, confere outra vez.
  Future<void> _link(BuildContext context, WidgetRef ref) async {
    final linked = await showDialog<bool>(
      context: context,
      builder: (_) => _LinkDialog(product: product, listingId: listingId, variants: variants),
    );
    if (linked == true) ref.invalidate(etsyListingsCheckProvider);
  }

  Future<void> _unlink(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(etsyRepositoryProvider).unlink(product.productId!);
      ref.invalidate(etsyListingsCheckProvider);
    } on ApiException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = product;
    final variant = p.variant;
    // a primeira linha: a escolha do comprador (se houver) e o SKU que está na Etsy
    final head = [
      if (p.variation.isNotEmpty) p.variation,
      p.sku == null ? "sem SKU" : "SKU ${p.sku}",
      if (p.pack > 1) "pack de ${p.pack} peças",
    ].join(" · ");
    // sem o número do produto da Etsy não há como associar (não devia acontecer)
    final canLink = p.productId != null && variants.isNotEmpty;
    return ListTile(
      dense: true,
      leading: Icon(
        p.isOk ? Icons.check_circle : Icons.cancel,
        color: p.isOk ? Colors.green.shade700 : Colors.red.shade700,
      ),
      title: Text(head),
      subtitle: Text(
          p.isOk ? "Liga a: ${variant?.label ?? "?"}${p.linked ? " (associado à mão)" : ""}" : p.problem!,
          style: p.isOk ? null : TextStyle(color: Colors.red.shade700)),
      trailing: p.linked
          ? TextButton(onPressed: () => _unlink(context, ref), child: const Text("Desfazer"))
          : !p.isOk && canLink
              ? FilledButton.tonal(onPressed: () => _link(context, ref), child: const Text("Associar"))
              : null,
      onTap: p.isOk && variant?.productId != null ? () => context.go("/products/${variant!.productId}") : null,
    );
  }
}

/// "Associar à mão": escolher a que variante da app corresponde este produto do anúncio.
/// É um StatefulWidget: guarda a escolha e o estado de gravar.
class _LinkDialog extends ConsumerStatefulWidget {
  const _LinkDialog({required this.product, required this.listingId, required this.variants});

  final EtsyProductCheck product;
  final String listingId;
  final List<EtsyVariantRef> variants;

  @override
  ConsumerState<_LinkDialog> createState() => _LinkDialogState();
}

class _LinkDialogState extends ConsumerState<_LinkDialog> {
  int? _variantId;
  var _busy = false;
  String? _error;

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(etsyRepositoryProvider).link(
            productId: widget.product.productId!,
            listingId: widget.listingId,
            variantId: _variantId!,
          );
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final what = [
      if (p.variation.isNotEmpty) p.variation,
      p.sku == null ? "sem SKU" : "SKU ${p.sku}",
    ].join(" · ");
    return AlertDialog(
      title: const Text("Associar a uma variante"),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Na Etsy: $what"),
            const SizedBox(height: 4),
            Text(
              "As vendas deste artigo passam a entrar como a variante escolhida. "
              "Se já houver vendas por associar, entram na próxima sincronização.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Flexible(
              child: RadioGroup<int>(
                groupValue: _variantId,
                onChanged: (v) => setState(() => _variantId = v),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final v in widget.variants)
                      RadioListTile<int>(
                        dense: true,
                        value: v.variantId,
                        title: Text(v.label),
                        subtitle: Text(v.sku ?? ""),
                      ),
                  ],
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: TextStyle(color: Colors.red.shade700)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
        FilledButton(onPressed: _busy || _variantId == null ? null : _save, child: const Text("Associar")),
      ],
    );
  }
}
