import 'package:cubico_backoffice/features/costs/domain/printer.dart';

abstract interface class PrinterRepository {
  Future<List<Printer>> fetchAll();
  Future<Printer> update(Printer printer);
}