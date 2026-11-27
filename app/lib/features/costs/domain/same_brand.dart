import 'package:cubico_backoffice/features/costs/domain/filament.dart';

/// Os OUTROS filamentos com a mesma marca de [edited] (sem ligar a maiúsculas
/// nem a espaços à volta) cuja tara é diferente da dele. Vazio se a marca for
/// nula ou vazia. Serve para oferecer "usar esta tara nos restantes".
List<Filament> sameBrandOthers(List<Filament> all, Filament edited) {
  final brand = edited.brand?.trim().toLowerCase() ?? "";
  if (brand.isEmpty) return [];

  return [
    for (final f in all)
      if (f.id != edited.id &&
          (f.brand?.trim().toLowerCase() ?? "") == brand &&
          f.emptySpoolG != edited.emptySpoolG)
        f,
  ];
}
