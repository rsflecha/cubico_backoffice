import 'package:cubico_backoffice/core/api/api_exception.dart';
import 'package:dio/dio.dart';

/// Os pedidos habituais de uma tabela simples da API: a lista, criar e mudar.
/// É o par do tableRoutes() da API: escrito uma vez, usado por vários repositórios.
///
/// O <T> é o modelo (Filament, Component…), e o fromJson diz como o construir a partir do JSON.
class ApiTable<T> {
  ApiTable(this._dio, this._path, this._fromJson);

  final Dio _dio;
  final String _path; // ex.: "/filaments"
  final T Function(Map<String, dynamic> json) _fromJson;

  Future<List<T>> fetchAll() => apiCall(() async {
        final response = await _dio.get<List<dynamic>>(_path);
        return [for (final item in response.data!) _fromJson(item as Map<String, dynamic>)];
      });

  Future<T> create(Map<String, dynamic> json) => apiCall(() async {
        final response = await _dio.post<Map<String, dynamic>>(_path, data: json);
        return _fromJson(response.data!);
      });

  Future<T> update(int id, Map<String, dynamic> json) => apiCall(() async {
        final response = await _dio.put<Map<String, dynamic>>("$_path/$id", data: json);
        return _fromJson(response.data!);
      });
}
