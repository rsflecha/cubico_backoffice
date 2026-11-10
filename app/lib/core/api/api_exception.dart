import 'package:dio/dio.dart';

/// Um erro de um pedido à API, com uma mensagem em português para mostrar ao utilizador.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode; // 401, 403, 404, 409… (null = nem chegou a haver resposta)

  /// Transforma um erro do Dio numa mensagem que se pode mostrar.
  factory ApiException.fromDio(DioException e) {
    final response = e.response;
    if (response == null) {
      return const ApiException(
        "Não foi possível ligar ao servidor. Confirma a ligação à internet.",
      );
    }
    final body = response.data;
    if (body is Map && body["error"] is String) {
      // a mensagem que a nossa API mandou
      return ApiException(body["error"] as String, statusCode: response.statusCode);
    }
    return ApiException(
      "Ocorreu um erro no servidor (código ${response.statusCode}).",
      statusCode: response.statusCode,
    );
  }

  @override
  String toString() => message;
}

/// Faz um pedido à API e transforma qualquer erro do Dio num ApiException.
/// Assim, nenhum repositório tem de repetir o try/catch.
Future<T> apiCall<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on DioException catch (e) {
    throw ApiException.fromDio(e);
  }
}
