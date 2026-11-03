import 'package:cubico_backoffice/features/costs/domain/sales_channel.dart';

abstract interface class SalesChannelRepository {
  Future<List<SalesChannel>> fetchAll();
}