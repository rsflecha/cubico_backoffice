import 'package:cubico_backoffice/core/api/api_exception.dart';
import 'package:cubico_backoffice/features/stock/domain/filament_movement.dart';
import 'package:cubico_backoffice/features/stock/domain/filament_stock.dart';
import 'package:cubico_backoffice/features/stock/domain/stock_repository.dart';
import 'package:dio/dio.dart';

/// O stock de filamento, vindo da API.
class ApiStockRepository implements StockRepository {
  ApiStockRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<FilamentStock>> fetchStock() => apiCall(() async {
        final response = await _dio.get<List<dynamic>>("/filaments/stock");
        return response.data!.map((e) => FilamentStock.fromJson(e as Map<String, dynamic>)).toList();
      });

  @override
  Future<List<FilamentMovement>> fetchMovements(int filamentId) => apiCall(() async {
        final response = await _dio.get<List<dynamic>>("/filaments/$filamentId/movements");
        return response.data!.map((e) => FilamentMovement.fromJson(e as Map<String, dynamic>)).toList();
      });

  @override
  Future<FilamentMovement> recordPurchase(
    int filamentId, {
    required int spools,
    required double paidPrice,
    required double shippingCost,
  }) =>
      apiCall(() async {
        final response = await _dio.post<Map<String, dynamic>>(
          "/filaments/$filamentId/purchases",
          data: {"spools": spools, "paid_price": paidPrice, "shipping_cost": shippingCost},
        );
        return FilamentMovement.fromJson(response.data!);
      });

  @override
  Future<FilamentMovement> recordAdjustment(
    int filamentId, {
    required int closedSpools,
    required List<double> openGrossG,
    String? note,
  }) =>
      apiCall(() async {
        final response = await _dio.post<Map<String, dynamic>>(
          "/filaments/$filamentId/adjustments",
          data: {
            "closed_spools": closedSpools,
            "open_gross_g": openGrossG,
            "note": ?note,
          },
        );
        return FilamentMovement.fromJson(response.data!);
      });
}
