import 'filament.dart';

abstract interface class FilamentRepository {
  Future<List<Filament>> fetchAll();

}