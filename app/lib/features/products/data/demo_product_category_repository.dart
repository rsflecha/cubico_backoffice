import '../domain/product_category.dart';
import '../domain/product_category_repository.dart';

class DemoProductCategoryRepository implements ProductCategoryRepository {
  /// As quatro categorias do seed.sql, para a demo comecar com conteudo real.
  final List<ProductCategory> _items = [
    const ProductCategory(id: 1, name: 'Secretária', color: '#C2410C', sortOrder: 1),
    const ProductCategory(id: 2, name: 'Brindes', color: '#0D7698', sortOrder: 2),
    const ProductCategory(id: 3, name: 'Flexi', color: '#7C3AED', sortOrder: 3),
    const ProductCategory(id: 4, name: 'Packs', color: '#15803D', sortOrder: 4),
  ];

  int _nextId = 5;

  Future<void> _latency() =>
      Future.delayed(const Duration(milliseconds: 300));

  @override
  Future<List<ProductCategory>> fetchAll() async {
    await _latency();

    // Copia primeiro, ordena depois: o .sort() altera a lista onde e chamado,
    // e ordenar _items diretamente era mexer no estado interno sem necessidade.
    final copy = List<ProductCategory>.of(_items);
    copy.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return copy;
  }

  @override
  Future<ProductCategory> create({
    required String name,
    String color = '#A1A1AA',
    int sortOrder = 0,
  }) async {
    await _latency();

    final created = ProductCategory(
      id: _nextId++,          // atribui e avanca, tal como faria o INSERT
      name: name,
      color: color,
      sortOrder: sortOrder,
    );

    _items.add(created);
    return created;              // devolve ja com id, como o contrato promete
  }

  @override
  Future<ProductCategory> update(ProductCategory category) async {
    await _latency();

    final index = _items.indexWhere((c) => c.id == category.id);

    // indexWhere devolve -1 quando nao encontra. Deixar passar em silencio
    // seria o pior: a app mostrava "guardado" e nada tinha sido gravado.
    // Na API isto corresponde a um 404.
    if (index == -1) {
      throw StateError('Nao existe categoria com id ${category.id}');
    }

    _items[index] = category;
    return category;
  }

  @override
  Future<void> delete(int id) async {
    await _latency();
    _items.removeWhere((c) => c.id == id);
  }
}