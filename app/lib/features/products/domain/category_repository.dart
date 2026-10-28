import 'category.dart';

/// Contrato de acesso a categorias.
///
/// Os ecras dependem DESTA classe, nunca de uma implementacao concreta.
/// Hoje por tras esta uma lista em memoria; na fatia 11 estara a API em PHP,
/// e nenhum ecra tera de mudar — e esta a unica razao de existir esta classe.
abstract interface class CategoryRepository {
  /// Todas as categorias, ja pela ordem com que devem aparecer na lista.
  ///
  /// Future mesmo em modo demo: quando vier da rede tera de ser assincrono,
  /// e mudar isso mais tarde obrigaria a mexer em todos os sitios que chamam.
  Future<List<Category>> fetchAll();

  /// Cria uma categoria e devolve-a ja com o id.
  ///
  /// Nao recebe um Category porque nesse momento ainda nao ha id — quem o
  /// atribui e a base de dados, no INSERT. Inventar um id: 0 seria uma
  /// mentira que ficava no codigo para sempre.
  ///
  /// Devolve o objeto criado (e nao void) porque sem o id atribuido a app
  /// nao consegue editar nem apagar a categoria a seguir.
  ///
  /// color e sortOrder tem valor por omissao igual ao DEFAULT da tabela:
  /// quem cria depressa nao e obrigado a escolher uma cor.
  Future<Category> create({
    required String name,
    String color = '#A1A1AA',
    int sortOrder = 0,
  });

  /// Altera uma categoria existente e devolve a versao gravada.
  ///
  /// Aqui recebe o objeto inteiro, ao contrario do create: ja tem id, e o id
  /// e justamente o que diz ao servidor qual a linha a alterar.
  ///
  /// Devolve o resultado porque o servidor pode nao gravar exatamente o que
  /// lhe foi enviado — o updated_at muda sozinho, e um dia pode haver
  /// validacoes que corrijam valores. Ficar com o objeto que enviaste e
  /// ficar com uma versao que pode ja nao ser verdade.
  Future<Category> update(Category category);

  /// Apaga a categoria com este id.
  ///
  /// So precisa do id: pedir o objeto inteiro obrigaria quem chama a te-lo
  /// em maos, e numa lista de check-boxes so ha ids.
  ///
  /// Devolve void porque depois de apagada nao ha nada para devolver. Se a
  /// operacao falhar, o erro vem por excecao, nao por valor de retorno.
  Future<void> delete(int id);
}