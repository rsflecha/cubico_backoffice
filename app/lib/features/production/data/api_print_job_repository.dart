import 'package:cubico_backoffice/core/api/api_table.dart';
import 'package:cubico_backoffice/features/production/domain/print_job.dart';
import 'package:cubico_backoffice/features/production/domain/print_job_repository.dart';
import 'package:dio/dio.dart';

/// As tarefas de impressão, vindas da API.
class ApiPrintJobRepository implements PrintJobRepository {
  ApiPrintJobRepository(Dio dio) : _table = ApiTable(dio, "/print-jobs", PrintJob.fromJson);

  final ApiTable<PrintJob> _table;

  @override
  Future<List<PrintJob>> fetchAll() => _table.fetchAll();

  @override
  Future<PrintJob> create(PrintJob draft) => _table.create(draft.toJson());

  @override
  Future<PrintJob> update(PrintJob job) => _table.update(job.id, job.toJson());
}
