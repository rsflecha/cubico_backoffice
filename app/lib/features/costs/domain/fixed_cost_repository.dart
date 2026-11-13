import 'package:cubico_backoffice/features/costs/domain/fixed_cost.dart';

abstract interface class FixedCostRepository {
  Future<List<FixedCost>> fetchAll();
  Future<FixedCost> create(FixedCost draft);
  Future<FixedCost> update(FixedCost cost);
  Future<void> delete(int id);
}
