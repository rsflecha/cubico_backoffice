// Corre DEPOIS de `flutter build web`:   dart run tool/cache_bust.dart
//
// Porquê: o alojamento tem um nginx à frente que guarda os .js na cache dele (não liga ao
// Cache-Control do .htaccess, e não o podemos limpar). Depois de publicar, os browsers
// continuavam a receber a versão ANTIGA do main.dart.js e do flutter_bootstrap.js.
//
// Solução: os endereços mudam a cada build — main.dart.js?v=<impressão digital>.
// Um endereço novo nunca está na cache. Só o index.html não fica preso no nginx,
// por isso é por ele que a versão nova entra:
//   index.html → flutter_bootstrap.js?v=… → main.dart.js?v=…
//   index.html → passkeys.js?v=…
// Pode correr-se mais de uma vez: troca a versão que lá estiver.
import 'dart:io';

void main() {
  final web = Directory("build/web");
  final main = File("${web.path}/main.dart.js");
  if (!main.existsSync()) {
    stderr.writeln("Não encontrei ${main.path}. Corre primeiro: flutter build web ...");
    exit(1);
  }
  final version = _fingerprint(main.readAsBytesSync());

  _version(File("${web.path}/flutter_bootstrap.js"), '"mainJsPath":"main.dart.js', '"', version);
  final index = File("${web.path}/index.html");
  _version(index, 'src="flutter_bootstrap.js', '"', version);
  _version(index, 'src="passkeys.js', '"', version);

  stdout.writeln("Versão $version: index.html → flutter_bootstrap.js → main.dart.js, e passkeys.js.");
}

/// Põe "?v=[version]" a seguir a [prefix] (antes de [end]), trocando um "?v=" que já lá esteja.
/// Falha alto se não encontrar: melhor parar do que publicar sem a versão.
void _version(File file, String prefix, String end, String version) {
  final text = file.readAsStringSync();
  final pattern = RegExp("${RegExp.escape(prefix)}(\\?v=[0-9a-f]+)?${RegExp.escape(end)}");
  if (!pattern.hasMatch(text)) {
    stderr.writeln("Não encontrei «$prefix» em ${file.path}. O Flutter mudou o formato?");
    exit(1);
  }
  file.writeAsStringSync(text.replaceFirst(pattern, "$prefix?v=$version$end"));
}

/// FNV-1a de 32 bits, em hex: muda sempre que o ficheiro muda (não precisa de pacotes).
String _fingerprint(List<int> bytes) {
  var hash = 0x811c9dc5;
  for (final b in bytes) {
    hash ^= b;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash.toRadixString(16).padLeft(8, "0");
}
