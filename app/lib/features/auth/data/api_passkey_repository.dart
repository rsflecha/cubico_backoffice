import 'dart:convert';

import 'package:cubico_backoffice/core/api/api_client.dart';
import 'package:cubico_backoffice/core/api/api_exception.dart';
import 'package:cubico_backoffice/core/passkeys/passkey_bridge.dart';
import 'package:cubico_backoffice/features/auth/domain/app_user.dart';
import 'package:cubico_backoffice/features/auth/domain/passkey.dart';
import 'package:dio/dio.dart';

/// As passkeys a sério: a API dá os desafios e confere; o browser trata do Face ID.
class ApiPasskeyRepository implements PasskeyRepository {
  /// [_bridge]: nos testes, um browser de mentira.
  ApiPasskeyRepository(this._dio, this._tokens, [this._bridge = const PasskeyBridge()]);

  final Dio _dio;
  final TokenStore _tokens;
  final PasskeyBridge _bridge;

  @override
  Future<PreparedPasskey> prepareSignIn() => _prepare("/auth/passkeys/login/options", const {});

  @override
  Future<PreparedPasskey> prepareRegister({required String password}) =>
      _prepare("/auth/passkeys/register/options", {"password": password});

  @override
  Future<AppUser> signIn(PreparedPasskey prepared, {bool remember = false}) async {
    final answer = _decode(await _bridge.get(prepared.optionsJson), creating: false);
    final data = await _post("/auth/passkeys/login", {
      "challenge_id": prepared.challengeId,
      "remember": remember,
      ...answer,
    });
    _tokens.token = data["token"] as String; // o "bilhete" para os próximos pedidos
    return AppUser.fromJson(data["user"] as Map<String, dynamic>);
  }

  @override
  Future<List<Passkey>> register(PreparedPasskey prepared) async {
    final answer = _decode(await _bridge.create(prepared.optionsJson), creating: true);
    final data = await _post("/auth/passkeys/register", {"challenge_id": prepared.challengeId, ...answer});
    return _list(data);
  }

  @override
  Future<List<Passkey>> fetchAll() => apiCall(() async {
        final response = await _dio.get<Map<String, dynamic>>("/auth/passkeys");
        return _list(response.data!);
      });

  @override
  Future<List<Passkey>> remove(int id) => apiCall(() async {
        final response = await _dio.delete<Map<String, dynamic>>("/auth/passkeys/$id");
        return _list(response.data!);
      });

  Future<PreparedPasskey> _prepare(String path, Map<String, dynamic> body) async {
    final data = await _post(path, body);
    return PreparedPasskey(
      challengeId: data["challenge_id"] as String,
      optionsJson: jsonEncode(data["options"]),
    );
  }

  /// Um POST que, se falhar, lança PasskeyException com a mensagem da API.
  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: body);
      return response.data!;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data["error"] is String) throw PasskeyException(data["error"] as String);
      throw PasskeyException(ApiException.fromDio(e).message);
    }
  }

  /// A resposta do browser. Um {"error": …} passa a uma mensagem em português.
  Map<String, dynamic> _decode(String json, {required bool creating}) {
    final data = jsonDecode(json) as Map<String, dynamic>;
    final error = data["error"];
    if (error == null) return data;
    throw switch (error) {
      // cancelou, o tempo acabou, ou o Safari não deixou (não foi logo a seguir ao toque)
      "NotAllowedError" => const PasskeyException("Cancelado. Toca outra vez para tentar.", cancelled: true),
      "InvalidStateError" when creating => const PasskeyException("Este aparelho já tem o Face ID ativo."),
      "NotSupportedError" => const PasskeyException("Este aparelho não tem Face ID nem impressão digital."),
      _ => const PasskeyException("O aparelho não conseguiu usar o Face ID. Usa a palavra-passe."),
    };
  }

  List<Passkey> _list(Map<String, dynamic> data) => [
        for (final item in data["passkeys"] as List) Passkey.fromJson(item as Map<String, dynamic>),
      ];
}
