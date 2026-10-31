import 'package:cubico_backoffice/app/theme.dart';
import 'package:cubico_backoffice/features/products/presentation/products_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // Olha para a placa e recebe a "caixa" com o estado da lista.
    final products = ref.watch(productsProvider);
    final categories = ref.watch(productCategoriesProvider).value ?? [];
    final selected = ref.watch(selectedCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        centerTitle: true,
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
                  label: const Text('Todas'),
                  selected: selected == null,
                  onSelected: (_) => ref.read(selectedCategoryProvider.notifier).select(null),
                ),
                for (final category in categories) ...[
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(category.name),
                    selected: selected == category.id,
                    onSelected: (_) =>
                        ref.read(selectedCategoryProvider.notifier).select(category.id),
                  ),
                ],
              ],
            ),
          ),
          // 2. a lista, filtrada
          Expanded(
            child: products.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Erro: $error')),
              data: (list) {
                final visible = selected == null
                    ? list
                    : list.where((p) => p.categoryId == selected).toList();
                return ListView.builder(
                  itemCount: visible.length,
                  itemBuilder: (context, index) {
                    final product = visible[index];
                    return ListTile(
                      leading: const Icon(Icons.folder_outlined),
                      title: Text(product.name),
                      subtitle: Text(product.baseSku, style: AppTextStyles.mono),
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