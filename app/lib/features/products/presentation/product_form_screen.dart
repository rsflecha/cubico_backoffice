import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>(); // o "comando" do formulário
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();

  var _submitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  void _save() {
    // pede ao formulário para verificar todos os campos
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return; // há erros: ficam a vermelho e não sai daqui

    // Passo B: aqui vamos gravar no repositório
    context.pop(); // volta à lista
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo produto')),
      body: Form(
        key: _formKey,
        autovalidateMode: _submitted
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,

        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                hintText: 'Ex.: Suporte de auscultadores',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'O nome é obrigatório.';
                }
                return null; // está tudo bem
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _skuController,
              decoration: const InputDecoration(
                labelText: 'SKU base',
                hintText: 'Ex.: CD3-SDA-01',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'O SKU é obrigatório.';
                }
                if (value.contains(' ')) {
                  return 'O SKU não pode ter espaços.';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}