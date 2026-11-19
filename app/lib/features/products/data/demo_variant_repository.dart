import 'package:cubico_backoffice/core/api/api_exception.dart';
import 'package:cubico_backoffice/features/products/domain/sku.dart';
import 'package:cubico_backoffice/features/products/domain/variant.dart';
import 'package:cubico_backoffice/features/products/domain/variant_repository.dart';

class DemoVariantRepository implements VariantRepository {
  DemoVariantRepository({required this.productSku});

  /// O SKU de um produto (CD3-SEC-01), para dar o SKU às variantes.
  final Future<String> Function(int productId) productSku;

  final List<Variant> _items = [
    // Suporte de auscultadores (produto 1): duas cores
    Variant(
      id: 1,
      productId: 1,
      name: "Preto mate",
      sku: "CD3-SEC-01-01",
      salePrice: 24.00,
      printTimeMin: 120,
      filaments: [VariantFilament(filamentId: 1, grams: 120)],
      components: [
        VariantComponent(componentId: 3, quantity: 2), // 2 parafusos
        VariantComponent(componentId: 4), // caixa
        VariantComponent(componentId: 7), // autocolante
      ],
    ),
    Variant(
      id: 2,
      productId: 1,
      name: "Laranja",
      sku: "CD3-SEC-01-02",
      salePrice: 24.00,
      printTimeMin: 120,
      filaments: [VariantFilament(filamentId: 2, grams: 120)],
      components: [
        VariantComponent(componentId: 3, quantity: 2),
        VariantComponent(componentId: 4),
        VariantComponent(componentId: 7),
      ],
    ),
    // Árvore de Natal (produto 2): uma variante
    Variant(
      id: 3,
      productId: 2,
      name: "Verde",
      sku: "CD3-BRI-01-01",
      salePrice: 12.00,
      printTimeMin: 60,
      filaments: [VariantFilament(filamentId: 1, grams: 60)],
      components: [
        VariantComponent(componentId: 5), // papel de seda
        VariantComponent(componentId: 6), // cartão
      ],
    ),
  ];

  Future<void> _latency() => Future.delayed(const Duration(milliseconds: 300));

  @override
  Future<List<Variant>> fetchByProduct(int productId) async {
    await _latency();
    return _items.where((v) => v.productId == productId).toList();
  }

  int _nextId = 100;

  /// Falha como a API, quando o produto já tem outra variante com este nome (ou outra sem nome).
  void _checkFree(int productId, String name, {int? exceptId}) {
    final wanted = plainUpper(name);
    if (_items.any((v) => v.productId == productId && plainUpper(v.name) == wanted && v.id != exceptId)) {
      throw ApiException(
        name.trim().isEmpty
            ? "Só uma variante pode ficar sem nome. Dá um nome a esta (ex.: Hamilton)."
            : "Já existe uma variante com esse nome neste produto.",
      );
    }
  }

  @override
  Future<Variant> create({required int productId, String name = ""}) async {
    await _latency();
    _checkFree(productId, name);
    // como na API: com nome, o próximo número (CD3-NAT-01-03); sem nome, o SKU do produto
    final base = await productSku(productId);
    final sku = variantSku(base, name.trim().isEmpty ? null : _nextNumber(productId, base));
    // como na API: copia o preço, o tempo, o peso e a receita da primeira variante do produto
    final first = _items.where((v) => v.productId == productId).firstOrNull;
    final created = (first ?? Variant(id: 0, productId: productId, name: "", sku: "", salePrice: 0))
        .copyWith(id: _nextId++, name: name.trim(), sku: sku, modelFile: null, etsyListingId: null);
    _items.add(created);
    return created;
  }

  int _nextNumber(int productId, String base) =>
      nextVariantNumber(base, _items.where((v) => v.productId == productId).map((v) => v.sku));

  /// O SKU do produto mudou (mudou de categoria): as variantes trocam o início e ficam com o número.
  void rebase(int productId, String baseSku) {
    for (final (i, v) in _items.indexed) {
      if (v.productId != productId) continue;
      final number = v.isUnnamed ? null : int.tryParse(v.sku.split("-").last);
      _items[i] = v.copyWith(sku: variantSku(baseSku, number));
    }
  }

  @override
  Future<Variant> update(Variant variant) async {
    await _latency();
    final index = _items.indexWhere((v) => v.id == variant.id);
    if (index == -1) throw StateError("Variante ${variant.id} não existe.");
    // como na API: mudar o nome não muda o SKU; só ganhar nome (número) ou perdê-lo (SKU do produto)
    _checkFree(variant.productId, variant.name, exceptId: variant.id);
    final old = _items[index];
    final base = await productSku(variant.productId);
    final named = variant.name.trim().isNotEmpty;
    final sku = !named
        ? base
        : old.isUnnamed
            ? variantSku(base, _nextNumber(variant.productId, base))
            : old.sku;
    final saved = variant.copyWith(name: variant.name.trim(), sku: sku);
    _items[index] = saved;
    return saved;
  }

  @override
  Future<List<Variant>> fetchAll() async {
    await _latency();
    return List<Variant>.of(_items);
  }

  @override
  Future<void> delete(int id) async {
    await _latency();
    _items.removeWhere((v) => v.id == id);
  }
}
