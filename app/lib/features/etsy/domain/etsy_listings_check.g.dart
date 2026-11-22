// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'etsy_listings_check.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EtsyVariantRef _$EtsyVariantRefFromJson(Map<String, dynamic> json) =>
    _EtsyVariantRef(
      variantId: (json['variant_id'] as num).toInt(),
      productId: (json['product_id'] as num?)?.toInt(),
      sku: json['sku'] as String?,
      label: json['label'] as String,
    );

Map<String, dynamic> _$EtsyVariantRefToJson(_EtsyVariantRef instance) =>
    <String, dynamic>{
      'variant_id': instance.variantId,
      'product_id': instance.productId,
      'sku': instance.sku,
      'label': instance.label,
    };

_EtsyProductCheck _$EtsyProductCheckFromJson(Map<String, dynamic> json) =>
    _EtsyProductCheck(
      productId: json['product_id'] as String?,
      linked: json['linked'] as bool? ?? false,
      sku: json['sku'] as String?,
      variation: json['variation'] as String? ?? "",
      pack: (json['pack'] as num?)?.toInt() ?? 1,
      status: json['status'] as String,
      variant: json['variant'] == null
          ? null
          : EtsyVariantRef.fromJson(json['variant'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EtsyProductCheckToJson(_EtsyProductCheck instance) =>
    <String, dynamic>{
      'product_id': instance.productId,
      'linked': instance.linked,
      'sku': instance.sku,
      'variation': instance.variation,
      'pack': instance.pack,
      'status': instance.status,
      'variant': instance.variant?.toJson(),
    };

_EtsyListingCheck _$EtsyListingCheckFromJson(Map<String, dynamic> json) =>
    _EtsyListingCheck(
      listingId: json['listing_id'] as String,
      title: json['title'] as String,
      url: json['url'] as String? ?? "",
      products:
          (json['products'] as List<dynamic>?)
              ?.map((e) => EtsyProductCheck.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$EtsyListingCheckToJson(_EtsyListingCheck instance) =>
    <String, dynamic>{
      'listing_id': instance.listingId,
      'title': instance.title,
      'url': instance.url,
      'products': instance.products.map((e) => e.toJson()).toList(),
    };

_EtsyListingsCheck _$EtsyListingsCheckFromJson(Map<String, dynamic> json) =>
    _EtsyListingsCheck(
      checkedAt: DateTime.parse(json['checked_at'] as String),
      ok: (json['ok'] as num?)?.toInt() ?? 0,
      problems: (json['problems'] as num?)?.toInt() ?? 0,
      digitalSkipped: (json['digital_skipped'] as num?)?.toInt() ?? 0,
      listings:
          (json['listings'] as List<dynamic>?)
              ?.map((e) => EtsyListingCheck.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      unlistedVariants:
          (json['unlisted_variants'] as List<dynamic>?)
              ?.map((e) => EtsyVariantRef.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      variants:
          (json['variants'] as List<dynamic>?)
              ?.map((e) => EtsyVariantRef.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$EtsyListingsCheckToJson(_EtsyListingsCheck instance) =>
    <String, dynamic>{
      'checked_at': instance.checkedAt.toIso8601String(),
      'ok': instance.ok,
      'problems': instance.problems,
      'digital_skipped': instance.digitalSkipped,
      'listings': instance.listings.map((e) => e.toJson()).toList(),
      'unlisted_variants': instance.unlistedVariants
          .map((e) => e.toJson())
          .toList(),
      'variants': instance.variants.map((e) => e.toJson()).toList(),
    };
