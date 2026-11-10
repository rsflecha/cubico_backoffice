import 'package:cubico_backoffice/core/api/api_table.dart';
import 'package:cubico_backoffice/features/costs/domain/sales_channel.dart';
import 'package:cubico_backoffice/features/costs/domain/sales_channel_repository.dart';
import 'package:dio/dio.dart';

/// Os canais de venda, vindos da API.
/// Para o colaborador, a API não manda as taxas: ficam a 0 (o @Default do modelo).
class ApiSalesChannelRepository implements SalesChannelRepository {
  ApiSalesChannelRepository(Dio dio) : _table = ApiTable(dio, "/channels", SalesChannel.fromJson);

  final ApiTable<SalesChannel> _table;

  @override
  Future<List<SalesChannel>> fetchAll() => _table.fetchAll();

  @override
  Future<SalesChannel> update(SalesChannel channel) => _table.update(channel.id, channel.toJson());
}
