import 'package:cubico_backoffice/features/costs/domain/cost_settings.dart';

abstract interface class CostSettingsRepository {
  Future<CostSettings> fetch();
  Future<CostSettings> save(CostSettings settings);
}