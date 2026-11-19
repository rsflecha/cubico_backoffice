import 'package:cubico_backoffice/app/theme.dart';
import 'package:cubico_backoffice/features/auth/domain/app_user.dart';
import 'package:cubico_backoffice/features/auth/domain/auth_repository.dart';
import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:cubico_backoffice/features/auth/presentation/passkey_widgets.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
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
      // "Manter sessão": a sessão fica guardada e dura 30 dias (antes a caixa não fazia nada)
      await ref
          .read(sessionProvider.notifier)
          .signIn(_email.text, _password.text, remember: _keepSession);
    } on AuthException catch (e) {
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
    // entrou: avisa o dispositivo de que o preenchimento acabou bem. É isto que faz
    // aparecer o "Guardar palavra-passe?" (Android, iPhone, browser). Só aqui, depois de a
    // entrada dar certo: uma palavra-passe errada nunca é oferecida para guardar.
    TextInput.finishAutofillContext();
    if (!mounted) return;
    context.go("/dashboard");
  }

  /// O grupo de preenchimento automático só na app instalada (Android, iPhone), não na web.
  Widget _autofill(Widget fields) => kIsWeb ? fields : AutofillGroup(child: fields);

  /// A palavra-passe, com o "olho" para a mostrar.
  Widget _passwordField() => TextField(
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
      );

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
    // porque é que se voltou ao login (a sessão expirou, o acesso foi retirado…)
    final message = ref.watch(loginMessageProvider);

    final form = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(32),
          children: [
            // sem o painel preto (ecrãs estreitos), a marca aparece aqui, em versão escura
            if (!isWide) ...[
              Row(
                children: [
                  Image.asset("assets/brand/icon-preto.png", height: 40),
                  const SizedBox(width: 10),
                  Text("CubicoDesign3D", style: AppTextStyles.brand.copyWith(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 32),
            ],
            Text("Entrar", style: AppTextStyles.brand.copyWith(fontSize: 28)),
            const SizedBox(height: 4),
            const Text("Acede ao backoffice da tua loja."),
            const SizedBox(height: 24),
            if (message != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7), // âmbar claro: um aviso, não um erro
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFF59E0B)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFFB45309)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(message)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            // o email e a palavra-passe numa "caixa" de preenchimento automático: o dispositivo
            // percebe que são da mesma conta e, depois de entrar, pergunta se os quer guardar.
            // Na WEB não: no browser do telemóvel, depois de uma palavra-passe errada, o campo
            // ficava "preso" (não apagava nem aceitava letras). Na web ficam só os autofillHints.
            _autofill(
              Column(
                children: [
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    // username também: o Android e o iPhone guardam a conta por esse nome
                    autofillHints: const [AutofillHints.email, AutofillHints.username],
                    decoration: const InputDecoration(labelText: "Email", hintText: "nome@exemplo.pt"),
                  ),
                  const SizedBox(height: 16),
                  _passwordField(),
                ],
              ),
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
            // Face ID / impressão digital: só no site, num browser que saiba
            if (ref.watch(passkeysAvailableProvider)) ...[
              const SizedBox(height: 12),
              PasskeySignInButton(
                remember: _keepSession,
                onSignedIn: () => context.go("/dashboard"),
              ),
            ],
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