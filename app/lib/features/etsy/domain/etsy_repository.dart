import 'package:cubico_backoffice/features/etsy/domain/etsy_listings_check.dart';
import 'package:cubico_backoffice/features/etsy/domain/etsy_status.dart';
import 'package:cubico_backoffice/features/etsy/domain/etsy_sync.dart';

/// O contrato da ligação à Etsy. Há duas versões: a da API e a do modo demo.
abstract interface class EtsyRepository {
  /// A loja está ligada?
  Future<EtsyStatus> fetchStatus();

  /// Prepara a ligação e devolve o endereço da Etsy onde se autoriza a app.
  Future<Uri> startConnect();

  /// Desliga a loja (as encomendas deixam de entrar sozinhas).
  Future<void> disconnect();

  /// A última sincronização (para a barra das Encomendas).
  Future<EtsySyncInfo> fetchSyncInfo();

  /// "Sincronizar agora": vai buscar as encomendas novas e devolve o registo desta vez.
  Future<EtsySyncRun> syncNow();

  /// "Conferir os SKU": os anúncios ativos da Etsy contra as variantes da app (só lê).
  Future<EtsyListingsCheck> checkListings();

  /// Associa à mão um produto de um anúncio a uma variante (quando o SKU não serve).
  /// As vendas que ficaram por associar entram na próxima sincronização.
  Future<void> link({required String productId, required String listingId, required int variantId});

  /// Desfaz a associação feita à mão.
  Future<void> unlink(String productId);
}
