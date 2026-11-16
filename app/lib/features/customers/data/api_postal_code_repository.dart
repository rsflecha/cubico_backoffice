import 'package:cubico_backoffice/core/api/api_exception.dart';
import 'package:cubico_backoffice/features/customers/domain/postal_code.dart';
import 'package:dio/dio.dart';

/// A localidade de um código postal, perguntada à API (que tem a base dos CTT).
class ApiPostalCodeRepository implements PostalCodeRepository {
  ApiPostalCodeRepository(this._dio);

  final Dio _dio;

  @override
  Future<PostalCodeInfo?> lookup(String postalCode) => apiCall(() async {
        try {
          final response = await _dio.get<Map<String, dynamic>>("/postal-codes/$postalCode");
          return PostalCodeInfo.fromJson(response.data!);
        } on DioException catch (e) {
          // 404 = o código não existe: não é um erro, é uma resposta
          if (e.response?.statusCode == 404) return null;
          rethrow;
        }
      });
}
