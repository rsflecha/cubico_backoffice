import 'package:cubico_backoffice/features/products/presentation/products_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>(); // o "comando" do formulário
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  int? _categoryId;
  var _submitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _submitted = true);
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    await ref.read(productRepositoryProvider).create(
      name: _nameController.text.trim(),
      baseSku: _skuController.text.trim().toUpperCase(),
      categoryId: _categoryId!,
    );
    ref.invalidate(productsProvider);

    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(productCategoriesProvider).value ?? [];

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
            DropdownButtonFormField<int>(
              initialValue: _categoryId,
              decoration: const InputDecoration(labelText: 'Categoria'),
              items: [
                for (final category in categories)
                  DropdownMenuItem(value: category.id, child: Text(category.name)),
              ],
              onChanged: (value) => setState(() => _categoryId = value),
              validator: (value) => value == null ? 'Escolhe uma categoria.' : null,
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