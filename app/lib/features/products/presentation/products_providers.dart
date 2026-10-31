import 'package:cubico_backoffice/features/products/data/demo_product_category_repository.dart';
import 'package:cubico_backoffice/features/products/domain/product_category.dart';
import 'package:cubico_backoffice/features/products/domain/product_category_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Placa 1: qual é o repositório das categorias.
/// Na Fatia 11 troca-se aqui o Demo pelo Api, e mais nada muda.
final productCategoryRepositoryProvider = Provider<ProductCategoryRepository>((ref) {
  return DemoProductCategoryRepository();
});

/// Placa 2: a lista de categorias, vinda do repositório.
/// É FutureProvider porque o fetchAll() demora (devolve um Future).
final productCategoriesProvider = FutureProvider<List<ProductCategory>>((ref) {
  final repository = ref.watch(productCategoryRepositoryProvider);
  return repository.fetchAll();
});