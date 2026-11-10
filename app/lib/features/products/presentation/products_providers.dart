import 'package:cubico_backoffice/features/products/data/api_product_repository.dart';
import 'package:cubico_backoffice/features/products/data/api_variant_repository.dart';
import 'package:cubico_backoffice/core/api/api_client.dart';
import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:cubico_backoffice/features/products/data/api_product_category_repository.dart';
import 'package:cubico_backoffice/features/products/data/demo_product_category_repository.dart';
import 'package:cubico_backoffice/features/products/domain/product_category.dart';
import 'package:cubico_backoffice/features/products/domain/product_category_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cubico_backoffice/features/products/data/demo_product_repository.dart';
import 'package:cubico_backoffice/features/products/data/demo_variant_repository.dart';
import 'package:cubico_backoffice/features/products/domain/product.dart';
import 'package:cubico_backoffice/features/products/domain/product_repository.dart';
import 'package:cubico_backoffice/features/products/domain/variant.dart';
import 'package:cubico_backoffice/features/products/domain/variant_repository.dart';

/// Qual é o repositório das categorias: os dados de exemplo no modo demo, a API numa sessão a sério.
final productCategoryRepositoryProvider = Provider<ProductCategoryRepository>((ref) {
  if (ref.watch(demoModeProvider)) return DemoProductCategoryRepository();
  return ApiProductCategoryRepository(ref.watch(dioProvider));
});

/// A lista de categorias, vinda do repositório.
/// É FutureProvider porque o fetchAll() demora (devolve um Future).
final productCategoriesProvider = FutureProvider<List<ProductCategory>>((ref) {
  final repository = ref.watch(productCategoryRepositoryProvider);
  return repository.fetchAll();
});

/// Qual é o repositório dos produtos.
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  if (ref.watch(demoModeProvider)) return DemoProductRepository();
  return ApiProductRepository(ref.watch(dioProvider));
});

/// A lista de produtos, vinda do repositório.
final productsProvider = FutureProvider<List<Product>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.fetchAll();
});

/// Guarda a categoria escolhida no filtro. null = "Todas".
class SelectedCategoryNotifier extends Notifier<int?> {
  @override
  int? build() => null; // valor inicial: nenhuma escolhida (Todas)

  void select(int? categoryId) {
    state = categoryId;
  }
}

/// A categoria escolhida no filtro.
final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, int?>(
      SelectedCategoryNotifier.new,
    );

/// Qual é o repositório das variantes.
final variantRepositoryProvider = Provider<VariantRepository>((ref) {
  if (ref.watch(demoModeProvider)) return DemoVariantRepository();
  return ApiVariantRepository(ref.watch(dioProvider));
});

/// As variantes de um produto (uma "gaveta" por produto).
final variantsProvider = FutureProvider.family<List<Variant>, int>((
  ref,
  productId,
) {
  final repository = ref.watch(variantRepositoryProvider);
  return repository.fetchByProduct(productId);
});

/// Todas as variantes da loja (para mostrar nomes nas encomendas).
final allVariantsProvider = FutureProvider<List<Variant>>((ref) {
  final repository = ref.watch(variantRepositoryProvider);
  return repository.fetchAll();
});
