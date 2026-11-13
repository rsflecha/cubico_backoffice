import 'package:cubico_backoffice/app/theme.dart';
import 'package:cubico_backoffice/core/api/api_exception.dart';
import 'package:cubico_backoffice/features/products/presentation/products_providers.dart';
import 'package:cubico_backoffice/features/products/presentation/widgets/category_dialog.dart';
import 'package:cubico_backoffice/features/products/presentation/widgets/product_photo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Olha para a placa e recebe a "caixa" com o estado da lista.
    final products = ref.watch(productsProvider);
    final categories = ref.watch(productCategoriesProvider).value ?? [];
    final selected = ref.watch(selectedCategoryProvider);
    final canSeeCosts = ref.watch(sessionProvider)?.canSeeCosts ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Produtos"),
        centerTitle: true,
        actions: [
          if (canSeeCosts)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton.icon(
                onPressed: () => context.push("/products/new"),
                icon: const Icon(Icons.add),
                label: const Text("Novo produto"),
              ),
            ),
        ],
      ),

      body: Column(
        children: [
          // 1. a fila de botões
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text("Todas"),
                  selected: selected == null,
                  onSelected: (_) =>
                      ref.read(selectedCategoryProvider.notifier).select(null),
                ),
                for (final category in categories) ...[
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(category.name),
                    selected: selected == category.id,
                    onSelected: (_) => ref
                        .read(selectedCategoryProvider.notifier)
                        .select(category.id),
                  ),
                ],
                if (canSeeCosts) ...[
                const SizedBox(width: 8),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: const Text("Nova"),
                  onPressed: () async {
                    // 1. abre a janela e espera pela resposta
                    final name = await showDialog<String>(
                      context: context,
                      builder: (context) => const CategoryDialog(),
                    );

                    // 2. se cancelou ou deixou vazio, não faz nada
                    if (name == null || name.trim().isEmpty) return;
                    // depois do await da janela, o ecrã pode já ter fechado
                    if (!context.mounted) return;

                    // 3. pede ao balcão para criar (se falhar, mostra o erro e pára)
                    final ok = await _tryCategory(
                      context,
                      () => ref
                          .read(productCategoryRepositoryProvider)
                          .create(name: name.trim()),
                    );
                    if (!ok) return;

                    // 4. diz ao Riverpod que a lista mudou, para a ir buscar outra vez
                    ref.invalidate(productCategoriesProvider);
                  },
                ),
                if (selected != null) ...[
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text("Editar"),
                    onPressed: () async {
                      // a categoria escolhida, completa
                      final category = categories.firstWhere(
                        (c) => c.id == selected,
                      );

                      final name = await showDialog<String>(
                        context: context,
                        builder: (context) => CategoryDialog(
                          title: "Editar categoria",
                          confirmLabel: "Guardar",
                          initialName: category.name,
                        ),
                      );
                      if (name == null || name.trim().isEmpty) return;
                      if (!context.mounted) return;

                      final ok = await _tryCategory(
                        context,
                        () => ref
                            .read(productCategoryRepositoryProvider)
                            .update(category.copyWith(name: name.trim())),
                      );
                      if (!ok) return;
                      ref.invalidate(productCategoriesProvider);
                    },
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.delete_outline, size: 18),
                    label: const Text("Apagar"),
                    onPressed: () async {
                      final category = categories.firstWhere(
                        (c) => c.id == selected,
                      );

                      // quantos produtos tem esta categoria?
                      final allProducts =
                          ref.read(productsProvider).value ?? [];
                      final count = allProducts
                          .where((p) => p.categoryId == selected)
                          .length;

                      if (count > 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "\"${category.name}\" tem $count produto(s). "
                              "Muda-os de categoria antes de a apagar.",
                            ),
                          ),
                        );
                        return;
                      }

                      // pedir confirmação
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Apagar categoria?"),
                          content: Text(
                            "A categoria \"${category.name}\" vai ser apagada.",
                          ),
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

                      if (!context.mounted) return;
                      final ok = await _tryCategory(
                        context,
                        () => ref
                            .read(productCategoryRepositoryProvider)
                            .delete(category.id),
                      );
                      if (!ok) return;
                      ref
                          .read(selectedCategoryProvider.notifier)
                          .select(null); // volta a "Todas"
                      ref.invalidate(productCategoriesProvider);
                    },
                  ),
                ],
              ],
              ],
            )
          ),
          // 2. a lista, filtrada
          Expanded(
            child: products.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text("Erro: $error")),
              data: (list) {
                final visible = selected == null
                    ? list
                    : list.where((p) => p.categoryId == selected).toList();
                if (visible.isEmpty) {
                  return const Center(
                    child: Text("Ainda não há produtos nesta categoria."),
                  );
                }
                return ListView.builder(
                  itemCount: visible.length,
                  itemBuilder: (context, index) {
                    final product = visible[index];
                    return ListTile(
                      leading: ProductPhoto(url: product.photoUrl),
                      title: Text(product.name),
                      subtitle: Text(
                        product.baseSku,
                        style: AppTextStyles.mono,
                      ),
                      onTap: () => context.push("/products/${product.id}"),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Corre uma gravação de categorias. Se falhar, mostra a mensagem e devolve false.
Future<bool> _tryCategory(BuildContext context, Future<void> Function() action) async {
  try {
    await action();
    return true;
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is ApiException
                ? error.message
                : "Não foi possível guardar. Tenta outra vez.",
          ),
        ),
      );
    }
    return false;
  }
}
