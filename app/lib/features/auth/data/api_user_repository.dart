import 'package:cubico_backoffice/core/api/api_exception.dart';
import 'package:cubico_backoffice/features/auth/domain/app_user.dart';
import 'package:cubico_backoffice/features/auth/domain/user_repository.dart';
import 'package:dio/dio.dart';

/// Os utilizadores, vindos da API.
class ApiUserRepository implements UserRepository {
  ApiUserRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<AppUser>> fetchAll() => apiCall(() async {
        final response = await _dio.get<List<dynamic>>("/users");
        return [for (final item in response.data!) AppUser.fromJson(item as Map<String, dynamic>)];
      });

  @override
  Future<({AppUser user, String? temporaryPassword})> create(AppUser draft) => apiCall(() async {
        final response = await _dio.post<Map<String, dynamic>>(
          "/users",
          data: {"name": draft.name, "email": draft.email, "role": draft.role.name},
        );
        final data = response.data!;
        return (
          user: AppUser.fromJson(data["user"] as Map<String, dynamic>),
          temporaryPassword: data["temporary_password"] as String?,
        );
      });

  @override
  Future<AppUser> update(AppUser user) => apiCall(() async {
        final response = await _dio.put<Map<String, dynamic>>(
          "/users/${user.id}",
          data: {"name": user.name, "role": user.role.name},
        );
        return AppUser.fromJson(response.data!);
      });

  @override
  Future<void> delete(int id) => apiCall(() async {
        await _dio.delete<void>("/users/$id");
      });
}
