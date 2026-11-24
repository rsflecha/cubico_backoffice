import 'dart:convert';

import 'package:cubico_backoffice/core/api/api_exception.dart';
import 'package:cubico_backoffice/core/push/push_bridge.dart';
import 'package:dio/dio.dart';

/// Em que pé estão os avisos neste aparelho.
enum PushState {
  unsupported, // este browser (ou a app de Windows/APK) não sabe receber avisos
  homeScreen, // iPhone/iPad: só funciona com o site no ecrã principal
  denied, // o aparelho bloqueou os avisos deste site
  off,
  on,
}

/// Os avisos de encomendas novas: o browser (PushBridge) e a API (/api/push/…).
class PushService {
  /// [_bridge]: nos testes, um browser de mentira.
  PushService(this._dio, [this._bridge = const PushBridge()]);

  final Dio _dio;
  final PushBridge _bridge;

  Future<PushState> state() async {
    final data = jsonDecode(await _bridge.state()) as Map<String, dynamic>;
    return switch (data["state"]) {
      "home-screen" => PushState.homeScreen,
      "denied" => PushState.denied,
      "off" => PushState.off,
      "on" => PushState.on,
      _ => PushState.unsupported,
    };
  }

  /// A chave pública da loja (pede-se ANTES do toque em "Ligar": o Safari só mostra o
  /// pedido de autorização logo a seguir a um toque, sem esperas pelo meio).
  Future<String> publicKey() => apiCall(() async {
        final response = await _dio.get<Map<String, dynamic>>("/push/key");
        return response.data!["public_key"] as String;
      });

  /// Liga os avisos: o browser pede autorização e inscreve-se; a API guarda o aparelho.
  /// Devolve false se a pessoa recusou a autorização.
  Future<bool> enable(String publicKey) async {
    final data = jsonDecode(await _bridge.enable(publicKey)) as Map<String, dynamic>;
    if (data["error"] == "denied") return false;
    if (data["error"] != null || data["endpoint"] == null) {
      throw ApiException("O browser não conseguiu ligar os avisos (${data["error"] ?? "sem resposta"}).");
    }
    await apiCall(() => _dio.post<void>("/push/subscriptions", data: data));
    return true;
  }

  /// Desliga os avisos neste aparelho (no browser e na API).
  Future<void> disable() async {
    final data = jsonDecode(await _bridge.disable()) as Map<String, dynamic>;
    final endpoint = data["endpoint"];
    if (endpoint == null) return;
    await apiCall(() => _dio.delete<void>("/push/subscriptions", data: {"endpoint": endpoint}));
  }

  /// Envia um aviso de teste aos aparelhos de quem está com sessão. Devolve quantos chegaram.
  Future<int> sendTest() => apiCall(() async {
        final response = await _dio.post<Map<String, dynamic>>("/push/test");
        return (response.data!["sent"] as num).toInt();
      });
}
