import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:cubico_backoffice/features/settings/presentation/widgets/users_section.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// A versão da app. Muda-a aqui quando publicares uma Release nova.
const appVersion = "0.2.0";

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Definições")),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _section(context, "A minha conta", [
                  ListTile(
                    leading: CircleAvatar(child: Text((user?.name ?? "?")[0])),
                    title: Text(user?.name ?? ""),
                    subtitle: Text(user?.email ?? ""),
                    trailing: Text(user?.isAdmin == true ? "Administrador" : "Colaborador"),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text("Terminar sessão"),
                    onTap: () => ref.read(sessionProvider.notifier).signOut(),
                  ),
                ]),
                _section(context, "Utilizadores", const [UsersSection()]),
                _section(context, "Atalhos", [
                  ListTile(
                    leading: const Icon(Icons.calculate_outlined),
                    title: const Text("Custos e preços"),
                    subtitle: const Text("Energia, filamentos, embalagens, portes, taxas e margens"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go("/costs"),
                  ),
                  ListTile(
                    leading: const Icon(Icons.folder_outlined),
                    title: const Text("Categorias dos produtos"),
                    subtitle: const Text("Criar, mudar o nome ou apagar, em Produtos"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go("/products"),
                  ),
                ]),
                _section(context, "Sobre", [
                  const ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text("CubicoDesign3D Backoffice"),
                    subtitle: Text("Versão $appVersion"),
                  ),
                  const ListTile(
                    leading: Icon(Icons.science_outlined),
                    title: Text("Modo demo"),
                    subtitle: Text(
                      "Os dados são de exemplo e ficam só na memória: "
                          "desaparecem quando fechas a app.",
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Uma secção com título e um cartão com as linhas.
  Widget _section(BuildContext context, String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(child: Column(children: children)),
        ],
      ),
    );
  }
}