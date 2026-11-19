import 'dart:convert';

import 'package:cubico_backoffice/core/api/api_client.dart';
import 'package:cubico_backoffice/core/passkeys/passkey_bridge.dart';
import 'package:cubico_backoffice/features/auth/data/api_passkey_repository.dart';
import 'package:cubico_backoffice/features/auth/data/session_storage.dart';
import 'package:cubico_backoffice/features/auth/domain/app_user.dart';
import 'package:cubico_backoffice/features/auth/domain/passkey.dart';
import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:cubico_backoffice/features/auth/presentation/login_screen.dart';
import 'package:cubico_backoffice/features/auth/presentation/passkey_widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

const _rui = AppUser(id: 1, name: "Rui", email: "rui@teste.pt", role: UserRole.admin);

/// Um browser de mentira: responde o que lhe mandarem, e guarda o que recebeu.
class _FakeBridge implements PasskeyBridge {
  _FakeBridge(this.answer);
  String answer;
  final received = <String>[];

  @override
  bool get supported => true;

  @override
  Future<String> create(String optionsJson) async {
    received.add(optionsJson);
    return answer;
  }

  @override
  Future<String> get(String optionsJson) async {
    received.add(optionsJson);
    return answer;
  }
}

/// Uma API de mentira: cada caminho dá uma resposta (estado e corpo), e guarda os pedidos.
Dio _api(Map<String, (int, Object)> routes, List<RequestOptions> log) {
  final dio = Dio(BaseOptions(baseUrl: "http://api.test"));
  dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
    log.add(options);
    final (status, body) = routes[options.path] ?? (404, {"error": "?"});
    final response = Response(requestOptions: options, statusCode: status, data: body);
    if (status >= 400) {
      handler.reject(DioException(requestOptions: options, response: response, type: DioExceptionType.badResponse));
    } else {
      handler.resolve(response);
    }
  }));
  return dio;
}

/// Um repositório de mentira para os ecrãs.
class _FakeRepo implements PasskeyRepository {
  var prepared = 0;
  var signedIn = 0;
  var registered = 0;
  final removed = <int>[];
  PasskeyException? failWith;
  List<Passkey> items = [Passkey(id: 7, label: "iPhone", createdAt: DateTime(2026, 11, 19))];

  @override
  Future<PreparedPasskey> prepareSignIn() async {
    prepared++;
    return PreparedPasskey(challengeId: "c$prepared", optionsJson: "{}");
  }

  String? password;

  @override
  Future<PreparedPasskey> prepareRegister({required String password}) async {
    if (password != "certa") throw const PasskeyException("A palavra-passe está errada.");
    this.password = password;
    return prepareSignIn();
  }

  @override
  Future<AppUser> signIn(PreparedPasskey p, {bool remember = false}) async {
    signedIn++;
    if (failWith != null) throw failWith!;
    return _rui;
  }

  @override
  Future<List<Passkey>> register(PreparedPasskey p) async {
    registered++;
    return items;
  }

  @override
  Future<List<Passkey>> fetchAll() async => items;

  @override
  Future<List<Passkey>> remove(int id) async {
    removed.add(id);
    items = [];
    return items;
  }
}

