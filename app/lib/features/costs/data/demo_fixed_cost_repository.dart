import 'package:cubico_backoffice/features/costs/domain/fixed_cost.dart';
import 'package:cubico_backoffice/features/costs/domain/fixed_cost_repository.dart';

class DemoFixedCostRepository implements FixedCostRepository {
  final List<FixedCost> _items = [
    const FixedCost(id: 1, name: "Etsy Plus", monthlyValue: 8.92),
    const FixedCost(id: 2, name: "Claude Pro", monthlyValue: 18),
  ];
  int _nextId = 10;

  Future<void> _latency() => Future.delayed(const Duration(milliseconds: 300));

  @override
  Future<List<FixedCost>> fetchAll() async {
    await _latency();
    return List<FixedCost>.of(_items);
  }

  @override
  Future<FixedCost> create(FixedCost draft) async {
    await _latency();
    final created = draft.copyWith(id: _nextId++);
    _items.add(created);
    return created;
  }

  @override
  Future<FixedCost> update(FixedCost cost) async {
    await _latency();
    final index = _items.indexWhere((c) => c.id == cost.id);
    if (index == -1) throw StateError("Custo fixo ${cost.id} não existe.");
    _items[index] = cost;
    return cost;
  }

  @override
  Future<void> delete(int id) async {
    await _latency();
    _items.removeWhere((c) => c.id == id);
  }
}
