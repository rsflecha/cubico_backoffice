import 'package:cubico_backoffice/features/products/domain/variant.dart';
import 'package:cubico_backoffice/features/products/domain/variant_repository.dart';

class DemoVariantRepository implements VariantRepository {
  final List<Variant> _items = [
    // Suporte de auscultadores (produto 1): duas cores
    Variant(
      id: 1,
      productId: 1,
      name: "Preto mate",
      sku: "CD3-SDA-01-PM",
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
      sku: "CD3-SDA-01-LR",
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
      sku: "CD3-ADN-01-VD",
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

  @override
  Future<Variant> create({required int productId}) async {
    await _latency();
    final id = _nextId++;
    final created = Variant(
      id: id,
      productId: productId,
      name: "Nova variante",
      sku: "DEMO-$id",
      salePrice: 0,
    );
    _items.add(created);
    return created;
  }

  @override
  Future<Variant> update(Variant variant) async {
    await _latency();
    final index = _items.indexWhere((v) => v.id == variant.id);
    if (index == -1) throw StateError("Variante ${variant.id} não existe.");
    _items[index] = variant;
    return variant;
  }

  @override
  Future<List<Variant>> fetchAll() async {
    await _latency();
    return List<Variant>.of(_items);
  }
}
