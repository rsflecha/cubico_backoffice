import 'package:cubico_backoffice/core/api/api_exception.dart';
import 'package:cubico_backoffice/features/auth/domain/app_user.dart';
import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// A lista de quem tem acesso à app, com juntar, mudar o papel e retirar.
class UsersSection extends ConsumerWidget {
  const UsersSection({super.key});

  /// Corre uma gravação e mostra o erro, se houver.
  Future<void> _run(BuildContext context, WidgetRef ref, Future<void> Function() action) async {
    try {
      await action();
    } on StateError catch (error) {
      // um erro com uma mensagem nossa: mostra só a mensagem
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
      return;
    } on ApiException catch (error) {
      // a mensagem que a API mandou ("Tem de haver sempre pelo menos um administrador.")
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
      return;
    } catch (error) {
      // outro problema qualquer: uma mensagem geral
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Não foi possível guardar. Tenta outra vez.")),
      );
      return;
    }
    ref.invalidate(usersProvider);
  }

  /// A janela para juntar um utilizador.
  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final name = TextEditingController();
    final email = TextEditingController();
    var role = UserRole.staff;

    final draft = await showDialog<AppUser>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Novo utilizador"),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: "Nome"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                const SizedBox(height: 16),
                SegmentedButton<UserRole>(
                  segments: const [
                    ButtonSegment(value: UserRole.staff, label: Text("Colaborador")),
                    ButtonSegment(value: UserRole.admin, label: Text("Administrador")),
                  ],
                  selected: {role},
                  onSelectionChanged: (s) => setState(() => role = s.first),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            FilledButton(
              onPressed: () {
                final n = name.text.trim();
                final e = email.text.trim().toLowerCase();
                if (n.isEmpty || !e.contains("@")) return; // falta o nome ou o email
                Navigator.pop(context, AppUser(id: 0, name: n, email: e, role: role));
              },
              child: const Text("Juntar"),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    email.dispose();

    if (draft == null || !context.mounted) return;
    String? temporary;
    await _run(context, ref, () async {
      temporary = (await ref.read(userRepositoryProvider).create(draft)).temporaryPassword;
    });

    // com a API: mostrar a palavra-passe provisória, que só existe agora
    final password = temporary;
    if (password == null || !context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Palavra-passe provisória"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Dá esta palavra-passe a ${draft.name}, para entrar a primeira vez:"),
            const SizedBox(height: 12),
            SelectableText(
              password,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: 1),
            ),
            const SizedBox(height: 12),
            const Text(
              "Só aparece agora: na base de dados fica cifrada, e nem tu a voltas a ver.",
            ),
          ],
        ),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text("Já a copiei")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(sessionProvider);
    final users = ref.watch(usersProvider);

    return users.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Text("Erro: $error"),
      data: (list) {
        final adminCount = list.where((u) => u.isAdmin).length;

        return Column(
          children: [
            for (final u in list)
              ListTile(
                leading: CircleAvatar(child: Text(u.name[0])),
                title: Text(u.id == me?.id ? "${u.name} (tu)" : u.name),
                subtitle: Text(u.email),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<UserRole>(
                      value: u.role,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: UserRole.admin, child: Text("Administrador")),
                        DropdownMenuItem(value: UserRole.staff, child: Text("Colaborador")),
                      ],
                      // não podes mudar o teu papel, nem tirar o último administrador
                      onChanged: u.id == me?.id || (u.isAdmin && adminCount == 1)
                          ? null
                          : (role) => _run(
                        context,
                        ref,
                            () => ref.read(userRepositoryProvider).update(u.copyWith(role: role!)),
                      ),
                    ),
                    IconButton(
                      tooltip: "Retirar acesso",
                      icon: const Icon(Icons.person_remove_outlined),
                      // não te podes retirar a ti
                      onPressed: u.id == me?.id
                          ? null
                          : () => _run(
                        context,
                        ref,
                            () => ref.read(userRepositoryProvider).delete(u.id),
                      ),
                    ),
                  ],
                ),
              ),
            ListTile(
              leading: const Icon(Icons.person_add_alt_outlined),
              title: const Text("Juntar utilizador"),
              onTap: () => _add(context, ref),
            ),
          ],
        );
      },
    );
  }
}