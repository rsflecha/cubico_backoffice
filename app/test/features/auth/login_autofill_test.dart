import 'package:cubico_backoffice/features/auth/data/session_storage.dart';
import 'package:cubico_backoffice/features/auth/domain/app_user.dart';
import 'package:cubico_backoffice/features/auth/domain/auth_repository.dart';
import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:cubico_backoffice/features/auth/presentation/login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// "Guardar palavra-passe?": o dispositivo só pergunta se a app lhe disser que campos são
/// a conta (AutofillGroup) e que a entrada correu bem (finishAutofillContext).

/// Faz de API: só entra com a palavra-passe "certa".
class _FakeAuth implements AuthRepository {
  @override
  Future<AppUser> signIn({required String email, required String password, bool remember = false}) async {
    if (password != "certa") throw const AuthException("Email ou palavra-passe errados.");
    return const AppUser(id: 1, name: "Rui", email: "rui@teste.pt", role: UserRole.admin);
  }

  @override
  Future<AppUser> me() => throw UnimplementedError();

  @override
  Future<void> changePassword({required String currentPassword, required String newPassword, bool remember = false}) =>
      throw UnimplementedError();

  @override
  Future<void> signOut() async {}
}

void main() {
  Future<void> start(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(routes: [
      GoRoute(path: "/", builder: (_, _) => const LoginScreen()),
      GoRoute(path: "/dashboard", builder: (_, _) => const Text("dashboard")),
    ]);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(_FakeAuth()),
        sessionStorageProvider.overrideWithValue(MemorySessionStorage()),
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pump();
  }

  /// Quantas vezes a app disse ao dispositivo "acabou, podes guardar".
  int finishCalls(WidgetTester tester) =>
      tester.testTextInput.log.where((c) => c.method == "TextInput.finishAutofillContext").length;

  testWidgets("o email e a palavra-passe estão no mesmo grupo de preenchimento", (tester) async {
    await start(tester);
    final group = find.byType(AutofillGroup);
    expect(group, findsOneWidget);
    final fields = tester.widgetList<TextField>(find.descendant(of: group, matching: find.byType(TextField))).toList();
    expect(fields, hasLength(2));
    expect(fields[0].autofillHints, contains(AutofillHints.email));
    expect(fields[1].autofillHints, [AutofillHints.password]);
  });

  testWidgets("palavra-passe errada: não oferece guardar; certa: oferece e entra", (tester) async {
    await start(tester);
    await tester.enterText(find.widgetWithText(TextField, "Email"), "rui@teste.pt");

    await tester.enterText(find.widgetWithText(TextField, "Palavra-passe"), "errada");
    await tester.tap(find.widgetWithText(FilledButton, "Entrar"));
    await tester.pump();
    await tester.pump();
    expect(find.text("Email ou palavra-passe errados."), findsOneWidget);
    expect(finishCalls(tester), 0);

    await tester.enterText(find.widgetWithText(TextField, "Palavra-passe"), "certa");
    await tester.tap(find.widgetWithText(FilledButton, "Entrar"));
    await tester.pump();
    await tester.pump();
    expect(finishCalls(tester), 1);
    expect(find.text("dashboard"), findsOneWidget);
  });
}
