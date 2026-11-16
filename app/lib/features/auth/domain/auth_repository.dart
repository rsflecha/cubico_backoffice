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
  /// Com [remember], a API dá um token de 30 dias em vez de 12 horas.
  Future<AppUser> signIn({
    required String email,
    required String password,
    bool remember = false,
  });

  /// Quem sou eu, segundo a API (o nome e o papel atuais).
  Future<AppUser> me();

  /// Muda a própria palavra-passe. Lança AuthException com a mensagem da API
  /// ("A palavra-passe atual está errada.", …). O token passa a ser o novo.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    bool remember = false,
  });

  Future<void> signOut();
}
