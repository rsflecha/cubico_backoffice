// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Customer _$CustomerFromJson(Map<String, dynamic> json) => _Customer(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  instagram: json['instagram'] as String?,
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  addresses:
      (json['addresses'] as List<dynamic>?)
          ?.map((e) => Address.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$CustomerToJson(_Customer instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'instagram': instance.instagram,
  'notes': instance.notes,
  'created_at': instance.createdAt.toIso8601String(),
  'addresses': instance.addresses.map((e) => e.toJson()).toList(),
};

_Address _$AddressFromJson(Map<String, dynamic> json) => _Address(
  id: (json['id'] as num).toInt(),
  line1: json['line1'] as String,
  line2: json['line2'] as String?,
  postalCode: json['postal_code'] as String,
  city: json['city'] as String,
  country: json['country'] as String? ?? "PT",
);

Map<String, dynamic> _$AddressToJson(_Address instance) => <String, dynamic>{
  'id': instance.id,
  'line1': instance.line1,
  'line2': instance.line2,
  'postal_code': instance.postalCode,
  'city': instance.city,
  'country': instance.country,
};
