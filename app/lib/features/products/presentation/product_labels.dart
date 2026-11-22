import 'package:cubico_backoffice/features/products/domain/product.dart';

/// O nome de cada estado do produto, como aparece no ecrã.
/// Ativo = à venda; Rascunho = ainda a preparar; Arquivado = já não se vende.
String productStatusLabel(ProductStatus status) => switch (status) {
      ProductStatus.active => "Ativo",
      ProductStatus.draft => "Rascunho",
      ProductStatus.archived => "Arquivado",
    };
