import 'package:cubico_backoffice/features/auth/domain/app_user.dart';

/// A gestão de quem tem acesso à app (só para o administrador).
abstract interface class UserRepository {
  Future<List<AppUser>> fetchAll();
  Future<AppUser> create(AppUser draft);
  Future<AppUser> update(AppUser user);
  Future<void> delete(int id);
}