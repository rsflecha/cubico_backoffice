// FICHEIRO TEMPORÁRIO — gera as capturas de docs/screenshots/ e é apagado a seguir.
// Desenha a app em memória (sem abrir janelas) a 1920x1080, com as fontes reais.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cubico_backoffice/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

const _out = r'C:\Users\PC\Desktop\CubicoDesign3D\cubico_backoffice\docs\screenshots';
final _fontCache = Platform.environment['CAPTURAS_FONT_CACHE']!;
final _sdkFonts = Platform.environment['CAPTURAS_SDK_FONTS']!;

Future<void> _loadFont(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final f in files) {
    final bytes = File('$_sdkFonts/$f').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

void main() {
  // Os testes trocam o HttpClient por um falso que responde 400; as Google
  // Fonts precisam do verdadeiro (e guardam a cópia na pasta de cache abaixo).
  // (repetido dentro do teste: o binding volta a pôr o falso no início de cada teste)

  testWidgets('capturas', (tester) async {
    HttpOverrides.global = null;
    // path_provider não existe nos testes: aponta a cache das fontes para o scratchpad.
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => _fontCache,
    );
    // Sem isto, ícones e texto sem família aparecem como quadrados.
    await tester.runAsync(() async {
      await _loadFont('MaterialIcons', ['materialicons-regular.otf']);
      await _loadFont('Roboto', [
        'roboto-regular.ttf', 'roboto-medium.ttf', 'roboto-bold.ttf',
      ]);
    });

    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final key = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: key,
      child: const ProviderScope(child: App()),
    ));

    // Espera pelas fontes pedidas pelo ecrã atual e redesenha.
    Future<void> settle() async {
      await tester.pumpAndSettle();
      await tester.runAsync(() => GoogleFonts.pendingFonts());
      await tester.pumpAndSettle();
    }

    Future<void> shot(String name) async {
      await settle();
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 1.0);
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        File('$_out\\$name').writeAsBytesSync(png!.buffer.asUint8List());
      });
    }

    await settle();

    // 1. Produtos → Suporte de auscultadores
    await tester.tap(find.text('Produtos').first);
    await settle();
    await tester.tap(find.text('Suporte de auscultadores').first);
    await shot('produto-custos.png');

    // 2. Encomendas → separador "Todas"
    await tester.tap(find.text('Encomendas').first);
    await settle();
    await tester.tap(find.textContaining('Todas ·').first);
    await shot('encomendas.png');

    // 3. Detalhe da #1042
    await tester.tap(find.textContaining('1042').first);
    await shot('encomenda-detalhe.png');
  });
}
