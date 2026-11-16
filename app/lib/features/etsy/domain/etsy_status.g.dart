// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'etsy_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EtsyStatus _$EtsyStatusFromJson(Map<String, dynamic> json) => _EtsyStatus(
  configured: json['configured'] as bool? ?? false,
  connected: json['connected'] as bool? ?? false,
  shopName: json['shop_name'] as String?,
  connectedAt: json['connected_at'] == null
      ? null
      : DateTime.parse(json['connected_at'] as String),
  refreshExpiresAt: json['refresh_expires_at'] == null
      ? null
      : DateTime.parse(json['refresh_expires_at'] as String),
);

Map<String, dynamic> _$EtsyStatusToJson(_EtsyStatus instance) =>
    <String, dynamic>{
      'configured': instance.configured,
      'connected': instance.connected,
      'shop_name': instance.shopName,
      'connected_at': instance.connectedAt?.toIso8601String(),
      'refresh_expires_at': instance.refreshExpiresAt?.toIso8601String(),
    };
