import 'package:cubico_backoffice/features/customers/domain/postal_code.dart';

/// No modo demo não há servidor nem a base dos CTT: só uns poucos códigos,
/// para se ver a localidade a aparecer sozinha.
class DemoPostalCodeRepository implements PostalCodeRepository {
  static const _known = {
    "1000-001": PostalCodeInfo(postalCode: "1000-001", locality: "Lisboa", municipality: "Lisboa", district: "Lisboa"),
    "3700-008": PostalCodeInfo(
        postalCode: "3700-008", locality: "São João da Madeira", municipality: "São João da Madeira", district: "Aveiro"),
    "4000-123": PostalCodeInfo(postalCode: "4000-123", locality: "Porto", municipality: "Porto", district: "Porto"),
    "4700-000": PostalCodeInfo(postalCode: "4700-000", locality: "Braga", municipality: "Braga", district: "Braga"),
  };

  @override
  Future<PostalCodeInfo?> lookup(String postalCode) async => _known[postalCode];
}
