import 'shipping_rate.dart';

abstract interface class ShippingRateRepository {
  Future<List<ShippingRate>> fetchAll();

  Future<ShippingRate> update(ShippingRate shippingRate);
}
