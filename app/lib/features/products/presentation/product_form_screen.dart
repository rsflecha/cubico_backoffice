import 'dart:typed_data';

import 'package:cubico_backoffice/core/api/api_exception.dart';
import 'package:cubico_backoffice/core/photos.dart';
import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:cubico_backoffice/features/products/presentation/products_providers.dart';
import 'package:cubico_backoffice/features/products/presentation/widgets/cost_card.dart';
import 'package:cubico_backoffice/features/products/presentation/widgets/product_photo.dart';
import 'package:cubico_backoffice/features/products/presentation/widgets/variants_section.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:cubico_backoffice/features/products/domain/product.dart';
import 'package:cubico_backoffice/features/products/domain/variant.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.productId});

  final int? productId; // null = produto novo

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>(); // o "comando" do formulário
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  int? _categoryId;
  var _submitted = false;
  var _saving = false;
  var _preparingPhoto = false; // a reduzir a foto escolhida
  Uint8List? _newPhoto; // a foto escolhida agora, já reduzida (ainda não gravada)
  Product? _original; // o produto tal como estava, quando se edita
  int? _selectedVariantId; // a variante escolhida na tabela

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final id = widget.productId;
    if (id == null) return; // produto novo: campos vazios

    final products = ref.read(productsProvider).value ?? [];
    _original = products.where((p) => p.id == id).firstOrNull;

    if (_original != null) {
      _nameController.text = _original!.name;
      _skuController.text = _original!.baseSku;
      _categoryId = _original!.categoryId;
    }
  }

  /// Um produto novo tem de ter foto; um que já existe fica com a que tinha.
  bool get _missingPhoto => _original == null && _newPhoto == null;

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  /// Abre o seletor de ficheiros, e reduz a imagem escolhida antes de a guardar no ecrã.
  Future<void> _pickPhoto() async {
    final file = await FilePicker.pickFile(type: FileType.image);
    if (file == null) return; // fechou a janela sem escolher

    setState(() => _preparingPhoto = true);
    Uint8List? photo;
    try {
      photo = await preparePhoto(await file.readAsBytes());
    } catch (_) {
      photo = null; // tratado logo abaixo, como uma imagem que não se consegue ler
    }
    if (!mounted) return;
    setState(() => _preparingPhoto = false);

    if (photo == null) {
      _showMessage("Não consegui ler esta imagem. Usa uma foto JPG, PNG ou WebP.");
      return;
    }
    setState(() => _newPhoto = photo);
  }

  Future<void> _save() async {
    setState(() => _submitted = true);
    final isValid = _formKey.currentState!.validate();
    // a foto não é um campo do Form, por isso confere-se à parte (o aviso aparece por baixo dela)
    if (!isValid || _missingPhoto) return;

    setState(() => _saving = true);

    final repository = ref.read(productRepositoryProvider);
    final name = _nameController.text.trim();
    final sku = _skuController.text.trim().toUpperCase();
    final photo = _newPhoto;

    try {
      if (_original == null) {
        await repository.create(
          name: name,
          baseSku: sku,
          categoryId: _categoryId!,
          photo: photo!, // _missingPhoto já garantiu que existe
        );
      } else {
        await repository.update(
          _original!.copyWith(
            name: name,
            baseSku: sku,
            categoryId: _categoryId,
            updatedAt: DateTime.now(),
          ),
        );
        // trocou a foto? vai num pedido à parte, depois dos dados
        if (photo != null) await repository.replacePhoto(_original!.id, photo);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage(
        error is ApiException ? error.message : "Não foi possível guardar. Tenta outra vez.",
      );
      return;
    } finally {
      // mesmo que a foto tenha falhado, os dados podem ter sido gravados: a lista vai buscá-los outra vez
      // (o "if (mounted)": depois de o ecrã fechar, o ref já não se pode usar)
      if (mounted) ref.invalidate(productsProvider);
    }

    if (!mounted) return;
    context.pop();
  }

  /// A foto no topo da ficha: a imagem, o botão para a escolher ou trocar, e o aviso se faltar.
  Widget _photoField(bool canEdit) {
    final colors = Theme.of(context).colorScheme;
    final hasPhoto = _newPhoto != null || _original?.photoUrl != null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ProductPhoto(url: _original?.photoUrl, bytes: _newPhoto, size: 120),
        if (canEdit) ...[
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OutlinedButton.icon(
                  onPressed: _preparingPhoto || _saving ? null : _pickPhoto,
                  icon: _preparingPhoto
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.add_photo_alternate_outlined),
                  label: Text(hasPhoto ? "Trocar foto" : "Escolher foto"),
                ),
                const SizedBox(height: 8),
                if (_submitted && _missingPhoto)
                  Text(
                    "A foto é obrigatória.",
                    style: TextStyle(color: colors.error, fontSize: 12),
                  )
                else
                  Text(
                    "JPG, PNG ou WebP. É reduzida antes de enviar.",
                    style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Apagar produto?"),
        content: Text("O produto \"${_original!.name}\" vai ser apagado."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Apagar"),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(productRepositoryProvider).delete(_original!.id);
    ref.invalidate(productsProvider);

    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(productCategoriesProvider).value ?? [];
    final isWide = MediaQuery.sizeOf(context).width >= 1100;
    // o colaborador só consulta: sem editar, sem apagar, sem calculadora
    final canSeeCosts = ref.watch(sessionProvider)?.canSeeCosts ?? false;

    // as variantes deste produto (só quando se edita)
    final variants = _original == null
        ? <Variant>[]
        : ref.watch(variantsProvider(_original!.id)).value ?? <Variant>[];
    // a escolhida, ou a primeira se ainda não escolheste nenhuma
    final selectedVariant =
        variants.where((v) => v.id == _selectedVariantId).firstOrNull ??
        variants.firstOrNull;

    final Widget? costCard = canSeeCosts
        ? CostCard(key: ValueKey(selectedVariant?.id), variant: selectedVariant)
        : null;

    final formFields = <Widget>[
      _photoField(canSeeCosts),
      const SizedBox(height: 24),
      TextFormField(
        controller: _nameController,
        enabled: canSeeCosts,
        decoration: const InputDecoration(
          labelText: "Nome",
          hintText: "Ex.: Suporte de auscultadores",
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "O nome é obrigatório.";
          }
          return null; // está tudo bem
        },
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<int>(
        initialValue: _categoryId,
        decoration: const InputDecoration(labelText: "Categoria"),
        items: [
          for (final category in categories)
            DropdownMenuItem(value: category.id, child: Text(category.name)),
        ],
        // sem onChanged, a lista fica desligada (só consulta)
        onChanged: canSeeCosts ? (value) => setState(() => _categoryId = value) : null,
        validator: (value) => value == null ? "Escolhe uma categoria." : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _skuController,
        enabled: canSeeCosts,
        decoration: const InputDecoration(
          labelText: "SKU base",
          hintText: "Ex.: CD3-SDA-01",
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "O SKU é obrigatório.";
          }
          if (value.contains(" ")) {
            return "O SKU não pode ter espaços.";
          }
          return null;
        },
      ),
      if (canSeeCosts) ...[
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("Guardar"),
        ),
      ],
      if (_original != null) ...[
        const SizedBox(height: 24),
        VariantsSection(
          productId: _original!.id,
          selectedVariantId: selectedVariant?.id,
          onSelect: (v) => setState(() => _selectedVariantId = v.id),
        ),
      ],
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.productId == null
              ? "Novo produto"
              : canSeeCosts
                  ? "Editar produto"
                  : "Produto",
        ),
        actions: [
          if (_original != null && canSeeCosts)
            IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
              tooltip: "Apagar produto",
            ),
        ],
      ),

      body: Form(
        key: _formKey,
        autovalidateMode: _submitted
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: isWide && costCard != null
            // PC (administrador): formulário à esquerda, cartão à direita
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: ListView(
                      padding: const EdgeInsets.all(24),
                      children: formFields,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(0, 24, 24, 24),
                      child: costCard,
                    ),
                  ),
                ],
              )
            // telemóvel, ou colaborador: tudo numa coluna
            : ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  ...formFields,
                  if (costCard != null) ...[const SizedBox(height: 24), costCard],
                ],
              ),
      ),
    );
  }
}
