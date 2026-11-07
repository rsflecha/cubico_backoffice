import 'package:cubico_backoffice/features/auth/domain/app_user.dart';
import 'package:cubico_backoffice/features/auth/domain/auth_repository.dart';

/// Contas de demonstração. As palavras-passe estão aqui de propósito, porque é só a demo:
/// na API, as palavras-passe ficam guardadas cifradas (bcrypt) e nunca saem do servidor.
class DemoAuthRepository implements AuthRepository {
  static const _accounts = {
    "admin@demo.pt": (
    password: "demo1234",
    user: AppUser(id: 1, name: "Rui", email: "admin@demo.pt", role: UserRole.admin),
    ),
    "loja@demo.pt": (
    password: "demo1234",
    user: AppUser(id: 2, name: "Ana", email: "loja@demo.pt", role: UserRole.staff),
    ),
  };

  @override
  Future<AppUser> signIn({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final account = _accounts[email.trim().toLowerCase()];
    if (account == null || account.password != password) {
      throw const AuthException("Email ou palavra-passe errados.");
    }
    return account.user;
  }

  @override
  Future<void> signOut() async {}
}