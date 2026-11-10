import 'package:cubico_backoffice/core/api/api_table.dart';
import 'package:cubico_backoffice/features/costs/domain/shipping_rate.dart';
import 'package:cubico_backoffice/features/costs/domain/shipping_rate_repository.dart';
import 'package:dio/dio.dart';

/// Os escalões de portes, vindos da API.
class ApiShippingRateRepository implements ShippingRateRepository {
  ApiShippingRateRepository(Dio dio)
      : _table = ApiTable(dio, "/shipping-rates", ShippingRate.fromJson);

  final ApiTable<ShippingRate> _table;

  @override
  Future<List<ShippingRate>> fetchAll() => _table.fetchAll();

  @override
  Future<ShippingRate> update(ShippingRate shippingRate) =>
      _table.update(shippingRate.id, shippingRate.toJson());
}
