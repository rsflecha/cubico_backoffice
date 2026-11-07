import 'package:cubico_backoffice/features/auth/domain/app_user.dart';

/// Um erro de autenticação, com uma mensagem para mostrar ao utilizador.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract interface class AuthRepository {
  /// Entra com email e palavra-passe. Lança AuthException se estiverem errados.
  Future<AppUser> signIn({required String email, required String password});

  Future<void> signOut();
}