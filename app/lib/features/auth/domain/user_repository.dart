import 'package:cubico_backoffice/features/auth/domain/app_user.dart';

/// A gestão de quem tem acesso à app (só para o administrador).
abstract interface class UserRepository {
  Future<List<AppUser>> fetchAll();

  /// Cria um utilizador. Com a API, devolve também uma palavra-passe provisória,
  /// que só existe nesta resposta (na base de dados fica só o hash). No modo demo é null.
  Future<({AppUser user, String? temporaryPassword})> create(AppUser draft);

  Future<AppUser> update(AppUser user);

  /// Retira o acesso (com a API, desativa: as encomendas guardam quem as criou).
  Future<void> delete(int id);
}
