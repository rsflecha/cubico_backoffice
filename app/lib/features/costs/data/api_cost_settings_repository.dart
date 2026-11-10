import 'package:cubico_backoffice/core/api/api_exception.dart';
import 'package:cubico_backoffice/features/costs/domain/cost_settings.dart';
import 'package:cubico_backoffice/features/costs/domain/cost_settings_repository.dart';
import 'package:dio/dio.dart';

/// As definições de custos, vindas da API (um objeto só, e não uma lista).
class ApiCostSettingsRepository implements CostSettingsRepository {
  ApiCostSettingsRepository(this._dio);

  final Dio _dio;

  @override
  Future<CostSettings> fetch() => apiCall(() async {
        final response = await _dio.get<Map<String, dynamic>>("/settings");
        return CostSettings.fromJson(response.data!);
      });

  @override
  Future<CostSettings> save(CostSettings settings) => apiCall(() async {
        final response = await _dio.put<Map<String, dynamic>>("/settings", data: settings.toJson());
        return CostSettings.fromJson(response.data!);
      });
}
