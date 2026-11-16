import 'package:cubico_backoffice/core/api/api_exception.dart';
import 'package:cubico_backoffice/features/etsy/domain/etsy_repository.dart';
import 'package:cubico_backoffice/features/etsy/domain/etsy_status.dart';
import 'package:cubico_backoffice/features/etsy/domain/etsy_sync.dart';

/// No modo demo não há servidor, por isso não há Etsy: a loja aparece desligada
/// e ligar explica porquê.
class DemoEtsyRepository implements EtsyRepository {
  @override
  Future<EtsyStatus> fetchStatus() async => const EtsyStatus(configured: true);

  @override
  Future<Uri> startConnect() async =>
      throw const ApiException("No modo demo não há ligação à Etsy. Entra com a tua conta.");

  @override
  Future<void> disconnect() async {}

  @override
  Future<EtsySyncInfo> fetchSyncInfo() async => const EtsySyncInfo();

  @override
  Future<EtsySyncRun> syncNow() async =>
      throw const ApiException("No modo demo não há ligação à Etsy. Entra com a tua conta.");
}
