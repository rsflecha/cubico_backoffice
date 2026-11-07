import 'package:cubico_backoffice/features/production/domain/print_job.dart';

abstract interface class PrintJobRepository {
  Future<List<PrintJob>> fetchAll();
  Future<PrintJob> update(PrintJob job);
}