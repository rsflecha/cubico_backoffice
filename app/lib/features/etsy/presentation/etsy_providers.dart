import 'package:cubico_backoffice/core/api/api_client.dart';
import 'package:cubico_backoffice/features/auth/presentation/auth_providers.dart';
import 'package:cubico_backoffice/features/etsy/data/api_etsy_repository.dart';
import 'package:cubico_backoffice/features/etsy/data/demo_etsy_repository.dart';
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

/// A última sincronização, para a barra das Encomendas (todos a veem).
final etsySyncInfoProvider = FutureProvider<EtsySyncInfo>(
  (ref) => ref.watch(etsyRepositoryProvider).fetchSyncInfo(),
);
