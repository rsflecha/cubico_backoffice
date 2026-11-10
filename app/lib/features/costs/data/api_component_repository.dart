import 'package:cubico_backoffice/core/api/api_table.dart';
import 'package:cubico_backoffice/features/costs/domain/component.dart';
import 'package:cubico_backoffice/features/costs/domain/component_repository.dart';
import 'package:dio/dio.dart';

/// As embalagens e os componentes, vindos da API.
class ApiComponentRepository implements ComponentRepository {
  ApiComponentRepository(Dio dio) : _table = ApiTable(dio, "/components", Component.fromJson);

  final ApiTable<Component> _table;

  @override
  Future<List<Component>> fetchAll() => _table.fetchAll();

  @override
  Future<Component> create(Component draft) => _table.create(draft.toJson());

  @override
  Future<Component> update(Component component) => _table.update(component.id, component.toJson());
}
