import 'package:cubico_backoffice/core/api/api_table.dart';
import 'package:cubico_backoffice/features/costs/domain/printer.dart';
import 'package:cubico_backoffice/features/costs/domain/printer_repository.dart';
import 'package:dio/dio.dart';

/// As impressoras, vindas da API.
class ApiPrinterRepository implements PrinterRepository {
  ApiPrinterRepository(Dio dio) : _table = ApiTable(dio, "/printers", Printer.fromJson);

  final ApiTable<Printer> _table;

  @override
  Future<List<Printer>> fetchAll() => _table.fetchAll();

  @override
  Future<Printer> update(Printer printer) => _table.update(printer.id, printer.toJson());
}
