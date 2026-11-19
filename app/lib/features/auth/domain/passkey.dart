import 'package:cubico_backoffice/features/auth/domain/app_user.dart';

/// Um aparelho com o Face ID / impressão digital ativo (uma passkey).
class Passkey {
  const Passkey({required this.id, required this.label, required this.createdAt, this.lastUsedAt});

  factory Passkey.fromJson(Map<String, dynamic> json) => Passkey(
        id: json["id"] as int,
        label: json["label"] as String,
        createdAt: DateTime.parse(json["created_at"] as String),
        lastUsedAt: json["last_used_at"] == null ? null : DateTime.parse(json["last_used_at"] as String),
      );

  final int id;
  final String label; // "iPhone", "iPad", "Android"…
  final DateTime createdAt;
  final DateTime? lastUsedAt;
}

/// Um desafio já pedido à API, pronto a usar.
///
/// Porquê pedir antes do toque: o Safari (iPhone, iPad) só abre o Face ID se for logo a
/// seguir ao toque no botão. Se a app esperasse pela API depois do toque, o Safari recusava.
class PreparedPasskey {
  PreparedPasskey({required this.challengeId, required this.optionsJson, DateTime? fetchedAt})
      : fetchedAt = fetchedAt ?? DateTime.now();

  final String challengeId;
  final String optionsJson; // o que vai para o browser (navigator.credentials)
  final DateTime fetchedAt;

  /// A API dá 5 minutos; com 4 fica uma margem.
  bool get isFresh => DateTime.now().difference(fetchedAt) < const Duration(minutes: 4);
}

/// Um problema com o Face ID, com a mensagem para mostrar.
/// [cancelled]: a pessoa cancelou (ou o tempo acabou): não é preciso mostrar erro.
class PasskeyException implements Exception {
  const PasskeyException(this.message, {this.cancelled = false});

  final String message;
  final bool cancelled;

  @override
  String toString() => message;
}

abstract interface class PasskeyRepository {
  /// Pede um desafio para entrar (sem sessão).
  Future<PreparedPasskey> prepareSignIn();

  /// O aparelho pede a cara ou o dedo; se bater certo, a API dá o token. Lança PasskeyException.
  Future<AppUser> signIn(PreparedPasskey prepared, {bool remember = false});

  /// Pede um desafio para ativar neste aparelho (com sessão). Pede a palavra-passe:
  /// com um acesso roubado não se cria uma entrada permanente. Lança PasskeyException.
  Future<PreparedPasskey> prepareRegister({required String password});

  /// O aparelho cria a chave; a API guarda a parte pública. Devolve a lista nova.
  Future<List<Passkey>> register(PreparedPasskey prepared);

  /// Os meus aparelhos com Face ID.
  Future<List<Passkey>> fetchAll();

  /// Tira o Face ID de um aparelho. Devolve a lista nova.
  Future<List<Passkey>> remove(int id);
}
