/// A ponte para os avisos do browser (Web Push).
///
/// Na web usa o `web/push.js`; nas outras plataformas (Windows, Android instalado) não há
/// avisos nesta versão e o [PushBridge] diz "unsupported".
library;

export 'package:cubico_backoffice/core/push/push_bridge_stub.dart'
    if (dart.library.js_interop) 'package:cubico_backoffice/core/push/push_bridge_web.dart';
