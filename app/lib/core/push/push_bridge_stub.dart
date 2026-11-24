/// Fora da web: sem avisos (a app de Windows e a APK não os têm).
class PushBridge {
  const PushBridge();

  Future<String> state() async => '{"state":"unsupported"}';

  Future<String> enable(String publicKey) async => '{"error":"NotSupportedError"}';

  Future<String> disable() async => '{"endpoint":null}';
}
