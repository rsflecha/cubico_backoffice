import 'package:cubico_backoffice/features/auth/domain/app_user.dart';
import 'package:cubico_backoffice/features/auth/domain/user_repository.dart';
import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:cubico_backoffice/features/settings/presentation/widgets/users_section.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _rui = AppUser(id: 1, name: "Rui", email: "rui@teste.pt", role: UserRole.admin);
const _sara = AppUser(id: 2, name: "Sara", email: "sara@teste.pt", role: UserRole.staff);

/// Faz de API: devolve uma provisória e lembra-se de para quem foi.
class _FakeUsers implements UserRepository {
  final reset = <int>[];

  @override
  Future<List<AppUser>> fetchAll() async => [_rui, _sara];

  @override
  Future<String?> resetPassword(int id) async {
    reset.add(id);
    return "Ab3dEf7hJk9m";
  }

  @override
  Future<({AppUser user, String? temporaryPassword})> create(AppUser draft) => throw UnimplementedError();

  @override
  Future<AppUser> update(AppUser user) => throw UnimplementedError();

  @override
  Future<void> delete(int id) => throw UnimplementedError();
}

void main() {
  testWidgets("o administrador dá uma palavra-passe provisória à Sara (e a si próprio não)", (tester) async {
    final users = _FakeUsers();
    final container = ProviderContainer(overrides: [userRepositoryProvider.overrideWithValue(users)]);
    addTearDown(container.dispose);
    container.read(sessionProvider.notifier).signInAs(_rui);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: Scaffold(body: SingleChildScrollView(child: UsersSection()))),
    ));
    await tester.pumpAndSettle();

    // só uma chave: a da Sara (o Rui muda a sua em "Mudar palavra-passe")
    expect(find.byTooltip("Nova palavra-passe"), findsOneWidget);

    await tester.tap(find.byTooltip("Nova palavra-passe"));
    await tester.pumpAndSettle();
    expect(find.text("Nova palavra-passe para Sara?"), findsOneWidget);

    await tester.tap(find.text("Gerar"));
    await tester.pumpAndSettle();
    expect(users.reset, [2]);
    expect(find.text("Ab3dEf7hJk9m"), findsOneWidget);

    await tester.tap(find.text("Já a copiei"));
    await tester.pumpAndSettle();
    expect(find.text("Ab3dEf7hJk9m"), findsNothing);
  });
}
