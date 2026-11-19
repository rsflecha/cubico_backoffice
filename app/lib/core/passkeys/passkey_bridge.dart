/// A ponte para o Face ID / impressão digital do browser (passkeys).
///
/// Na web usa o `web/passkeys.js`; nas outras plataformas (Windows, Android instalado)
/// não há passkeys nesta versão e o [PasskeyBridge] diz que não é suportado.
/// O "if (dart.library.js_interop)" escolhe o ficheiro certo ao compilar.
library;

export 'package:cubico_backoffice/core/passkeys/passkey_bridge_stub.dart'
    if (dart.library.js_interop) 'package:cubico_backoffice/core/passkeys/passkey_bridge_web.dart';
