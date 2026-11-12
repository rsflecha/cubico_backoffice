import 'package:cubico_backoffice/app/theme.dart';
import 'package:cubico_backoffice/features/auth/domain/app_user.dart';
import 'package:cubico_backoffice/features/auth/domain/auth_repository.dart';
import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _keepSession = true;
  var _loading = false;
  var _showPassword = false; // o "olho": mostrar ou esconder a palavra-passe
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(sessionProvider.notifier).signIn(_email.text, _password.text);
    } on AuthException catch (e) {
      // palavra-passe errada: mostra a nossa mensagem
      setState(() {
        _loading = false;
        _error = e.message;
      });
      return;
    } catch (e) {
      // outro problema qualquer
      setState(() {
        _loading = false;
        _error = "Não foi possível entrar. Tenta outra vez.";
      });
      return;
    }
    if (!mounted) return;
    context.go("/dashboard");
  }

  /// "Explorar em modo demo": escolher o papel.
  Future<void> _demo() async {
    final role = await showDialog<UserRole>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text("Explorar como…"),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, UserRole.admin),
            child: const ListTile(
              leading: Icon(Icons.admin_panel_settings_outlined),
              title: Text("Administrador"),
              subtitle: Text("Vê tudo, incluindo custos e lucros."),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, UserRole.staff),
            child: const ListTile(
              leading: Icon(Icons.storefront_outlined),
              title: Text("Colaborador"),
              subtitle: Text("Só a parte operacional, sem custos nem lucros."),
            ),
          ),
        ],
      ),
    );
    if (role == null) return;
    ref.read(sessionProvider.notifier).signInAs(
      role == UserRole.admin
          ? const AppUser(id: 1, name: "Rui", email: "admin@demo.pt", role: UserRole.admin)
          : const AppUser(id: 2, name: "Ana", email: "loja@demo.pt", role: UserRole.staff),
    );
    if (!mounted) return;
    context.go("/dashboard");
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    final form = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(32),
          children: [
            Text("Entrar", style: AppTextStyles.brand.copyWith(fontSize: 28)),
            const SizedBox(height: 4),
            const Text("Acede ao backoffice da tua loja."),
            const SizedBox(height: 24),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(labelText: "Email", hintText: "nome@exemplo.pt"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _password,
              obscureText: !_showPassword, // escondida, a não ser que se carregue no olho
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                labelText: "Palavra-passe",
                suffixIcon: IconButton(
                  tooltip: _showPassword ? "Esconder a palavra-passe" : "Mostrar a palavra-passe",
                  icon: Icon(_showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                  onPressed: () => setState(() => _showPassword = !_showPassword),
                ),
              ),
              onSubmitted: (_) => _signIn(),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _keepSession,
              onChanged: (v) => setState(() => _keepSession = v ?? true),
              title: const Text("Manter sessão"),
            ),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C))),
              const SizedBox(height: 8),
            ],
            FilledButton(
              onPressed: _loading ? null : _signIn,
              child: _loading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text("Entrar"),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("ou")),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: _demo, child: const Text("Explorar em modo demo")),
            const SizedBox(height: 8),
            Text(
              "O modo demo usa dados de exemplo e não liga ao servidor.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );

    // a metade escura com a marca (só em ecrãs largos)
    final brand = Container(
      color: AppColors.black,
      padding: const EdgeInsets.all(48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset("assets/brand/icon-branco.png", height: 56),
              const SizedBox(width: 12),
              Text(
                "CubicoDesign3D",
                style: AppTextStyles.brand.copyWith(color: Colors.white, fontSize: 22),
              ),
            ],
          ),
          const Spacer(),
          Text(
            "Da impressora à porta do cliente, tudo num só sítio.",
            style: AppTextStyles.brand.copyWith(
              color: Colors.white,
              fontSize: 36,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Encomendas, produção, custos e margens da tua loja de impressão 3D.",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );

    return Scaffold(
      body: isWide
          ? Row(children: [Expanded(child: brand), Expanded(child: form)])
          : form,
    );
  }
}