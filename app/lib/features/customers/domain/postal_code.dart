/// Um código postal português e a sua localidade (base dos CTT).
class PostalCodeInfo {
  const PostalCodeInfo({
    required this.postalCode,
    required this.locality,
    required this.municipality,
    required this.district,
  });

  factory PostalCodeInfo.fromJson(Map<String, dynamic> json) => PostalCodeInfo(
        postalCode: json["postal_code"] as String,
        locality: json["locality"] as String,
        municipality: json["municipality"] as String? ?? "",
        district: json["district"] as String? ?? "",
      );

  final String postalCode; // "3700-008"
  final String locality; // a localidade postal (é a que vai para a morada)
  final String municipality; // concelho
  final String district; // distrito (ou ilha)

  /// "São João da Madeira, Aveiro": o que aparece por baixo do campo.
  String get area => [municipality, district].where((t) => t.isNotEmpty).toSet().join(", ");
}

/// Procurar a localidade de um código postal.
abstract interface class PostalCodeRepository {
  /// A localidade de [postalCode] ("4700-000"), ou null se o código não existir.
  Future<PostalCodeInfo?> lookup(String postalCode);
}
