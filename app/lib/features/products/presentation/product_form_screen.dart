import 'dart:typed_data';

import 'package:cubico_backoffice/app/theme.dart';
import 'package:cubico_backoffice/core/api/api_exception.dart';
import 'package:cubico_backoffice/core/colors.dart';
import 'package:cubico_backoffice/core/photos.dart';
import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:cubico_backoffice/features/costs/domain/cost_calculator.dart';
import 'package:cubico_backoffice/features/costs/domain/filament.dart';
import 'package:cubico_backoffice/features/costs/presentation/costs_providers.dart';
import 'package:cubico_backoffice/features/products/presentation/products_providers.dart';
import 'package:cubico_backoffice/features/products/presentation/widgets/cost_card.dart';
import 'package:cubico_backoffice/features/products/presentation/widgets/product_photo.dart';
import 'package:cubico_backoffice/features/products/presentation/widgets/variants_section.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:cubico_backoffice/features/products/domain/product.dart';
import 'package:cubico_backoffice/features/products/domain/variant.dart';

/// A ficha de um produto. Criar e editar são O MESMO ecrã:
/// à esquerda a foto, o nome, a categoria e as cores disponíveis;
/// à direita a receita e o preço (o cartão de custo).
/// Um só "Guardar" grava tudo: o produto E a variante que está no cartão.
class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.productId, @visibleForTesting this.initialPhoto});

  final int? productId; // null = produto novo

  /// Só para os testes: uma foto já escolhida (o seletor de ficheiros não abre num teste).
  final Uint8List? initialPhoto;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>(); // o "comando" do formulário
  // o "comando" do cartão de custo: lê-se a receita e o preço que lá estão escritos.
  // Uma key nova = um cartão novo (quando se muda de variante, recomeça com os dados dela).
  static const _calc = CostCalculator();
  var _cardKey = GlobalKey<CostCardState>();
  int? _cardVariantId; // a variante que o cartão está a mostrar
  final _nameController = TextEditingController();
  int? _categoryId;
  Set<int> _colorIds = {}; // as cores disponíveis (ids dos filamentos)
  var _submitted = false;
  var _saving = false;
  var _preparingPhoto = false; // a reduzir a foto escolhida
  Uint8List? _newPhoto; // a foto escolhida agora, já reduzida (ainda não gravada)
  Product? _original; // o produto tal como está gravado (null = ainda não existe)
  int? _selectedVariantId; // a variante escolhida na tabela
  String? _cardProblem; // o que falta no cartão (gramas, tempo, peso, preço)
  var _loading = false; // a ir buscar o produto (quando a lista ainda não tinha chegado)

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _newPhoto = widget.initialPhoto;
    final id = widget.productId;
    if (id == null) return; // produto novo: campos vazios

    // a lista pode ainda não ter chegado (ex.: a página web recarregada em /#/products/3):
    // espera-se por ela. Antes, a ficha abria vazia, como um produto NOVO, e gravar duplicava-o.
    // E a lista em memória pode ser antiga (sem um produto criado entretanto): sem ele, vai-se
    // buscá-la outra vez antes de dizer "já não existe".
    final loaded = ref.read(productsProvider).value?.where((p) => p.id == id).firstOrNull;
    if (loaded != null) {
      _fill(loaded);
    } else {
      _loading = true;
      if (ref.read(productsProvider).hasValue) ref.invalidate(productsProvider);
      ref.read(productsProvider.future).then(
        (list) => _fill(list.where((p) => p.id == id).firstOrNull),
        onError: (_) => _fill(null),
      );
    }
  }

  /// Põe nos campos o produto que se está a editar (null = já não existe).
  void _fill(Product? product) {
    if (!mounted) return;
    setState(() {
      _loading = false;
      _original = product;
      if (product != null) {
        _nameController.text = product.name;
        _categoryId = product.categoryId;
        _colorIds = product.colorIds.toSet();
      }
    });
  }

  /// Um produto novo tem de ter foto; um que já existe fica com a que tinha.
  bool get _missingPhoto => _original == null && _newPhoto == null;

  /// Sem cores, a encomenda não tinha cor para escolher e o custo não tinha preço por kg.
  bool get _missingColors => _colorIds.isEmpty;

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  /// A variante que está no cartão (a escolhida, ou a primeira). null num produto novo.
  Variant? _selectedVariant() {
    if (widget.productId == null) return null;
    final variants = ref.read(variantsProvider(widget.productId!)).value ?? <Variant>[];
    return variants.where((v) => v.id == _selectedVariantId).firstOrNull ?? variants.firstOrNull;
  }

  /// Há alguma coisa escrita que ainda não está gravada?
  bool _hasChanges() {
    final card = _cardKey.currentState;
    final original = _original;
    if (original == null) {
      return _nameController.text.trim().isNotEmpty ||
          _newPhoto != null ||
          _colorIds.isNotEmpty ||
          (card?.isChangedFrom(null) ?? false);
    }
    final selected = _selectedVariant();
    return _nameController.text.trim() != original.name ||
        _categoryId != original.categoryId ||
        _newPhoto != null ||
        !_sameColors(original.colorIds) ||
        (card != null && selected != null && card.isChangedFrom(selected));
  }

  bool _sameColors(List<int> saved) =>
      saved.length == _colorIds.length && saved.every(_colorIds.contains);

  /// "Tens alterações por gravar": Guardar, Descartar ou Cancelar.
  /// Devolve true se se pode seguir (gravou, ou deitou fora).
  Future<bool> _resolveChanges() async {
    if (!_hasChanges()) return true;
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Alterações por gravar"),
        content: const Text("Há alterações nesta ficha que ainda não foram gravadas."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          TextButton(onPressed: () => Navigator.pop(context, "discard"), child: const Text("Descartar")),
          FilledButton(onPressed: () => Navigator.pop(context, "save"), child: const Text("Guardar")),
        ],
      ),
    );
    if (choice == "discard") return true;
    if (choice == "save") return _save(close: false);
    return false; // cancelou
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

  /// Grava TUDO: o produto (nome, categoria, foto, cores) e a variante do cartão (receita e preço).
  /// Devolve true se ficou tudo gravado. [close]: fechar a ficha no fim.
  Future<bool> _save({bool close = true}) async {
    final card = _cardKey.currentState; // null para o colaborador (não vê o cartão)
    setState(() {
      _submitted = true;
      _cardProblem = card?.problem();
    });
    final isValid = _formKey.currentState!.validate();
    // a foto, as cores e o cartão não são campos do Form, por isso conferem-se à parte
    if (!isValid || _missingPhoto || _missingColors || _cardProblem != null) return false;

    setState(() => _saving = true);

    final products = ref.read(productRepositoryProvider);
    final variants = ref.read(variantRepositoryProvider);
    final name = _nameController.text.trim();
    final photo = _newPhoto;
    final colorIds = _colorIds.toList()..sort();
    final wasNew = _original == null;

    try {
      if (_original == null) {
        final created = await products.create(
          name: name,
          categoryId: _categoryId!,
          photo: photo!, // _missingPhoto já garantiu que existe
          colorIds: colorIds,
        );
        // a partir daqui o produto EXISTE: se a receita falhar, o "Guardar" seguinte não o duplica
        setState(() {
          _original = created;
          _newPhoto = null;
        });
      } else {
        final updated = await products.update(
          _original!.copyWith(
            name: name,
            categoryId: _categoryId,
            colorIds: colorIds,
            updatedAt: DateTime.now(),
          ),
        );
        // trocou a foto? vai num pedido à parte, depois dos dados
        final withPhoto = photo == null ? updated : await products.replacePhoto(updated.id, photo);
        setState(() {
          _original = withPhoto;
          _newPhoto = null;
        });
      }

      // a variante: a escolhida, ou a primeira; se o produto ainda não tiver nenhuma, cria-se
      // (o próprio produto, sem nome: SKU CD3-SEC-01)
      if (card != null) {
        final id = _original!.id;
        final list = await variants.fetchByProduct(id);
        var target = list.where((v) => v.id == _selectedVariantId).firstOrNull ?? list.firstOrNull;
        final isFresh = target == null;
        target ??= await variants.create(productId: id);
        if (isFresh || card.isChangedFrom(target)) {
          await variants.update(card.applyTo(target));
        }
        // as outras variantes: o custo passa a usar a cor mais cara das cores novas
        // (as gramas ficam as mesmas)
        final priciest = _calc.priciestFilament(ref.read(filamentsProvider).value ?? <Filament>[], colorIds);
        if (priciest != null) {
          for (final other in list.where((v) => v.id != target!.id)) {
            final grams = other.filaments.fold<int>(0, (sum, f) => sum + f.grams);
            if (grams <= 0) continue; // sem receita: fica para quando a abrires
            final same = other.filaments.length == 1 && other.filaments.single.filamentId == priciest.id;
            if (same) continue;
            await variants.update(
              other.copyWith(filaments: [VariantFilament(filamentId: priciest.id, grams: grams)]),
            );
          }
        }
      }
    } catch (error) {
      if (!mounted) return false;
      setState(() => _saving = false);
      final reason = error is ApiException ? error.message : "Tenta outra vez.";
      _showMessage(
        wasNew && _original != null
            // o produto ficou, a receita não: dizê-lo claramente (era um erro mudo)
            ? "O produto ficou criado, mas a receita e o preço não. Carrega em Guardar outra vez. ($reason)"
            : "Não foi possível guardar. $reason",
      );
      return false;
    } finally {
      // os dados podem ter sido gravados (mesmo que só uma parte): as listas vão buscá-los outra vez
      // (o "if (mounted)": depois de o ecrã fechar, o ref já não se pode usar)
      if (mounted) {
        ref.invalidate(productsProvider);
        ref.invalidate(allVariantsProvider);
        if (_original != null) ref.invalidate(variantsProvider(_original!.id));
      }
    }

    if (!mounted) return true;
    setState(() => _saving = false);
    _showMessage("Produto \"$name\" guardado.");
    if (close) Navigator.of(context).pop(); // pop direto: não passa pelo aviso de "por gravar"
    return true;
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

  /// As cores em que o produto se vende: um botão por filamento ativo.
  /// Na encomenda, o menu "Cor" mostra só estas; o custo usa a mais cara. Obrigatória pelo menos uma.
  Widget _colorsField(List<Filament> filaments) {
    final shown = filaments.where((f) => f.isActive || _colorIds.contains(f.id)).toList();
    return InputDecorator(
      decoration: InputDecoration(
        labelText: "Cores disponíveis",
        filled: false,
        errorText: _submitted && _missingColors ? "Escolhe pelo menos uma cor." : null,
        helperText: "Na encomenda escolhe-se uma destas. O custo do filamento usa a mais cara.",
        helperMaxLines: 2,
      ),
      child: shown.isEmpty
          ? const Text("Ainda não há filamentos (Custos e preços → Filamentos).")
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final f in shown)
                  FilterChip(
                    avatar: CircleAvatar(radius: 6, backgroundColor: colorFromHex(f.colorHex)),
                    label: Text("${f.colorName} · ${f.material}"),
                    selected: _colorIds.contains(f.id),
                    onSelected: (on) => setState(() {
                      _colorIds = {..._colorIds};
                      on ? _colorIds.add(f.id) : _colorIds.remove(f.id);
                    }),
                  ),
              ],
            ),
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
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // a abrir um produto que ainda não chegou, ou que já não existe: nada de formulário vazio
    // (gravá-lo criaria um produto novo)
    if (widget.productId != null && _original == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Produto")),
        body: Center(
          child: _loading
              ? const CircularProgressIndicator()
              : const Text("Este produto já não existe."),
        ),
      );
    }
    final categories = ref.watch(productCategoriesProvider).value ?? [];
    final filaments = ref.watch(filamentsProvider).value ?? <Filament>[];
    final isWide = MediaQuery.sizeOf(context).width >= 1100;
    // o colaborador só consulta: sem editar, sem apagar, sem calculadora
    final canSeeCosts = ref.watch(sessionProvider)?.canSeeCosts ?? false;

    // as variantes deste produto (só de um produto que já existia ao abrir a ficha)
    final existing = widget.productId != null && _original != null;
    final variants = existing
        ? ref.watch(variantsProvider(_original!.id)).value ?? <Variant>[]
        : <Variant>[];
    // a escolhida, ou a primeira se ainda não escolheste nenhuma
    final selectedVariant =
        variants.where((v) => v.id == _selectedVariantId).firstOrNull ?? variants.firstOrNull;

    // mudou a variante à vista (escolheu outra, ou as variantes acabaram de chegar): cartão novo.
    // Num produto novo, o cartão fica o mesmo do princípio ao fim, para o que se escreveu
    // não se perder entre gravar o produto e gravar a receita.
    if (widget.productId != null && selectedVariant?.id != _cardVariantId) {
      _cardKey = GlobalKey<CostCardState>();
      _cardVariantId = selectedVariant?.id;
    }
    final Widget? costCard = canSeeCosts
        ? CostCard(
            key: _cardKey,
            variant: widget.productId == null ? null : selectedVariant,
            showName: variants.length > 1 || (selectedVariant?.name.isNotEmpty ?? false),
            colorIds: _colorIds.toList(),
          )
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
      // o SKU não se escreve: nasce da categoria e da ordem (CD3-SEC-01)
      InputDecorator(
        decoration: InputDecoration(
          labelText: "SKU",
          filled: false,
          helperText: _original != null && _categoryId != _original!.categoryId
              ? "Ao mudar de categoria, o SKU muda (e o das variantes). Se o produto está na Etsy, atualiza lá."
              : "Automático: CD3, o código da categoria e o número.",
          helperMaxLines: 2,
        ),
        child: Text(
          _original?.baseSku ?? "Dado ao guardar",
          style: _original == null ? null : AppTextStyles.mono,
        ),
      ),
      if (canSeeCosts) ...[
        const SizedBox(height: 16),
        _colorsField(filaments),
        const SizedBox(height: 24),
        if (_submitted && _cardProblem != null) ...[
          Text(_cardProblem!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          const SizedBox(height: 8),
        ],
        FilledButton(
          onPressed: _saving ? null : () => _save(),
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("Guardar"),
        ),
        if (widget.productId == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "Grava o produto e a receita de uma vez. Variantes com nomes (ex.: Hamilton) "
              "juntam-se depois, ao editar.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
      if (existing) ...[
        const SizedBox(height: 24),
        VariantsSection(
          productId: _original!.id,
          selectedVariantId: selectedVariant?.id,
          // antes de mudar de variante (ou de criar outra), não deixar perder o que está escrito
          canLeave: _resolveChanges,
          onSelect: (v) => setState(() => _selectedVariantId = v.id),
        ),
      ],
    ];

    return PopScope(
      // ao sair com alterações por gravar, pergunta primeiro
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || _saving) return;
        if (!canSeeCosts || await _resolveChanges()) {
          if (context.mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.productId == null
                ? "Novo produto"
                : canSeeCosts
                    ? "Editar produto"
                    : "Produto",
          ),
          actions: [
            if (existing && canSeeCosts)
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
              // telemóvel, ou colaborador: tudo numa coluna (o cartão antes do Guardar não cabia:
              // fica por baixo, e o Guardar lê-o na mesma)
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    ...formFields,
                    if (costCard != null) ...[const SizedBox(height: 24), costCard],
                  ],
                ),
        ),
      ),
    );
  }
}
