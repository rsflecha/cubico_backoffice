import 'package:cubico_backoffice/features/etsy/domain/etsy_status.dart';

/// O contrato da ligação à Etsy. Há duas versões: a da API e a do modo demo.
abstract interface class EtsyRepository {
  /// A loja está ligada?
  Future<EtsyStatus> fetchStatus();

  /// Prepara a ligação e devolve o endereço da Etsy onde se autoriza a app.
  Future<Uri> startConnect();

  /// Desliga a loja (as encomendas deixam de entrar sozinhas).
  Future<void> disconnect();
}
