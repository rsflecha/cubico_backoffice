import 'package:cubico_backoffice/features/costs/domain/filament.dart';
import 'package:cubico_backoffice/features/costs/domain/filament_repository.dart';

class DemoFilamentRepository implements FilamentRepository {
  final List<Filament> _items = [
    Filament(
      id: 1,
      material: "PLA",
      brand: "Bambu Lab",
      colorName: "Black Basic",
      colorHex: "#1F2937",   // Black Basic
      listPrice: 26.86,
      paidPrice: 13.43,
    ),
    Filament(
      id: 2,
      material: "PETG",
      brand: "Bambu Lab",
      colorName: "Translucent",
      colorHex: "#E5E7EB",   // Translucent
      listPrice: 23.76,
      paidPrice: 11.88,
    ),
    Filament(
      id: 3,
      material: "PLA",
      brand: "Bambu Lab",
      colorName: "Orange Basic",
      colorHex: "#EA580C",   // Orange Basic
      listPrice: 23.76,
      paidPrice: 11.88,
    ),
  ];

  Future<void> _latency() => Future.delayed(const Duration(milliseconds: 300));

  @override
  Future<List<Filament>> fetchAll() async {
    await _latency();
    return List<Filament>.of(_items);
  }
}
