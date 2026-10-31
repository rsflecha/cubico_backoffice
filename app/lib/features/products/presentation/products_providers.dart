import 'package:cubico_backoffice/features/products/data/demo_product_category_repository.dart';
import 'package:cubico_backoffice/features/products/domain/product_category.dart';
import 'package:cubico_backoffice/features/products/domain/product_category_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/demo_product_repository.dart';
import '../domain/product.dart';
import '../domain/product_repository.dart';

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

/// Placa 3: qual é o repositório dos produtos.
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return DemoProductRepository();
});

/// Placa 4: a lista de produtos, vinda do repositório.
final productsProvider = FutureProvider<List<Product>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.fetchAll();
});