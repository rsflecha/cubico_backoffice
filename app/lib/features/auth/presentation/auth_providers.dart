import 'package:cubico_backoffice/core/api/api_client.dart';
import 'package:cubico_backoffice/features/auth/data/api_auth_repository.dart';
import 'package:cubico_backoffice/features/auth/data/demo_user_repository.dart';
import 'package:cubico_backoffice/features/auth/domain/app_user.dart';
import 'package:cubico_backoffice/features/auth/domain/auth_repository.dart';
import 'package:cubico_backoffice/features/auth/domain/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Qual é o repositório de autenticação: a API a sério.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ApiAuthRepository(ref.watch(dioProvider), ref.watch(tokenStoreProvider));
});

/// O modo da sessão: true = modo demo (dados de exemplo, sem servidor);
/// false = sessão a sério, com os dados da API.
class DemoModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) {
    state = value;
  }
}

/// Em que modo está a app. Cada placa de repositório escolhe o Demo ou o Api conforme isto.
final demoModeProvider = NotifierProvider<DemoModeNotifier, bool>(DemoModeNotifier.new);

/// Quem tem sessão iniciada. null = ninguém.
class SessionNotifier extends Notifier<AppUser?> {
  @override
  AppUser? build() => null;

  /// Entra com email e palavra-passe. Lança AuthException se falhar.
  Future<void> signIn(String email, String password) async {
    final user = await ref.read(authRepositoryProvider).signIn(email: email, password: password);
    ref.read(demoModeProvider.notifier).set(false); // sessão a sério: os dados vêm da API
    state = user;
  }

  /// Entra diretamente com uma conta demo (o botão "Explorar em modo demo").
  void signInAs(AppUser user) {
    ref.read(demoModeProvider.notifier).set(true); // modo demo: os dados de exemplo
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