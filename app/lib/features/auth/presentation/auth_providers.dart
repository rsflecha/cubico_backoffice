import 'package:cubico_backoffice/features/auth/data/demo_auth_repository.dart';
import 'package:cubico_backoffice/features/auth/data/demo_user_repository.dart';
import 'package:cubico_backoffice/features/auth/domain/app_user.dart';
import 'package:cubico_backoffice/features/auth/domain/auth_repository.dart';
import 'package:cubico_backoffice/features/auth/domain/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Qual é o repositório de autenticação.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return DemoAuthRepository();
});

/// Quem tem sessão iniciada. null = ninguém.
class SessionNotifier extends Notifier<AppUser?> {
  @override
  AppUser? build() => null;

  /// Entra com email e palavra-passe. Lança AuthException se falhar.
  Future<void> signIn(String email, String password) async {
    state = await ref.read(authRepositoryProvider).signIn(email: email, password: password);
  }

  /// Entra diretamente com uma conta demo (o botão "Explorar em modo demo").
  void signInAs(AppUser user) {
    state = user;
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = null;
  }
}

/// A sessão: quem está a usar a app.
final sessionProvider = NotifierProvider<SessionNotifier, AppUser?>(SessionNotifier.new);

/// Qual é o repositório dos utilizadores.
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return DemoUserRepository();
});

/// Quem tem acesso à app.
final usersProvider = FutureProvider<List<AppUser>>((ref) {
  return ref.watch(userRepositoryProvider).fetchAll();
});