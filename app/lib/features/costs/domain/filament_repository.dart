import 'filament.dart';

abstract interface class FilamentRepository {
  Future<List<Filament>> fetchAll();

  /// Cria um filamento a partir de um rascunho. O id do rascunho é ignorado:
  /// quem cria é que dá o id (como faria a base de dados).
  Future<Filament> create(Filament draft);

  Future<Filament> update(Filament filament);
}
