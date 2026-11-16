import 'package:cubico_backoffice/app/app.dart';
import 'package:cubico_backoffice/features/auth/data/session_storage.dart';
import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  // preciso antes de usar plugins (as preferências) fora de um widget
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // o "contentor" dos providers, criado aqui para se poder recuperar a sessão
  // ANTES de o primeiro ecrã aparecer (senão piscava o login)
  final container = ProviderContainer(
    overrides: [
      sessionStorageProvider.overrideWithValue(PrefsSessionStorage(prefs)),
    ],
  );
  container.read(sessionProvider.notifier).restore();

  runApp(UncontrolledProviderScope(container: container, child: const App()));
}
