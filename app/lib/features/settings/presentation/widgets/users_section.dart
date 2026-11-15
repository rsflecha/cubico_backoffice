import 'package:cubico_backoffice/core/api/api_exception.dart';
import 'package:cubico_backoffice/features/auth/domain/app_user.dart';
import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// O nome do papel, como aparece no ecrã.
String _roleLabel(UserRole role) => role == UserRole.admin ? "Administrador" : "Colaborador";

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

  /// Muda o papel de um utilizador.
  Future<void> _changeRole(BuildContext context, WidgetRef ref, AppUser u, UserRole role) =>
      _run(context, ref, () => ref.read(userRepositoryProvider).update(u.copyWith(role: role)));

  /// Pergunta, e retira o acesso. Era um clique só, sem volta atrás.
  Future<void> _remove(BuildContext context, WidgetRef ref, AppUser u) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Retirar o acesso a ${u.name}?"),
        content: const Text("Deixa de poder entrar na app. Para voltar, tens de o juntar outra vez."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text("Retirar")),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await _run(context, ref, () => ref.read(userRepositoryProvider).delete(u.id));
  }

  /// A janela para juntar um utilizador.
  Future<void> _add(BuildContext context, WidgetRef ref) async {
    // a janela é um StatefulWidget que cria e deita fora os seus próprios controllers
    final draft = await showDialog<AppUser>(
      context: context,
      builder: (context) => const _NewUserDialog(),
    );

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

        return LayoutBuilder(builder: (context, constraints) {
          // abaixo de 520 px, o menu do papel e o botão comiam a largura toda
          // e o nome e o email partiam letra a letra
          final narrow = constraints.maxWidth < 520;

          return Column(
            children: [
              for (final u in list)
                _userTile(
                  context,
                  ref,
                  u,
                  isMe: u.id == me?.id,
                  // não podes mudar o teu papel, nem tirar o último administrador
                  canChangeRole: u.id != me?.id && !(u.isAdmin && adminCount == 1),
                  narrow: narrow,
                ),
              ListTile(
                leading: const Icon(Icons.person_add_alt_outlined),
                title: const Text("Juntar utilizador"),
                onTap: () => _add(context, ref),
              ),
            ],
          );
        });
      },
    );
  }

  /// Uma linha da lista. Estreita: o papel por baixo do email e as ações num menu ⋮.
  Widget _userTile(
    BuildContext context,
    WidgetRef ref,
    AppUser u, {
    required bool isMe,
    required bool canChangeRole,
    required bool narrow,
  }) {
    final title = Text(isMe ? "${u.name} (tu)" : u.name, overflow: TextOverflow.ellipsis);
    final avatar = CircleAvatar(child: Text(u.name[0]));

    if (narrow) {
      final other = u.isAdmin ? UserRole.staff : UserRole.admin;
      return ListTile(
        leading: avatar,
        title: title,
        subtitle: Text("${u.email}\n${_roleLabel(u.role)}", maxLines: 2, overflow: TextOverflow.ellipsis),
        isThreeLine: true,
        // tu não tens ações sobre ti próprio: não aparece o menu
        trailing: isMe
            ? null
            : PopupMenuButton<String>(
                tooltip: "Ações",
                onSelected: (action) => action == "role"
                    ? _changeRole(context, ref, u, other)
                    : _remove(context, ref, u),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: "role",
                    enabled: canChangeRole,
                    child: Text("Passar a ${_roleLabel(other).toLowerCase()}"),
                  ),
                  const PopupMenuItem(value: "remove", child: Text("Retirar acesso")),
                ],
              ),
      );
    }

    return ListTile(
      leading: avatar,
      title: title,
      subtitle: Text(u.email),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<UserRole>(
            value: u.role,
            underline: const SizedBox(),
            items: [
              for (final r in [UserRole.admin, UserRole.staff])
                DropdownMenuItem(value: r, child: Text(_roleLabel(r))),
            ],
            onChanged: canChangeRole ? (role) => _changeRole(context, ref, u, role!) : null,
          ),
          IconButton(
            tooltip: "Retirar acesso",
            icon: const Icon(Icons.person_remove_outlined),
            // não te podes retirar a ti
            onPressed: isMe ? null : () => _remove(context, ref, u),
          ),
        ],
      ),
    );
  }
}

/// A janela "Novo utilizador". Devolve o rascunho, ou null se cancelares.
class _NewUserDialog extends StatefulWidget {
  const _NewUserDialog();

  @override
  State<_NewUserDialog> createState() => _NewUserDialogState();
}

class _NewUserDialogState extends State<_NewUserDialog> {
  // nascem e morrem com a janela: o dispose só corre quando ela sai mesmo do ecrã
  final _name = TextEditingController();
  final _email = TextEditingController();
  var _role = UserRole.staff;
  var _submitted = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  /// O que falta para poder juntar, ou null.
  String? _problem() {
    if (_name.text.trim().isEmpty) return "Escreve o nome.";
    if (!_email.text.contains("@")) return "Escreve um email válido.";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final problem = _problem();

    return AlertDialog(
      title: const Text("Novo utilizador"),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: "Nome"),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: "Email"),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            SegmentedButton<UserRole>(
              // sem o visto: no telemóvel "Administrador" não cabia
              showSelectedIcon: false,
              segments: [
                for (final r in [UserRole.staff, UserRole.admin])
                  ButtonSegment(value: r, label: Text(_roleLabel(r))),
              ],
              selected: {_role},
              onSelectionChanged: (s) => setState(() => _role = s.first),
            ),
            // antes, o botão "Juntar" não fazia nada e não dizia porquê
            if (_submitted && problem != null) ...[
              const SizedBox(height: 12),
              Text(problem, style: const TextStyle(color: Color(0xFFB91C1C))),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
        FilledButton(
          onPressed: () {
            setState(() => _submitted = true);
            if (problem != null) return;
            Navigator.pop(
              context,
              AppUser(
                id: 0,
                name: _name.text.trim(),
                email: _email.text.trim().toLowerCase(),
                role: _role,
              ),
            );
          },
          child: const Text("Juntar"),
        ),
      ],
    );
  }
}
