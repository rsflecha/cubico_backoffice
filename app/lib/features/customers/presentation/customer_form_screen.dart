import 'package:cubico_backoffice/features/customers/domain/customer.dart';
import 'package:cubico_backoffice/features/customers/presentation/customers_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// O código postal português: 4 algarismos, um hífen, 3 algarismos.
final _ptPostalCode = RegExp(r"^\d{4}-\d{3}$");

/// Criar (sem customerId) ou editar (com customerId) um cliente.
class CustomerFormScreen extends ConsumerStatefulWidget {
  const CustomerFormScreen({super.key, this.customerId});

  final int? customerId;

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  Customer? _original;

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _instagram = TextEditingController();
  final _notes = TextEditingController();
  // uma morada (a primeira); várias moradas ficam para mais tarde
  final _line1 = TextEditingController();
  final _line2 = TextEditingController();
  final _postalCode = TextEditingController();
  final _city = TextEditingController();

  var _submitted = false;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    final id = widget.customerId;
    if (id == null) return;
    final customers = ref.read(customersProvider).value ?? <Customer>[];
    _original = customers.where((c) => c.id == id).firstOrNull;
    final c = _original;
    if (c == null) return;

    _name.text = c.name;
    _email.text = c.email ?? "";
    _phone.text = c.phone ?? "";
    _instagram.text = c.instagram ?? "";
    _notes.text = c.notes ?? "";
    final address = c.addresses.firstOrNull;
    if (address != null) {
      _line1.text = address.line1;
      _line2.text = address.line2 ?? "";
      _postalCode.text = address.postalCode;
      _city.text = address.city;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _name, _email, _phone, _instagram, _notes,
      _line1, _line2, _postalCode, _city,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Texto limpo, ou null se estiver vazio.
  String? _value(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  /// Algum campo da morada foi preenchido?
  bool get _hasAddress =>
      [_line1, _line2, _postalCode, _city].any((c) => c.text.trim().isNotEmpty);

  Future<void> _save() async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final old = _original;
    final oldAddress = old?.addresses.firstOrNull;

    final address = _hasAddress
        ? Address(
      id: oldAddress?.id ?? 0, // 0 = morada nova
      line1: _line1.text.trim(),
      line2: _value(_line2),
      postalCode: _postalCode.text.trim(),
      city: _city.text.trim(),
    )
        : null;

    final draft = Customer(
      id: old?.id ?? 0,
      name: _name.text.trim(),
      email: _value(_email),
      phone: _value(_phone),
      // guarda sem o @, mesmo que o escrevam
      instagram: _value(_instagram)?.replaceFirst("@", ""),
      notes: _value(_notes),
      createdAt: old?.createdAt ?? DateTime.now(),
      // a primeira morada é a do formulário; as outras (se houver) ficam como estavam
      addresses: [
        ?address, // o "?" só junta a morada se não for null
        ...?old?.addresses.skip(1),
      ],
    );

    final repository = ref.read(customerRepositoryProvider);
    final Customer saved;
    try {
      saved = old == null ? await repository.create(draft) : await repository.update(draft);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Não foi possível guardar: $error")),
      );
      return;
    }
    ref.invalidate(customersProvider);
    if (!mounted) return;
    // um cliente novo abre a ficha; uma edição volta à ficha
    if (old == null) {
      context.pushReplacement("/customers/${saved.id}");
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget field(
        TextEditingController c,
        String label, {
          String? hint,
          TextInputType? keyboard,
          String? Function(String?)? validator,
          int maxLines = 1,
        }) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: c,
          keyboardType: keyboard,
          maxLines: maxLines,
          decoration: InputDecoration(labelText: label, hintText: hint),
          validator: validator,
          onChanged: (_) => setState(() {}),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_original == null ? "Novo cliente" : "Editar cliente")),
      body: Form(
        key: _formKey,
        autovalidateMode:
        _submitted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("Contactos", style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  field(_name, "Nome",
                      validator: (v) =>
                      (v ?? "").trim().isEmpty ? "O nome é obrigatório." : null),
                  field(_email, "Email (opcional)",
                      keyboard: TextInputType.emailAddress,
                      validator: (v) {
                        final t = (v ?? "").trim();
                        if (t.isEmpty) return null;
                        return t.contains("@") && t.contains(".") ? null : "Este email não parece certo.";
                      }),
                  field(_phone, "Telemóvel (opcional)", keyboard: TextInputType.phone),
                  field(_instagram, "Instagram (opcional)", hint: "@nome"),
                  const SizedBox(height: 12),
                  Text("Morada (opcional)", style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  field(_line1, "Rua e número",
                      validator: (v) => _hasAddress && (v ?? "").trim().isEmpty
                          ? "Falta a rua."
                          : null),
                  field(_line2, "Andar, porta… (opcional)"),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 160,
                        child: field(_postalCode, "Código postal",
                            hint: "4700-000",
                            validator: (v) {
                              final t = (v ?? "").trim();
                              if (!_hasAddress) return null;
                              if (t.isEmpty) return "Falta o código.";
                              return _ptPostalCode.hasMatch(t) ? null : "Formato: 4700-000";
                            }),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: field(_city, "Localidade",
                            validator: (v) => _hasAddress && (v ?? "").trim().isEmpty
                                ? "Falta a localidade."
                                : null),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  field(_notes, "Notas (opcional)", maxLines: 3),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text("Guardar"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}