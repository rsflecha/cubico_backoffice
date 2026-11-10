import 'package:cubico_backoffice/features/auth/domain/app_user.dart';
import 'package:cubico_backoffice/features/auth/domain/user_repository.dart';

class DemoUserRepository implements UserRepository {
  // as mesmas duas contas do login demo
  final List<AppUser> _items = [
    const AppUser(id: 1, name: "Rui", email: "admin@demo.pt", role: UserRole.admin),
    const AppUser(id: 2, name: "Ana", email: "loja@demo.pt", role: UserRole.staff),
  ];
  int _nextId = 10;

  Future<void> _latency() => Future.delayed(const Duration(milliseconds: 300));

  @override
  Future<List<AppUser>> fetchAll() async {
    await _latency();
    return List<AppUser>.of(_items);
  }

  @override
  Future<({AppUser user, String? temporaryPassword})> create(AppUser draft) async {
    await _latency();
    if (_items.any((u) => u.email == draft.email)) {
      throw StateError("Já existe um utilizador com este email.");
    }
    final created = draft.copyWith(id: _nextId++);
    _items.add(created);
    return (user: created, temporaryPassword: null); // no modo demo não há palavras-passe
  }

  @override
  Future<AppUser> update(AppUser user) async {
    await _latency();
    final index = _items.indexWhere((u) => u.id == user.id);
    if (index == -1) throw StateError("Utilizador ${user.id} não existe.");
    _items[index] = user;
    return user;
  }

  @override
  Future<void> delete(int id) async {
    await _latency();
    _items.removeWhere((u) => u.id == id);
  }
}