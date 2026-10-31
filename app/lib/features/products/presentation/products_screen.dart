import 'package:cubico_backoffice/features/products/presentation/products_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Olha para a placa e recebe a "caixa" com o estado da lista.
    final categories = ref.watch(productCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        centerTitle: true,
      ),
      // Um ecrã diferente para cada estado da caixa.
      body: categories.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erro: $error')),
        data: (list) => ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            final category = list[index];
            return ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: Text(category.name),
            );
          },
        ),
      ),
    );
  }
}