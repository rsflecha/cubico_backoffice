import 'dart:io';

import 'package:cubico_backoffice/app/app.dart';
import 'package:cubico_backoffice/app/router.dart';
import 'package:cubico_backoffice/features/auth/domain/app_user.dart';
import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

/// Varrimento do "responsivo": a app inteira (modo demo), cada ecrã em vários tamanhos.
/// Apanha o que transborda (as faixas amarelas e pretas) e outros erros de desenho,
/// que nos testes normais passam despercebidos porque correm num ecrã grande.

class _Demo extends DemoModeNotifier {
  @override
  bool build() => true;
}

class _Admin extends SessionNotifier {
  @override
  AppUser? build() => const AppUser(id: 1, name: "Rui", email: "rui@teste.pt", role: UserRole.admin);
}

class _Staff extends SessionNotifier {
  @override
  AppUser? build() => const AppUser(id: 2, name: "Sara", email: "sara@teste.pt", role: UserRole.staff);
}

const _sizes = {
  "telemóvel pequeno 320×640": Size(320, 640),
  "iPhone SE 375×667": Size(375, 667),
  "iPhone 390×844": Size(390, 844),
  "iPhone deitado 844×390": Size(844, 390),
  "iPad ao alto 768×1024": Size(768, 1024),
  "iPad deitado 1024×768": Size(1024, 768),
  "portátil 1366×768": Size(1366, 768),
  "monitor 1920×1080": Size(1920, 1080),
};

const _adminRoutes = [
  "/dashboard",
  "/orders",
  "/orders/new",
  "/orders/1",
  "/orders/2",
  "/production",
  "/products",
  "/products/new",
  "/products/1",
  "/customers",
  "/customers/new",
  "/customers/1",
  "/customers/1/edit",
  "/costs",
  "/settings",
];

const _staffRoutes = ["/dashboard", "/orders", "/orders/1", "/production", "/products", "/products/1"];

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 400));
  }
}

/// Percorre [routes] num tamanho e devolve "rota: problema" para cada erro de desenho.
Future<List<String>> _scan(WidgetTester tester, Size size, Notifier<AppUser?> Function() session,
    List<String> routes) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final problems = <String>[];
  var route = "(arranque)";
  final original = FlutterError.onError;
  FlutterError.onError = (details) {
    final text = details.exceptionAsString();
    if (text.contains("google_fonts") || text.contains("Failed to load font")) return; // sem rede nos testes
    final first = text.split("\n").first;
    // o widget onde aconteceu (a "RenderFlex" e o sítio no código ajudam a encontrar)
    final where = details.context?.toDescription() ?? "";
    final line = RegExp(r"file:///[^\s)]*lib/([^\s):]+:\d+)").firstMatch(details.toString())?.group(1) ?? "";
    problems.add("$route  →  $first ${where.isEmpty ? "" : "[$where]"} ${line.isEmpty ? "" : "($line)"}");
  };
  try {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        demoModeProvider.overrideWith(_Demo.new),
        sessionProvider.overrideWith(session as SessionNotifier Function()),
      ],
      child: const App(),
    ));
    await _settle(tester);
    final container = ProviderScope.containerOf(tester.element(find.byType(App)));
    for (final r in routes) {
      route = r;
      container.read(routerProvider).go(r);
      await _settle(tester);
    }
  } finally {
    FlutterError.onError = original;
  }
  // o mesmo problema repete-se a cada frame: fica uma vez
  return problems.toSet().toList();
}

/// Carrega as fontes verdadeiras da app (Manrope, Poppins, JetBrains Mono) a partir de test/fonts/.
///
/// Sem isto, os testes desenham com a fonte de testes do Flutter, onde cada letra é um quadrado
/// da largura do tamanho da letra: os textos saem muito mais largos do que na app e o varrimento
/// acusa transbordos que não existem.
///
/// O google_fonts procura cada estilo por um nome "Família_peso": "Poppins_regular", "Poppins_600"…
/// e NÃO cai no nome simples da família (medido: a fonte de testes ganha). Por isso regista-se cada
/// peso com esse nome exato. A Manrope e a JetBrains Mono são variáveis (um ficheiro para todos os
/// pesos): servem para todos os nomes, mas podem não engrossar no negrito — larguras aproximadas.
Future<void> _loadRealFonts() async {
  // o ficheiro que serve a cada peso (100 a 900)
  String poppins(int w) => w <= 400
      ? "Poppins-Regular.ttf"
      : w == 500
          ? "Poppins-Medium.ttf"
          : w == 600
              ? "Poppins-SemiBold.ttf"
              : "Poppins-Bold.ttf";
  final families = <String, String Function(int)>{
    "Poppins": poppins,
    "Manrope": (_) => "Manrope-Variable.ttf",
    "JetBrainsMono": (_) => "JetBrainsMono-Variable.ttf",
  };
  for (final family in families.entries) {
    for (var w = 100; w <= 900; w += 100) {
      // o google_fonts chama "regular" ao 400
      final loader = FontLoader("${family.key}_${w == 400 ? "regular" : w}");
      final bytes = File("test/fonts/${family.value(w)}").readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
      await loader.load();
    }
  }
  // sem rede nos testes: não tentar ir buscar à internet (cai logo nas fontes carregadas acima)
  GoogleFonts.config.allowRuntimeFetching = false;
}

void main() {
  setUpAll(_loadRealFonts);

  for (final entry in _sizes.entries) {
    testWidgets("administrador · ${entry.key}", (tester) async {
      final problems = await _scan(tester, entry.value, _Admin.new, _adminRoutes);
      // ignore: avoid_print
      print("\n### administrador · ${entry.key}: ${problems.length} problema(s)\n${problems.join("\n")}");
      // falha com problemas: antes só os escrevia e o teste dava verde (erro mudo)
      expect(problems, isEmpty);
    });
  }
  for (final name in ["iPhone 390×844", "iPad ao alto 768×1024"]) {
    testWidgets("colaborador · $name", (tester) async {
      final problems = await _scan(tester, _sizes[name]!, _Staff.new, _staffRoutes);
      // ignore: avoid_print
      print("\n### colaborador · $name: ${problems.length} problema(s)\n${problems.join("\n")}");
      expect(problems, isEmpty);
    });
  }
}
