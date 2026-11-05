import 'package:cubico_backoffice/features/costs/domain/printer.dart';
import 'package:cubico_backoffice/features/costs/domain/printer_repository.dart';

class DemoPrinterRepository implements PrinterRepository {
  final List<Printer> _items = [
    const Printer(
      id: 1,
      name: "Bambu Lab A1",
      powerW: 95,
      purchasePrice: 381.40,
      lifespanHours: 5000,
      yearlyMaintenance: 40,
      yearlyHours: 1500,
      isDefault: true,
    ),
  ];

  Future<void> _latency() => Future.delayed(const Duration(milliseconds: 300));

  @override
  Future<List<Printer>> fetchAll() async {
    await _latency();
    return List<Printer>.of(_items);
  }

  @override
  Future<Printer> update(Printer printer) async {
    await _latency();
    final index = _items.indexWhere((p) => p.id == printer.id);
    if (index == -1) throw StateError("Impressora ${printer.id} não existe.");
    _items[index] = printer;
    return printer;
  }
}