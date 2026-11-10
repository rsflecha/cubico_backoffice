import 'package:cubico_backoffice/core/api/api_table.dart';
import 'package:cubico_backoffice/features/costs/domain/filament.dart';
import 'package:cubico_backoffice/features/costs/domain/filament_repository.dart';
import 'package:dio/dio.dart';

/// Os filamentos, vindos da API.
class ApiFilamentRepository implements FilamentRepository {
  ApiFilamentRepository(Dio dio) : _table = ApiTable(dio, "/filaments", Filament.fromJson);

  final ApiTable<Filament> _table;

  @override
  Future<List<Filament>> fetchAll() => _table.fetchAll();

  @override
  Future<Filament> create(Filament draft) => _table.create(draft.toJson());

  @override
  Future<Filament> update(Filament filament) => _table.update(filament.id, filament.toJson());
}
