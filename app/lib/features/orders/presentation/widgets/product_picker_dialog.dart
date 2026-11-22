import 'package:cubico_backoffice/app/theme.dart';
import 'package:cubico_backoffice/core/formatting.dart';
import 'package:cubico_backoffice/features/products/domain/product.dart';
import 'package:cubico_backoffice/features/products/domain/product_category.dart';
import 'package:cubico_backoffice/features/products/domain/variant.dart';
import 'package:cubico_backoffice/features/products/presentation/widgets/product_photo.dart';
import 'package:material_ui/material_ui.dart';

/// "Escolher produto" na nova encomenda: por categoria, com a foto, e as variantes já à vista.
///
/// Quem não sabe o nome vai pela categoria e pela foto; quem sabe escreve na procura.
/// Devolve a variante escolhida (com `Navigator.pop`), ou null se fechar.
/// É um StatefulWidget: guarda a procura e a categoria escolhida, e deita fora o controller.
class ProductPickerDialog extends StatefulWidget {
  const ProductPickerDialog({
    super.key,
    required this.products,
    required this.variants,
    required this.categories,
  });

  final List<Product> products;
  final List<Variant> variants;
  final List<ProductCategory> categories;

  @override
  State<ProductPickerDialog> createState() => _ProductPickerDialogState();
}

class _ProductPickerDialogState extends State<ProductPickerDialog> {
  final _search = TextEditingController();
  int? _categoryId; // null = todas

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// Para comparar sem ligar a maiúsculas nem acentos: "Árvore" e "arvore" batem certo.
  static String _plain(String s) {
    const from = "áàâãäéèêëíìîïóòôõöúùûüçñ";
    const to = "aaaaaeeeeiiiiooooouuuucn";
    final lower = s.toLowerCase();
    final out = StringBuffer();
    for (final ch in lower.split("")) {
      final i = from.indexOf(ch);
      out.write(i < 0 ? ch : to[i]);
    }
    return out.toString();
  }

  /// Os grupos a mostrar: categoria → produtos → variantes, já filtrados e ordenados.
  List<_Group> _groups() {
    final query = _plain(_search.text.trim());
    final byProduct = <int, List<Variant>>{};
    for (final v in widget.variants) {
      byProduct.putIfAbsent(v.productId, () => []).add(v);
    }
    // variantes pela ordem em que foram criadas (-01, -02…), não pelo alfabeto
    for (final list in byProduct.values) {
      list.sort((a, b) => a.id.compareTo(b.id));
    }

    final categories = [...widget.categories]
      ..sort((a, b) => a.sortOrder != b.sortOrder
          ? a.sortOrder.compareTo(b.sortOrder)
          : _plain(a.name).compareTo(_plain(b.name)));
    final known = {for (final c in categories) c.id};

    // um grupo por categoria, e no fim "Sem categoria" (produtos sem categoria ou com uma apagada)
    final groups = <_Group>[
      for (final c in categories) _Group(c.id, c.name),
      _Group(null, "Sem categoria"),
    ];
    for (final p in widget.products) {
      final own = byProduct[p.id];
      if (own == null || own.isEmpty) continue; // sem variantes não se pode vender
      final categoryId = known.contains(p.categoryId) ? p.categoryId : null;
      if (_categoryId != null && categoryId != _categoryId) continue;
      final group = groups.firstWhere((g) => g.categoryId == categoryId);

      // a procura: no nome do produto ou da categoria mostra todas as variantes;
      // senão, só as variantes cujo nome ou SKU batem certo
      var shown = own;
      if (query.isNotEmpty) {
        final productHit = _plain(p.name).contains(query) || _plain(group.name).contains(query);
        if (!productHit) {
          shown = own.where((v) => _plain(v.name).contains(query) || _plain(v.sku).contains(query)).toList();
        }
      }
      if (shown.isEmpty) continue;
      group.items.add(_Item(p, shown, single: own.length == 1 && own.single.isUnnamed));
    }
    for (final g in groups) {
      g.items.sort((a, b) => _plain(a.product.name).compareTo(_plain(b.product.name)));
    }
    return groups.where((g) => g.items.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groups();
    // as categorias que têm produtos à venda (para os botões de cima)
    final withProducts = {
      for (final p in widget.products)
        if (widget.variants.any((v) => v.productId == p.id)) p.categoryId,
    };
    final chips = [...widget.categories.where((c) => withProducts.contains(c.id))]
      ..sort((a, b) => a.sortOrder != b.sortOrder ? a.sortOrder.compareTo(b.sortOrder) : a.name.compareTo(b.name));

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 8, 0),
          child: Row(
            children: [
              Expanded(child: Text("Escolher produto", style: Theme.of(context).textTheme.titleLarge)),
              IconButton(
                tooltip: "Fechar",
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: "Procurar (nome, variante ou SKU)",
              isDense: true,
              border: const OutlineInputBorder(),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: "Limpar",
                      onPressed: () => setState(_search.clear),
                      icon: const Icon(Icons.clear),
                    ),
            ),
          ),
        ),
        if (chips.isNotEmpty)
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                ChoiceChip(
                  label: const Text("Todas"),
                  selected: _categoryId == null,
                  onSelected: (_) => setState(() => _categoryId = null),
                ),
                for (final c in chips) ...[
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(c.name),
                    selected: _categoryId == c.id,
                    onSelected: (_) => setState(() => _categoryId = _categoryId == c.id ? null : c.id),
                  ),
                ],
              ],
            ),
          ),
        const Divider(height: 1),
        Expanded(
          child: groups.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text("Nenhum produto encontrado.", textAlign: TextAlign.center),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.only(bottom: 16),
                  children: [
                    for (final g in groups) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                        child: Text(
                          g.name.toUpperCase(),
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                letterSpacing: 1,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                      for (final item in g.items) _ProductEntry(item: item),
                    ],
                  ],
                ),
        ),
      ],
    );

    // no telemóvel ocupa o ecrã todo; no ecrã largo é uma janela
    final narrow = MediaQuery.sizeOf(context).width < 600;
    if (narrow) return Dialog.fullscreen(child: SafeArea(child: content));
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 720),
        child: content,
      ),
    );
  }
}

/// Um produto: a foto e o nome; por baixo, as variantes (ou o preço, se for modelo único).
class _ProductEntry extends StatelessWidget {
  const _ProductEntry({required this.item});

  final _Item item;

  @override
  Widget build(BuildContext context) {
    final p = item.product;
    if (item.single) {
      final v = item.variants.single;
      return ListTile(
        leading: ProductPhoto(url: p.photoUrl),
        title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Text(euro(v.salePrice), style: AppTextStyles.mono),
        onTap: () => Navigator.pop(context, v),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          leading: ProductPhoto(url: p.photoUrl),
          title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        for (final v in item.variants)
          ListTile(
            dense: true,
            // alinhado com o nome do produto (a foto tem 48 + 16 de espaço)
            contentPadding: const EdgeInsets.only(left: 80, right: 16),
            title: Text(v.label),
            subtitle: Text(v.sku, style: AppTextStyles.mono),
            trailing: Text(euro(v.salePrice), style: AppTextStyles.mono),
            onTap: () => Navigator.pop(context, v),
          ),
      ],
    );
  }
}

class _Group {
  _Group(this.categoryId, this.name);

  final int? categoryId;
  final String name;
  final items = <_Item>[];
}

class _Item {
  _Item(this.product, this.variants, {required this.single});

  final Product product;
  final List<Variant> variants;
  final bool single; // modelo único: uma linha só, com o preço
}
