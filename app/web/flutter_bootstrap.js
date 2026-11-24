{{flutter_js}}
{{flutter_build_config}}

// O nosso arranque do Flutter (o "flutter build web" usa este ficheiro em vez do dele).
// A diferença: SEM o service worker do Flutter. Esse está obsoleto e, ao ativar, apaga-se a si
// próprio — e há só um service worker por site, por isso apagava também o dos avisos (push_sw.js).
_flutter.loader.load();
