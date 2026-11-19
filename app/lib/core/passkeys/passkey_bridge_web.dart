import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Na web: chama as funções do `web/passkeys.js` (o `globalContext` é o `window` do browser).
class PasskeyBridge {
  const PasskeyBridge();

  /// O browser sabe usar passkeys? (e o passkeys.js carregou?)
  bool get supported {
    if (!globalContext.has("cubicoPasskeysSupported")) return false;
    return globalContext.callMethod<JSBoolean>("cubicoPasskeysSupported".toJS).toDart;
  }

  /// Ativar: devolve o JSON da resposta do aparelho, ou {"error": "..."}.
  Future<String> create(String optionsJson) => _call("cubicoPasskeyCreate", optionsJson);

  /// Entrar: devolve o JSON da assinatura do aparelho, ou {"error": "..."}.
  Future<String> get(String optionsJson) => _call("cubicoPasskeyGet", optionsJson);

  Future<String> _call(String name, String optionsJson) async {
    if (!globalContext.has(name)) return '{"error":"NotSupportedError"}';
    final promise = globalContext.callMethod<JSPromise<JSString>>(name.toJS, optionsJson.toJS);
    return (await promise.toDart).toDart;
  }
}
