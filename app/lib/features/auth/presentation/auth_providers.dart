import 'dart:async';

import 'package:cubico_backoffice/core/api/api_client.dart';
import 'package:cubico_backoffice/core/passkeys/passkey_bridge.dart';
import 'package:cubico_backoffice/features/auth/data/api_auth_repository.dart';
import 'package:cubico_backoffice/features/auth/data/api_passkey_repository.dart';
import 'package:cubico_backoffice/features/auth/data/api_user_repository.dart';
import 'package:cubico_backoffice/features/auth/data/demo_user_repository.dart';
import 'package:cubico_backoffice/features/auth/data/session_storage.dart';
import 'package:cubico_backoffice/features/auth/domain/app_user.dart';
import 'package:cubico_backoffice/features/auth/domain/auth_repository.dart';
import 'package:cubico_backoffice/features/auth/domain/passkey.dart';
import 'package:cubico_backoffice/features/auth/domain/user_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Qual é o repositório de autenticação: a API a sério.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ApiAuthRepository(ref.watch(dioProvider), ref.watch(tokenStoreProvider));
});

/// O Face ID / impressão digital (passkeys): a API e o browser.
final passkeyRepositoryProvider = Provider<PasskeyRepository>((ref) {
  return ApiPasskeyRepository(ref.watch(dioProvider), ref.watch(tokenStoreProvider));
});

/// Há Face ID / impressão digital aqui? Só no site (web), num browser que saiba.
/// (A app de Windows e a APK ainda não; e no modo demo não há servidor para o guardar.)
final passkeysAvailableProvider = Provider<bool>((ref) => kIsWeb && const PasskeyBridge().supported);

/// Os meus aparelhos com Face ID.
final passkeysProvider = FutureProvider<List<Passkey>>((ref) {
  return ref.watch(passkeyRepositoryProvider).fetchAll();
});

/// Onde fica guardada a sessão do "Manter sessão".
/// Por omissão só na memória (nos testes); o main troca-a pelas preferências da app.
final sessionStorageProvider = Provider<SessionStorage>((ref) => MemorySessionStorage());

/// O modo da sessão: true = modo demo (dados de exemplo, sem servidor);
/// false = sessão a sério, com os dados da API.
class DemoModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) {
    state = value;
  }
}

/// Em que modo está a app. Cada placa de repositório escolhe o Demo ou o Api conforme isto.
final demoModeProvider = NotifierProvider<DemoModeNotifier, bool>(DemoModeNotifier.new);

/// Uma mensagem para mostrar no ecrã de login ("A sessão expirou. Entra outra vez.").
class LoginMessageNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? message) => state = message;
}

final loginMessageProvider = NotifierProvider<LoginMessageNotifier, String?>(
  LoginMessageNotifier.new,
);

/// Quem tem sessão iniciada. null = ninguém.
class SessionNotifier extends Notifier<AppUser?> {
  /// Esta sessão foi aberta com "Manter sessão"? (então fica guardada entre aberturas)
  var _remember = false;

  @override
  AppUser? build() {
    // quando a API recusar o token (401), a sessão termina aqui
    ref.read(tokenStoreProvider).onExpired = _expire;
    return null;
  }

  SessionStorage get _storage => ref.read(sessionStorageProvider);

  /// Entra com email e palavra-passe. Lança AuthException se falhar.
  Future<void> signIn(String email, String password, {bool remember = false}) async {
    final user = await ref
        .read(authRepositoryProvider)
        .signIn(email: email, password: password, remember: remember);
    await _start(user, remember);
  }

  /// Entra com o Face ID / impressão digital. Lança PasskeyException se falhar.
  Future<void> signInWithPasskey(PreparedPasskey prepared, {bool remember = false}) async {
    final user = await ref.read(passkeyRepositoryProvider).signIn(prepared, remember: remember);
    await _start(user, remember);
  }

  /// Já entrou (com palavra-passe ou Face ID): abre a sessão.
  Future<void> _start(AppUser user, bool remember) async {
    ref.read(demoModeProvider.notifier).set(false); // sessão a sério: os dados vêm da API
    ref.read(loginMessageProvider.notifier).set(null);
    _remember = remember;
    // com "Manter sessão", guarda; sem ele, apaga o que houvesse de outra vez
    final token = ref.read(tokenStoreProvider).token;
    if (remember && token != null) {
      await _storage.save(token, user);
    } else {
      await _storage.clear();
    }
    state = user;
  }

  /// Ao abrir a app: se havia uma sessão guardada, entra logo com ela.
  /// Depois confirma-a com a API, sem fazer esperar quem está a usar a app:
  /// se já não valer, o 401 termina a sessão; se o nome ou o papel mudaram, atualiza-os.
  void restore() {
    final saved = _storage.read();
    if (saved == null) return;
    ref.read(tokenStoreProvider).token = saved.token;
    ref.read(demoModeProvider.notifier).set(false);
    _remember = true;
    state = saved.user;
    unawaited(_refresh());
  }

  Future<void> _refresh() async {
    try {
      final user = await ref.read(authRepositoryProvider).me();
      if (state == null) return; // entretanto saiu
      state = user;
      final token = ref.read(tokenStoreProvider).token;
      if (token != null) await _storage.save(token, user);
    } catch (_) {
      // 401: o interceptor já terminou a sessão. Sem rede: fica como está, e o
      // próximo pedido à API volta a tentar.
    }
  }

  /// A API recusou o token: sai, e o login mostra porquê.
  void _expire(String message) {
    if (state == null || ref.read(demoModeProvider)) return; // já saiu, ou é a demo
    ref.read(tokenStoreProvider).token = null;
    unawaited(_storage.clear());
    ref.read(loginMessageProvider.notifier).set(message);
    state = null;
  }

  /// Muda a própria palavra-passe. Lança AuthException com a mensagem da API.
  /// As outras sessões (noutros aparelhos) deixam de valer; esta continua, com o token novo.
  Future<void> changePassword(String currentPassword, String newPassword) async {
    await ref.read(authRepositoryProvider).changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      remember: _remember,
    );
    final token = ref.read(tokenStoreProvider).token;
    final user = state;
    if (_remember && token != null && user != null) await _storage.save(token, user);
  }

  /// Entra diretamente com uma conta demo (o botão "Explorar em modo demo").
  void signInAs(AppUser user) {
    ref.read(demoModeProvider.notifier).set(true); // modo demo: os dados de exemplo
    ref.read(loginMessageProvider.notifier).set(null);
    state = user;
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    await _storage.clear(); // sair a sério: a sessão guardada também vai
    _remember = false;
    state = null;
  }
}

/// A sessão: quem está a usar a app.
final sessionProvider = NotifierProvider<SessionNotifier, AppUser?>(SessionNotifier.new);

/// Qual é o repositório dos utilizadores.
final userRepositoryProvider = Provider<UserRepository>((ref) {
  if (ref.watch(demoModeProvider)) return DemoUserRepository();
  return ApiUserRepository(ref.watch(dioProvider));
});

/// Quem tem acesso à app.
final usersProvider = FutureProvider<List<AppUser>>((ref) {
  return ref.watch(userRepositoryProvider).fetchAll();
});
