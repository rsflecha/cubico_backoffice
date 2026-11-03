// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_channel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SalesChannel _$SalesChannelFromJson(Map<String, dynamic> json) =>
    _SalesChannel(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      name: json['name'] as String,
      transactionFee: (json['transaction_fee'] as num?)?.toDouble() ?? 0,
      processingFee: (json['processing_fee'] as num?)?.toDouble() ?? 0,
      flatFee: (json['flat_fee'] as num?)?.toDouble() ?? 0,
      listingFee: (json['listing_fee'] as num?)?.toDouble() ?? 0,
      isAutomatic: json['is_automatic'] as bool? ?? false,
    );

Map<String, dynamic> _$SalesChannelToJson(_SalesChannel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'transaction_fee': instance.transactionFee,
      'processing_fee': instance.processingFee,
      'flat_fee': instance.flatFee,
      'listing_fee': instance.listingFee,
      'is_automatic': instance.isAutomatic,
    };
