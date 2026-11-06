import '../domain/shipping_rate.dart';
import '../domain/shipping_rate_repository.dart';

class DemoShippingRateRepository implements ShippingRateRepository {
  final List<ShippingRate> _items = [
    // 1 · Portugal · CTT Correio Registado (preço base 2026)
    const ShippingRate(id: 1, zoneId: 1, maxWeightG: 100, price: 4.60),
    const ShippingRate(id: 2, zoneId: 1, maxWeightG: 500, price: 5.40),
    const ShippingRate(id: 3, zoneId: 1, maxWeightG: 2000, price: 8.93),

    // 2 · Europa · CTT Correio Azul Internacional
    const ShippingRate(id: 4, carrierId: 2, zoneId: 2, maxWeightG: 100, price: 5.80),
    const ShippingRate(id: 5, carrierId: 2, zoneId: 2, maxWeightG: 250, price: 7.55),
    const ShippingRate(id: 6, carrierId: 2, zoneId: 2, maxWeightG: 500, price: 9.80),
    const ShippingRate(id: 7, carrierId: 2, zoneId: 2, maxWeightG: 1000, price: 13.20),
    const ShippingRate(id: 8, carrierId: 2, zoneId: 2, maxWeightG: 2000, price: 21.20),

    // 3 · Estados Unidos · CTT Correio Azul Internacional
    const ShippingRate(id: 9, carrierId: 2, zoneId: 3, maxWeightG: 100, price: 6.95),
    const ShippingRate(id: 10, carrierId: 2, zoneId: 3, maxWeightG: 250, price: 10.10),
    const ShippingRate(id: 11, carrierId: 2, zoneId: 3, maxWeightG: 500, price: 15.70),
    const ShippingRate(id: 12, carrierId: 2, zoneId: 3, maxWeightG: 1000, price: 26.75),
    const ShippingRate(id: 13, carrierId: 2, zoneId: 3, maxWeightG: 2000, price: 39.25),

    // 4 · Resto do mundo · CTT Correio Azul Internacional
    const ShippingRate(id: 14, carrierId: 2, zoneId: 4, maxWeightG: 100, price: 6.55),
    const ShippingRate(id: 15, carrierId: 2, zoneId: 4, maxWeightG: 250, price: 9.30),
    const ShippingRate(id: 16, carrierId: 2, zoneId: 4, maxWeightG: 500, price: 14.15),
    const ShippingRate(id: 17, carrierId: 2, zoneId: 4, maxWeightG: 1000, price: 23.95),
    const ShippingRate(id: 18, carrierId: 2, zoneId: 4, maxWeightG: 2000, price: 36.15),
  ];

  @override
  Future<ShippingRate> update(ShippingRate shippingRate) async {
    await _latency();
    final index = _items.indexWhere((f) => f.id == shippingRate.id);
    if (index == -1) throw StateError("Portes de envio ${shippingRate.id} não existe.");
    _items[index] = shippingRate;
    return shippingRate;
  }

  Future<void> _latency() => Future.delayed(const Duration(milliseconds: 300));

  @override
  Future<List<ShippingRate>> fetchAll() async {
    await _latency();
    return List<ShippingRate>.of(_items);
  }
}
