import 'package:freezed_annotation/freezed_annotation.dart';

part 'etsy_listings_check.freezed.dart';
part 'etsy_listings_check.g.dart';

/// Uma variante da app, tal como aparece na conferência dos SKU.
@freezed
abstract class EtsyVariantRef with _$EtsyVariantRef {
  const factory EtsyVariantRef({
    required int variantId,
    int? productId, // para abrir a ficha do produto
    String? sku,
    required String label, // "Suporte F1 · Hamilton"
  }) = _EtsyVariantRef;

  factory EtsyVariantRef.fromJson(Map<String, dynamic> json) => _$EtsyVariantRefFromJson(json);
}

/// Um produto de um anúncio da Etsy (um anúncio com variações tem vários).
@freezed
abstract class EtsyProductCheck with _$EtsyProductCheck {
  const EtsyProductCheck._(); // para poder ter getters

  const factory EtsyProductCheck({
    String? productId, // o produto do anúncio na Etsy: é por ele que se associa à mão
    @Default(false) bool linked, // liga porque foi associado à mão (e não pelo SKU)
    String? sku,
    @Default("") String variation, // "Piloto: Hamilton"
    @Default(1) int pack, // pack de quantidade: cada venda são N peças (a API reconhece "Quantidade: 10")
    required String status, // ok, unknown_sku, no_sku
    EtsyVariantRef? variant, // a variante da app a que liga (só quando ok)
  }) = _EtsyProductCheck;

  factory EtsyProductCheck.fromJson(Map<String, dynamic> json) => _$EtsyProductCheckFromJson(json);

  /// Uma venda deste produto entra sozinha na app?
  bool get isOk => status == "ok";

  /// O que falta fazer, em português (null quando está tudo bem).
  String? get problem => switch (status) {
        "ok" => null,
        "unknown_sku" => "Nenhuma variante da app tem o SKU $sku.",
        "no_sku" => "Sem SKU na Etsy.",
        _ => "Estado desconhecido ($status).",
      };
}

/// Um anúncio ativo da Etsy e os seus produtos.
@freezed
abstract class EtsyListingCheck with _$EtsyListingCheck {
  const EtsyListingCheck._();

  const factory EtsyListingCheck({
    required String listingId,
    required String title,
    @Default("") String url,
    @Default([]) List<EtsyProductCheck> products,
  }) = _EtsyListingCheck;

  factory EtsyListingCheck.fromJson(Map<String, dynamic> json) => _$EtsyListingCheckFromJson(json);

  /// Quantos produtos deste anúncio ficavam de fora numa venda.
  int get problems => products.where((p) => !p.isOk).length;
}

/// O resultado de "Conferir os SKU": os anúncios ativos contra as variantes da app.
@freezed
abstract class EtsyListingsCheck with _$EtsyListingsCheck {
  const EtsyListingsCheck._();

  const factory EtsyListingsCheck({
    required DateTime checkedAt,
    @Default(0) int ok,
    @Default(0) int problems,

    /// Anúncios digitais (downloads) que não se conferem: não entram na app.
    @Default(0) int digitalSkipped,
    @Default([]) List<EtsyListingCheck> listings,

    /// Variantes da app que nenhum anúncio usa (não é erro: podem não estar à venda na Etsy).
    @Default([]) List<EtsyVariantRef> unlistedVariants,

    /// Todas as variantes ativas da app, para escolher uma ao associar à mão.
    @Default([]) List<EtsyVariantRef> variants,
  }) = _EtsyListingsCheck;

  factory EtsyListingsCheck.fromJson(Map<String, dynamic> json) => _$EtsyListingsCheckFromJson(json);

  /// Os anúncios com problemas primeiro; dentro de cada grupo, por título.
  List<EtsyListingCheck> get sorted => [...listings]..sort((a, b) {
      final byProblem = (b.problems > 0 ? 1 : 0).compareTo(a.problems > 0 ? 1 : 0);
      return byProblem != 0 ? byProblem : a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
}
