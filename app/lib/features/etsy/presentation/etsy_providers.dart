import 'package:cubico_backoffice/core/api/api_client.dart';
import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:cubico_backoffice/features/etsy/data/api_etsy_repository.dart';
import 'package:cubico_backoffice/features/etsy/data/demo_etsy_repository.dart';
import 'package:cubico_backoffice/features/etsy/domain/etsy_listings_check.dart';
import 'package:cubico_backoffice/features/etsy/domain/etsy_repository.dart';
import 'package:cubico_backoffice/features/etsy/domain/etsy_status.dart';
import 'package:cubico_backoffice/features/etsy/domain/etsy_sync.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Qual é o repositório da Etsy: o da demo ou o da API.
final etsyRepositoryProvider = Provider<EtsyRepository>((ref) {
  if (ref.watch(demoModeProvider)) return DemoEtsyRepository();
  return ApiEtsyRepository(ref.watch(dioProvider));
});

/// O estado da ligação à Etsy (só o administrador o pede).
final etsyStatusProvider = FutureProvider<EtsyStatus>(
  (ref) => ref.watch(etsyRepositoryProvider).fetchStatus(),
);

/// "Conferir os SKU" (só o administrador). autoDispose: cada vez que se abre o ecrã,
/// pergunta outra vez à Etsy (os anúncios podem ter mudado entretanto).
/// Sem "retry": por omissão, o Riverpod 3 repete sozinho um provider que falha (até 10 vezes,
/// cada vez mais espaçadas) e, entretanto, o ecrã fica "a carregar" em vez de mostrar o erro.
/// Aqui o erro (ex.: ligação sem autorização) tem de aparecer logo, e não vale a pena
/// incomodar a Etsy 10 vezes: quem tenta outra vez é o Rui, com o botão.
final etsyListingsCheckProvider = FutureProvider.autoDispose<EtsyListingsCheck>(
  (ref) => ref.watch(etsyRepositoryProvider).checkListings(),
  retry: (retryCount, error) => null,
);

/// A última sincronização, para a barra das Encomendas (todos a veem).
final etsySyncInfoProvider = FutureProvider<EtsySyncInfo>(
  (ref) => ref.watch(etsyRepositoryProvider).fetchSyncInfo(),
);
