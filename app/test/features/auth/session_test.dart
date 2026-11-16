import 'package:cubico_backoffice/core/api/api_client.dart';
import 'package:cubico_backoffice/features/auth/data/session_storage.dart';
import 'package:cubico_backoffice/features/auth/domain/app_user.dart';
import 'package:cubico_backoffice/features/auth/domain/auth_repository.dart';
import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _rui = AppUser(id: 1, name: "Rui", email: "rui@teste.pt", role: UserRole.admin);

/// Faz de API: entra sempre, e põe um token na caixinha (como a verdadeira).
class _FakeAuth implements AuthRepository {
  _FakeAuth(this._tokens);
  final TokenStore _tokens;
  AppUser meResult = _rui;

  @override
  Future<AppUser> signIn({required String email, required String password, bool remember = false}) async {
    _tokens.token = remember ? "token-30-dias" : "token-12-horas";
    return _rui;
  }

  @override
  Future<AppUser> me() async => meResult;

  @override
  Future<void> changePassword({required String currentPassword, required String newPassword, bool remember = false}) async {
    _tokens.token = "token-novo";
  }

  @override
  Future<void> signOut() async => _tokens.token = null;
}

/// Uma app "de papel": os providers, com a API falsa e o armazenamento dado.
ProviderContainer _app(SessionStorage storage, {AppUser? meResult}) {
  final tokens = TokenStore();
  final auth = _FakeAuth(tokens)..meResult = meResult ?? _rui;
  final container = ProviderContainer(overrides: [
    tokenStoreProvider.overrideWithValue(tokens),
    authRepositoryProvider.overrideWithValue(auth),
    sessionStorageProvider.overrideWithValue(storage),
  ]);
  addTearDown(container.dispose);
  return container;
}

void main() {
  test("com «Manter sessão», a sessão fica guardada e volta ao reabrir a app", () async {
    final storage = MemorySessionStorage();
    final first = _app(storage);
    await first.read(sessionProvider.notifier).signIn("rui@teste.pt", "x", remember: true);
    expect(storage.read()?.token, "token-30-dias");

    // "reabrir": outra app, o mesmo armazenamento
    final second = _app(storage);
    second.read(sessionProvider.notifier).restore();
    expect(second.read(sessionProvider), _rui);
    expect(second.read(tokenStoreProvider).token, "token-30-dias");
  });

  test("sem «Manter sessão», nada fica guardado (e apaga o que houvesse)", () async {
    final storage = MemorySessionStorage();
    await storage.save("token-antigo", _rui);
    final app = _app(storage);
    await app.read(sessionProvider.notifier).signIn("rui@teste.pt", "x");
    expect(storage.read(), isNull);
  });

  test("ao reabrir, o papel atual vem da API (passou a colaborador)", () async {
    final storage = MemorySessionStorage();
    await storage.save("token-30-dias", _rui);
    final staff = _rui.copyWith(role: UserRole.staff);
    final app = _app(storage, meResult: staff);
    app.read(sessionProvider.notifier).restore();
    await Future<void>.delayed(Duration.zero); // deixa a confirmação em segundo plano acabar
    expect(app.read(sessionProvider)?.role, UserRole.staff);
    expect(storage.read()?.user.role, UserRole.staff);
  });

  test("um 401 termina a sessão, apaga a guardada e explica porquê", () async {
    final storage = MemorySessionStorage();
    final app = _app(storage);
    await app.read(sessionProvider.notifier).signIn("rui@teste.pt", "x", remember: true);

    // o que o interceptor do Dio faz quando a API responde 401
    app.read(tokenStoreProvider).onExpired!("Já não tens acesso a esta loja.");

    expect(app.read(sessionProvider), isNull);
    expect(app.read(tokenStoreProvider).token, isNull);
    expect(storage.read(), isNull);
    expect(app.read(loginMessageProvider), "Já não tens acesso a esta loja.");
  });

  test("entrar outra vez apaga a mensagem do login", () async {
    final app = _app(MemorySessionStorage());
    app.read(sessionProvider); // liga a sessão ao interceptor
    app.read(loginMessageProvider.notifier).set("A sessão expirou. Entra outra vez.");
    await app.read(sessionProvider.notifier).signIn("rui@teste.pt", "x");
    expect(app.read(loginMessageProvider), isNull);
  });

  test("no modo demo, um 401 não termina a sessão (a demo não fala com a API)", () {
    final app = _app(MemorySessionStorage());
    app.read(sessionProvider.notifier).signInAs(_rui);
    app.read(tokenStoreProvider).onExpired!("A sessão expirou. Entra outra vez.");
    expect(app.read(sessionProvider), _rui);
  });

  test("mudar a palavra-passe guarda o token novo, se a sessão for para manter", () async {
    final storage = MemorySessionStorage();
    final app = _app(storage);
    await app.read(sessionProvider.notifier).signIn("rui@teste.pt", "x", remember: true);
    await app.read(sessionProvider.notifier).changePassword("x", "nova-palavra");
    expect(storage.read()?.token, "token-novo");
    expect(app.read(sessionProvider), _rui); // continua dentro
  });

  test("terminar sessão apaga a sessão guardada", () async {
    final storage = MemorySessionStorage();
    final app = _app(storage);
    await app.read(sessionProvider.notifier).signIn("rui@teste.pt", "x", remember: true);
    await app.read(sessionProvider.notifier).signOut();
    expect(storage.read(), isNull);
    expect(app.read(sessionProvider), isNull);
  });
}
