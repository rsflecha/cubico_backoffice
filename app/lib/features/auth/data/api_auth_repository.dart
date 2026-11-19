import 'package:cubico_backoffice/core/api/api_client.dart';
import 'package:cubico_backoffice/core/api/api_exception.dart';
import 'package:cubico_backoffice/features/auth/domain/app_user.dart';
import 'package:cubico_backoffice/features/auth/domain/auth_repository.dart';
import 'package:dio/dio.dart';

/// O login a sério: pergunta à API.
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._dio, this._tokens);

  final Dio _dio;
  final TokenStore _tokens;

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
    bool remember = false,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        "/auth/login",
        data: {"email": email.trim(), "password": password, "remember": remember},
      );
      final data = response.data!;
      _tokens.token = data["token"] as String; // guarda o "bilhete" para os próximos pedidos
      return AppUser.fromJson(data["user"] as Map<String, dynamic>);
    } on DioException catch (e) {
      // 401: email ou palavra-passe errados; 429: demasiadas tentativas → a mensagem que a API mandou
      final status = e.response?.statusCode;
      if (status == 401 || status == 429) {
        final body = e.response?.data;
        final message = body is Map && body["error"] is String
            ? body["error"] as String
            : "Email ou palavra-passe errados.";
        throw AuthException(message);
      }
      // outro problema: a API desligada, sem internet…
      throw const AuthException(
        "Não foi possível ligar ao servidor. Confirma que a API está a correr.",
      );
    }
  }

  @override
  Future<AppUser> me() => apiCall(() async {
    final response = await _dio.get<Map<String, dynamic>>("/auth/me");
    return AppUser.fromJson(response.data!["user"] as Map<String, dynamic>);
  });

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    bool remember = false,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        "/auth/password",
        data: {
          "current_password": currentPassword,
          "new_password": newPassword,
          "remember": remember,
        },
      );
      // o token antigo deixou de valer na API: passa a usar o novo
      _tokens.token = response.data!["token"] as String;
    } on DioException catch (e) {
      throw AuthException(ApiException.fromDio(e).message);
    }
  }

  @override
  Future<void> signOut() async {
    _tokens.token = null; // sem token, a API deixa de aceitar os pedidos
  }
}
