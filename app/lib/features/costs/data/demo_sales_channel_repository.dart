import 'package:cubico_backoffice/features/costs/domain/sales_channel.dart';
import 'package:cubico_backoffice/features/costs/domain/sales_channel_repository.dart';

class DemoSalesChannelRepository implements SalesChannelRepository {
  final List<SalesChannel> _items = [
    SalesChannel(
      id: 1,
      code: "etsy",
      name: "Etsy",
      transactionFee: 6.5,
      processingFee: 4,
      flatFee: 0.30,
      listingFee: 0.20,
      isAutomatic: true,
    ),
    SalesChannel(id: 2, code: "instagram", name: "Instagram"),
    SalesChannel(id: 3, code: "facebook", name: "Facebook"),
    SalesChannel(id: 4, code: "in_person", name: "Pessoalmente"),
  ];

  Future<void> _latency() => Future.delayed(const Duration(milliseconds: 300));

  @override
  Future<List<SalesChannel>> fetchAll() async {
    await _latency();
    return List<SalesChannel>.of(_items);
  }

  @override
  Future<SalesChannel> update(SalesChannel channel) async {
    await _latency();
    final index = _items.indexWhere((c) => c.id == channel.id);
    if (index == -1) throw StateError("Canal ${channel.id} não existe.");
    _items[index] = channel;
    return channel;
  }
}