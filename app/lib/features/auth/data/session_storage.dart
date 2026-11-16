import 'dart:convert';

import 'package:cubico_backoffice/features/auth/domain/app_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Uma sessão guardada: o token e quem é (para a app abrir logo, sem esperar pela API).
typedef SavedSession = ({String token, AppUser user});

/// Onde fica a sessão do "Manter sessão", entre aberturas da app.
abstract interface class SessionStorage {
  SavedSession? read();
  Future<void> save(String token, AppUser user);
  Future<void> clear();
}

/// No telemóvel e no PC: as preferências da app. Na web: o localStorage do browser.
class PrefsSessionStorage implements SessionStorage {
  PrefsSessionStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _tokenKey = "session.token";
  static const _userKey = "session.user";

  @override
  SavedSession? read() {
    final token = _prefs.getString(_tokenKey);
    final userJson = _prefs.getString(_userKey);
    if (token == null || userJson == null) return null;
    try {
      final user = AppUser.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      return (token: token, user: user);
    } catch (_) {
      return null; // guardado por uma versão antiga, ou estragado: como se não houvesse
    }
  }

  @override
  Future<void> save(String token, AppUser user) async {
    await _prefs.setString(_tokenKey, token);
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
  }
}

/// Só na memória: nos testes, ou enquanto o main não ligar as preferências.
class MemorySessionStorage implements SessionStorage {
  SavedSession? _saved;

  @override
  SavedSession? read() => _saved;

  @override
  Future<void> save(String token, AppUser user) async => _saved = (token: token, user: user);

  @override
  Future<void> clear() async => _saved = null;
}
