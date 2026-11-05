import 'package:cubico_backoffice/features/costs/domain/cost_settings.dart';
import 'package:cubico_backoffice/features/costs/domain/cost_settings_repository.dart';

class DemoCostSettingsRepository implements CostSettingsRepository {
  // os valores do seed.sql
  CostSettings _settings = const CostSettings(kwhPrice: 0.21);

  Future<void> _latency() => Future.delayed(const Duration(milliseconds: 300));

  @override
  Future<CostSettings> fetch() async {
    await _latency();
    return _settings;
  }

  @override
  Future<CostSettings> save(CostSettings settings) async {
    await _latency();
    _settings = settings;
    return settings;
  }
}