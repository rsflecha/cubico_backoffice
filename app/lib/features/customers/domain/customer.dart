import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer.freezed.dart';
part 'customer.g.dart';

/// Um cliente com ficha.
@freezed
abstract class Customer with _$Customer {
  const factory Customer({
    required int id,
    required String name,
    String? email,
    String? phone,
    String? instagram, // sem o @
    String? notes,
    required DateTime createdAt,
    @Default([]) List<Address> addresses,
  }) = _Customer;

  factory Customer.fromJson(Map<String, dynamic> json) => _$CustomerFromJson(json);
}

/// Uma morada de um cliente.
@freezed
abstract class Address with _$Address {
  const Address._();

  const factory Address({
    required int id,
    required String line1,
    String? line2,
    required String postalCode,
    required String city,
    @Default("PT") String country,
  }) = _Address;

  factory Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);

  /// A morada numa linha só: "Rua das Flores 12, 4700-000 Braga".
  String get oneLine => [
    line1,
    if (line2 != null && line2!.isNotEmpty) line2!,
    "$postalCode $city",
    if (country != "PT") country,
  ].join(", ");
}