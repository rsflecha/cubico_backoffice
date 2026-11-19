/// Fora da web: sem passkeys (a app de Windows e a APK ainda não as têm).
class PasskeyBridge {
  const PasskeyBridge();

  bool get supported => false;

  /// Ativar: devolve o JSON da resposta do aparelho, ou {"error": "..."}.
  Future<String> create(String optionsJson) async => '{"error":"NotSupportedError"}';

  /// Entrar: devolve o JSON da assinatura do aparelho, ou {"error": "..."}.
  Future<String> get(String optionsJson) async => '{"error":"NotSupportedError"}';
}
