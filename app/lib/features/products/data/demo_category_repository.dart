import '../domain/product_category.dart';
import '../domain/product_category_repository.dart';

/// Implementacao de demonstracao do contrato CategoryRepository.
///
/// Os dados vivem em memoria e desaparecem quando a app fecha. Serve para
/// construir e testar os ecras antes de a API existir. Na fatia 11 nasce uma
/// ApiCategoryRepository ao lado desta, com os mesmos metodos, e troca-se uma
/// pela outra num sitio so — os ecras nem dao por isso.
class DemoCategoryRepository implements CategoryRepository {
  /// As quatro categorias do seed.sql, para a demo comecar com conteudo real.
  final List<Category> _items = [
    const Category(id: 1, name: 'Secretária', color: '#C2410C', sortOrder: 1),
    const Category(id: 2, name: 'Chaveiros', color: '#0D7698', sortOrder: 2),
    const Category(id: 3, name: 'Flexi', color: '#7C3AED', sortOrder: 3),
    const Category(id: 4, name: 'Packs', color: '#15803D', sortOrder: 4),
  ];

  /// Faz o papel do AUTO_INCREMENT da base de dados: comeca a seguir ao
  /// ultimo id da lista acima. Sem isto, duas categorias criadas seguidas
  /// ficavam com o mesmo id e a app passava a editar a errada.
  int _nextId = 5;

  /// Finge a demora da rede.
  ///
  /// Parece inutil numa lista em memoria, mas obriga-nos a construir os ecras
  /// ja com estado de carregamento. Sem isto, tudo parece instantaneo ate ao
  /// dia em que ha API a serio — e aí a app pisca toda e ha que refazer ecras.
  Future<void> _latency() =>
      Future.delayed(const Duration(milliseconds: 300));

  @override
  Future<List<Category>> fetchAll() async {
    await _latency();

    // Copia primeiro, ordena depois: o .sort() altera a lista onde e chamado,
    // e ordenar _items diretamente era mexer no estado interno sem necessidade.
    final copy = List<Category>.of(_items);
    copy.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return copy;
  }

  @override
  Future<Category> create({
    required String name,
    String color = '#A1A1AA',
    int sortOrder = 0,
  }) async {
    await _latency();

    final created = Category(
      id: _nextId++,          // atribui e avanca, tal como faria o INSERT
      name: name,
      color: color,
      sortOrder: sortOrder,
    );

    _items.add(created);
    return created;              // devolve ja com id, como o contrato promete
  }

  @override
  Future<Category> update(Category category) async {
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