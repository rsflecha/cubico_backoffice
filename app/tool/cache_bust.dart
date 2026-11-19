// Corre DEPOIS de `flutter build web`:   dart run tool/cache_bust.dart
//
// Porquê: o alojamento tem um nginx à frente que guarda o main.dart.js na cache dele
// (não liga ao Cache-Control do .htaccess, e não o podemos limpar). Depois de publicar,
// os browsers continuavam a receber a versão ANTIGA durante muito tempo.
//
// Solução: o endereço muda a cada build — main.dart.js?v=<impressão digital do ficheiro>.
// Um endereço novo nunca está na cache. O index.html e o flutter_bootstrap.js não ficam
// presos na cache do nginx, por isso são eles que levam o endereço novo.
import 'dart:io';

void main() {
  final web = Directory("build/web");
  final main = File("${web.path}/main.dart.js");
  if (!main.existsSync()) {
    stderr.writeln("Não encontrei ${main.path}. Corre primeiro: flutter build web ...");
    exit(1);
  }
  final version = _fingerprint(main.readAsBytesSync());

  // 1. o flutter_bootstrap.js: o caminho do main.dart.js
  _replace(
    File("${web.path}/flutter_bootstrap.js"),
    '"mainJsPath":"main.dart.js"',
    '"mainJsPath":"main.dart.js?v=$version"',
  );
  // 2. o index.html: o passkeys.js (Face ID)
  _replace(File("${web.path}/index.html"), 'src="passkeys.js"', 'src="passkeys.js?v=$version"');

  stdout.writeln("Versão $version nos endereços do main.dart.js e do passkeys.js.");
}

/// Troca [from] por [to]. Falha alto se não encontrar: melhor parar do que publicar sem a versão.
void _replace(File file, String from, String to) {
  final text = file.readAsStringSync();
  if (!text.contains(from)) {
    stderr.writeln("Não encontrei «$from» em ${file.path}. O Flutter mudou o formato?");
    exit(1);
  }
  file.writeAsStringSync(text.replaceFirst(from, to));
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
