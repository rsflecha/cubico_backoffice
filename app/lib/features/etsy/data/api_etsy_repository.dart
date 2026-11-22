import 'package:cubico_backoffice/core/api/api_exception.dart';
import 'package:cubico_backoffice/features/etsy/domain/etsy_listings_check.dart';
import 'package:cubico_backoffice/features/etsy/domain/etsy_repository.dart';
import 'package:cubico_backoffice/features/etsy/domain/etsy_status.dart';
import 'package:cubico_backoffice/features/etsy/domain/etsy_sync.dart';
import 'package:dio/dio.dart';

/// A ligação à Etsy, através da API (é a API que fala com a Etsy, nunca a app).
class ApiEtsyRepository implements EtsyRepository {
  ApiEtsyRepository(this._dio);

  final Dio _dio;

  @override
  Future<EtsyStatus> fetchStatus() => apiCall(() async {
        final response = await _dio.get<Map<String, dynamic>>("/etsy/status");
        return EtsyStatus.fromJson(response.data!);
      });

  @override
  Future<Uri> startConnect() => apiCall(() async {
        final response = await _dio.post<Map<String, dynamic>>("/etsy/connect");
        return Uri.parse(response.data!["url"] as String);
      });

  @override
  Future<void> disconnect() => apiCall(() async {
        await _dio.delete<void>("/etsy/connection");
      });

  @override
  Future<EtsySyncInfo> fetchSyncInfo() => apiCall(() async {
        final response = await _dio.get<Map<String, dynamic>>("/etsy/sync");
        return EtsySyncInfo.fromJson(response.data!);
      });

  @override
  Future<EtsySyncRun> syncNow() => apiCall(() async {
        // pode demorar (a Etsy responde página a página): mais tempo do que o habitual
        final response = await _dio.post<Map<String, dynamic>>(
          "/etsy/sync",
          options: Options(receiveTimeout: const Duration(minutes: 2)),
        );
        return EtsySyncRun.fromJson(response.data!["last"] as Map<String, dynamic>);
      });

  @override
  Future<EtsyListingsCheck> checkListings() => apiCall(() async {
        // a Etsy responde página a página (100 anúncios de cada vez): mais tempo do que o habitual
        final response = await _dio.get<Map<String, dynamic>>(
          "/etsy/listings-check",
          options: Options(receiveTimeout: const Duration(minutes: 1)),
        );
        return EtsyListingsCheck.fromJson(response.data!);
      });

  @override
  Future<void> link({required String productId, required String listingId, required int variantId}) =>
      apiCall(() async {
        await _dio.put<void>("/etsy/links/$productId", data: {"listing_id": listingId, "variant_id": variantId});
      });

  @override
  Future<void> unlink(String productId) => apiCall(() async {
        await _dio.delete<void>("/etsy/links/$productId");
      });
}
