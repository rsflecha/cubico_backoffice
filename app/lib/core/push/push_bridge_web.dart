import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Na web: chama as funções do `web/push.js` (o `globalContext` é o `window` do browser).
/// Todas devolvem texto JSON; o PushService lê-o.
class PushBridge {
  const PushBridge();

  /// {"state": "unsupported" | "home-screen" | "denied" | "off" | "on", "endpoint": …}
  Future<String> state() => _call("cubicoPushState");

  /// Pede autorização e inscreve o aparelho: {"endpoint", "keys": {"p256dh", "auth"}} ou {"error"}.
  Future<String> enable(String publicKey) => _call("cubicoPushEnable", publicKey);

  /// Esquece a inscrição: {"endpoint": …} (null se não havia).
  Future<String> disable() => _call("cubicoPushDisable");

  Future<String> _call(String name, [String? argument]) async {
    if (!globalContext.has(name)) return '{"state":"unsupported","error":"NotSupportedError"}';
    final promise = argument == null
        ? globalContext.callMethod<JSPromise<JSString>>(name.toJS)
        : globalContext.callMethod<JSPromise<JSString>>(name.toJS, argument.toJS);
    return (await promise.toDart).toDart;
  }
}
