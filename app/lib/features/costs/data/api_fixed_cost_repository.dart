import 'package:cubico_backoffice/core/api/api_exception.dart';
import 'package:cubico_backoffice/core/api/api_table.dart';
import 'package:cubico_backoffice/features/costs/domain/fixed_cost.dart';
import 'package:cubico_backoffice/features/costs/domain/fixed_cost_repository.dart';
import 'package:dio/dio.dart';

/// Os custos fixos mensais, vindos da API.
class ApiFixedCostRepository implements FixedCostRepository {
  ApiFixedCostRepository(this._dio) : _table = ApiTable(_dio, "/fixed-costs", FixedCost.fromJson);

  final Dio _dio;
  final ApiTable<FixedCost> _table;

  @override
  Future<List<FixedCost>> fetchAll() => _table.fetchAll();

  @override
  Future<FixedCost> create(FixedCost draft) => _table.create(draft.toJson());

  @override
  Future<FixedCost> update(FixedCost cost) => _table.update(cost.id, cost.toJson());

  @override
  Future<void> delete(int id) => apiCall(() async {
        await _dio.delete<void>("/fixed-costs/$id");
      });
}
