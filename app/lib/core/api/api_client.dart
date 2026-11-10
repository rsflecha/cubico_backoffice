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

  // corre antes de CADA pedido: junta o token, se houver sessão
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = tokens.token;
        if (token != null) {
          options.headers["Authorization"] = "Bearer $token";
        }
        handler.next(options); // segue para o pedido
      },
    ),
  );

  return dio;
});