void main() {
  group("repositório (API + browser)", () {
    final options = {"challenge_id": "abc", "options": {"challenge": "xyz", "rpId": "app.test"}};

    test("entrar: o browser recebe as opções da API, e a API a resposta do browser", () async {
      final log = <RequestOptions>[];
      final tokens = TokenStore();
      final bridge = _FakeBridge(jsonEncode({"id": "cred", "signature": "sig"}));
      final repo = ApiPasskeyRepository(
        _api({
          "/auth/passkeys/login/options": (200, options),
          "/auth/passkeys/login": (200, {"token": "t-1", "user": _rui.toJson()}),
        }, log),
        tokens,
        bridge,
      );
      final prepared = await repo.prepareSignIn();
      expect(prepared.challengeId, "abc");
      final user = await repo.signIn(prepared, remember: true);
      expect(user.id, 1);
      expect(tokens.token, "t-1");
      expect(jsonDecode(bridge.received.single), {"challenge": "xyz", "rpId": "app.test"});
      expect(log.last.data, {"challenge_id": "abc", "remember": true, "id": "cred", "signature": "sig"});
    });

    test("cancelar o Face ID: cancelled, e nem vai à API", () async {
      final log = <RequestOptions>[];
      final repo = ApiPasskeyRepository(_api({}, log), TokenStore(), _FakeBridge('{"error":"NotAllowedError"}'));
      final p = PreparedPasskey(challengeId: "a", optionsJson: "{}");
      await expectLater(repo.signIn(p), throwsA(isA<PasskeyException>().having((e) => e.cancelled, "cancelled", true)));
      expect(log, isEmpty);
    });

    test("a API recusa: mostra a mensagem dela", () async {
      final repo = ApiPasskeyRepository(
        _api({"/auth/passkeys/login": (401, {"error": "Não foi possível entrar com o Face ID. Usa a palavra-passe."})}, []),
        TokenStore(),
        _FakeBridge('{"id":"x"}'),
      );
      await expectLater(
        repo.signIn(PreparedPasskey(challengeId: "a", optionsJson: "{}")),
        throwsA(isA<PasskeyException>().having((e) => e.message, "message", contains("Usa a palavra-passe"))),
      );
    });

    test("ativar outra vez no mesmo aparelho: diz que já está ativo", () async {
      final repo = ApiPasskeyRepository(_api({}, []), TokenStore(), _FakeBridge('{"error":"InvalidStateError"}'));
      await expectLater(
        repo.register(PreparedPasskey(challengeId: "a", optionsJson: "{}")),
        throwsA(isA<PasskeyException>().having((e) => e.message, "message", "Este aparelho já tem o Face ID ativo.")),
      );
    });

    test("o desafio vale 4 minutos (a API dá 5)", () {
      expect(PreparedPasskey(challengeId: "a", optionsJson: "{}").isFresh, isTrue);
      final old = DateTime.now().subtract(const Duration(minutes: 4, seconds: 1));
      expect(PreparedPasskey(challengeId: "a", optionsJson: "{}", fetchedAt: old).isFresh, isFalse);
    });
  });

  group("ecrãs", () {
    Future<_FakeRepo> start(WidgetTester tester, Widget home, {bool available = true}) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final repo = _FakeRepo();
      final router = GoRouter(routes: [
        GoRoute(path: "/", builder: (_, _) => home),
        GoRoute(path: "/dashboard", builder: (_, _) => const Text("dashboard")),
      ]);
      await tester.pumpWidget(ProviderScope(
        overrides: [
          passkeyRepositoryProvider.overrideWithValue(repo),
          passkeysAvailableProvider.overrideWithValue(available),
          sessionStorageProvider.overrideWithValue(MemorySessionStorage()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ));
      await tester.pump();
      return repo;
    }

    testWidgets("login: sem Face ID no aparelho, não há botão", (tester) async {
      await start(tester, const LoginScreen(), available: false);
      expect(find.textContaining("Entrar com "), findsNothing);
    });

    testWidgets("login: o desafio é pedido antes do toque, e o toque entra", (tester) async {
      final repo = await start(tester, const LoginScreen());
      expect(repo.prepared, 1); // já pedido ao abrir o ecrã
      await tester.tap(find.textContaining("Entrar com "));
      await tester.pumpAndSettle();
      expect(repo.prepared, 1, reason: "no toque não se espera pela API");
      expect(repo.signedIn, 1);
      expect(find.text("dashboard"), findsOneWidget);
    });

    testWidgets("login: se falhar, mostra porquê e prepara outro desafio", (tester) async {
      final repo = await start(tester, const LoginScreen());
      repo.failWith = const PasskeyException("Não foi possível entrar com o Face ID. Usa a palavra-passe.");
      await tester.tap(find.textContaining("Entrar com "));
      await tester.pumpAndSettle();
      expect(find.text("Não foi possível entrar com o Face ID. Usa a palavra-passe."), findsOneWidget);
      expect(repo.prepared, 2);
      expect(find.text("dashboard"), findsNothing);
    });

    testWidgets("definições: lista o aparelho, ativa e remove", (tester) async {
      final repo = await start(tester, const Scaffold(body: SingleChildScrollView(child: PasskeysTile())));
      await tester.pumpAndSettle();
      expect(find.text("iPhone"), findsOneWidget);
      expect(find.text("Ativado a 19/11/2026"), findsOneWidget);

      // passo 1: a palavra-passe (errada, depois certa)
      await tester.tap(find.text("Ativar"));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), "errada");
      await tester.tap(find.text("Continuar"));
      await tester.pumpAndSettle();
      expect(find.text("A palavra-passe está errada."), findsOneWidget);
      expect(repo.registered, 0);
      await tester.enterText(find.byType(TextField), "certa");
      await tester.tap(find.text("Continuar"));
      await tester.pumpAndSettle();
      // passo 2: um toque à parte abre o Face ID
      expect(repo.registered, 0);
      await tester.tap(find.widgetWithText(FilledButton, "Usar impressão digital"));
      await tester.pumpAndSettle();
      expect(repo.registered, 1);
      expect(find.textContaining("ativo neste aparelho."), findsOneWidget);

      await tester.tap(find.text("Remover"));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, "Remover")); // confirmar
      await tester.pumpAndSettle();
      expect(repo.removed, [7]);
      expect(find.text("iPhone"), findsNothing);
    });
  });
}
