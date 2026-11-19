import 'dart:convert';
import 'dart:typed_data';

import 'package:cubico_backoffice/features/products/domain/product.dart';
import 'package:cubico_backoffice/features/products/domain/product_repository.dart';
import 'package:cubico_backoffice/features/products/domain/sku.dart';

class DemoProductRepository implements ProductRepository {
  DemoProductRepository({required this.categoryCode, this.onSkuChanged});

  /// O código de uma categoria (SEC), para dar o SKU; null = sem categoria (GER).
  final Future<String?> Function(int? categoryId) categoryCode;

  /// Avisa as variantes quando o SKU de um produto muda (mudou de categoria).
  final void Function(int productId, String baseSku)? onSkuChanged;

  int _nextId = 4;
  final List<Product> _items = [
    Product(
      id: 1,
      name: "Suporte de auscultadores",
      baseSku: "CD3-SEC-01",
      categoryId: 1,
      status: ProductStatus.active,
      createdAt: DateTime(2026, 10, 1),
      updatedAt: DateTime(2026, 10, 1),
    ),
    Product(
      id: 2,
      name: "Árvore de Natal",
      baseSku: "CD3-BRI-01",
      categoryId: 2,
      status: ProductStatus.active,
      createdAt: DateTime(2026, 09, 15),
      updatedAt: DateTime(2026, 09, 15),
    ),
    Product(
      id: 3,
      name: "Bolas de Natal",
      baseSku: "CD3-BRI-02",
      categoryId: 2,
      status: ProductStatus.active,
      createdAt: DateTime(2026, 09, 25),
      updatedAt: DateTime(2026, 09, 25),
    ),
  ];

  Future<void> _latency() => Future.delayed(const Duration(milliseconds: 300));

  @override
  Future<List<Product>> fetchAll() async {
    await _latency();
    return List<Product>.of(_items);
  }

  @override
  Future<Product> create({
    required String name,
    required int categoryId,
    required Uint8List photo,
    List<int> colorIds = const [],
    int colorsPerPiece = 1,
  }) async {
    await _latency();
    // o SKU, como na API: o próximo número da categoria
    final baseSku = nextProductSku(await categoryCode(categoryId), _items.map((p) => p.baseSku));
    final now = DateTime.now();
    final created = Product(
      id: _nextId++,
      name: name,
      baseSku: baseSku,
      categoryId: categoryId,
      photoUrl: _dataUri(photo),
      colorIds: colorIds,
      colorsPerPiece: colorsPerPiece,
      createdAt: now,
      updatedAt: now,
    );
    _items.add(created);
    return created;
  }

  @override
  Future<Product> update(Product product) async {
    await _latency();
    final index = _items.indexWhere((p) => p.id == product.id);
    if (index == -1) throw StateError("Produto ${product.id} não existe.");
    var saved = product.copyWith(baseSku: _items[index].baseSku); // o SKU não se escreve à mão
    // mudou de categoria: SKU novo, no fim da numeração da categoria nova (e as variantes com ele)
    if (product.categoryId != _items[index].categoryId) {
      saved = saved.copyWith(
        baseSku: nextProductSku(await categoryCode(product.categoryId), _items.map((p) => p.baseSku)),
      );
      onSkuChanged?.call(saved.id, saved.baseSku);
    }
    _items[index] = saved;
    return saved;
  }

  @override
  Future<Product> replacePhoto(int productId, Uint8List photo) async {
    await _latency();
    final index = _items.indexWhere((p) => p.id == productId);
    if (index == -1) throw StateError("Produto $productId não existe.");
    final updated = _items[index].copyWith(photoUrl: _dataUri(photo), updatedAt: DateTime.now());
    _items[index] = updated;
    return updated;
  }

  /// Sem servidor, a foto fica dentro do próprio texto do endereço (um "data:" URI).
  /// O ProductPhoto sabe mostrá-la; quando a app fecha desaparece, como os outros dados demo.
  String _dataUri(Uint8List photo) => "data:image/jpeg;base64,${base64Encode(photo)}";

  @override
  Future<void> delete(int id) async {
    await _latency();
    _items.removeWhere((p) => p.id == id);
  }
}
