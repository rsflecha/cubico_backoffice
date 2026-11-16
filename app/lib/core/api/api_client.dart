import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// O endereço da API. Por omissão, a API no teu PC.
/// Para outro servidor: flutter run --dart-define=API_URL=https://...
const apiUrl = String.fromEnvironment(
  "API_URL",
  defaultValue: "http://localhost:8080/api",
);

/// Guarda o token de sessão enquanto a app está aberta.
class TokenStore {
  String? token;

  /// Chamado quando a API recusa o token (401): a sessão expirou, ou o acesso foi retirado.
  /// Quem o preenche é a sessão (o SessionNotifier); assim esta pasta "core" não precisa
  /// de saber nada da sessão.
  void Function(String message)? onExpired;
}

/// A caixinha do token: uma só para a app inteira.
final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());

/// O Dio da app: o endereço base, os tempos de espera e o token em todos os pedidos.
final dioProvider = Provider<Dio>((ref) {
  final tokens = ref.watch(tokenStoreProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: apiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      contentType: Headers.jsonContentType,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      // corre antes de CADA pedido: junta o token, se houver sessão
      onRequest: (options, handler) {
        final token = tokens.token;
        if (token != null) {
          options.headers["Authorization"] = "Bearer $token";
        }
        handler.next(options); // segue para o pedido
      },
      // corre quando um pedido falha: um 401 quer dizer que a sessão já não vale.
      // Antes, a app mostrava o erro em cada ecrã e continuava "lá dentro".
      // O login fica de fora: aí, 401 é só "email ou palavra-passe errados".
      onError: (error, handler) {
        final isLogin = error.requestOptions.path.endsWith("/auth/login");
        if (error.response?.statusCode == 401 && !isLogin && tokens.token != null) {
          final body = error.response?.data;
          tokens.onExpired?.call(
            body is Map && body["error"] is String
                ? body["error"] as String
                : "A sessão expirou. Entra outra vez.",
          );
        }
        handler.next(error); // o erro segue, para quem fez o pedido também o saber
      },
    ),
  );

  return dio;
});
