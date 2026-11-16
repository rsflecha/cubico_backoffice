/// SKU automático — decisão de 2026-11-16. Ninguém escreve SKU à mão:
///   categoria "Suportes"                → código SUP (3 letras do nome, sem acentos)
///   produto                             → CD3-SUP-01, CD3-SUP-02… (recomeça em cada categoria)
///   produto sem categoria               → CD3-GER-01… (GER fica reservado)
///   variante "Hamilton"                 → CD3-SUP-01-HAMILTON
///   variante sem nome (produto simples) → CD3-SUP-01
///
/// Quem manda é a API (api/src/sku.php): estas funções são as MESMAS regras, para o
/// modo demo e para a app mostrar o SKU antes de gravar. Se mudares uma, muda a outra.
library;

const skuPrefix = "CD3";
const noCategoryCode = "GER";
const _variantSlugMax = 30;

const _accents = {
  "Á": "A", "À": "A", "Â": "A", "Ã": "A", "Ä": "A",
  "É": "E", "È": "E", "Ê": "E", "Ë": "E",
  "Í": "I", "Ì": "I", "Î": "I", "Ï": "I",
  "Ó": "O", "Ò": "O", "Ô": "O", "Õ": "O", "Ö": "O",
  "Ú": "U", "Ù": "U", "Û": "U", "Ü": "U",
  "Ç": "C", "Ñ": "N",
};

/// "Fórmula 1" → "FORMULA 1": maiúsculas e sem acentos.
String plainUpper(String text) {
  final upper = text.trim().toUpperCase();
  final out = StringBuffer();
  for (final char in upper.split("")) {
    out.write(_accents[char] ?? char);
  }
  return out.toString();
}

/// Um código de categoria aceitável: 2 a 5 letras ou algarismos.
bool isValidCategoryCode(String code) => RegExp(r"^[A-Z0-9]{2,5}$").hasMatch(code);

/// O código para uma categoria nova: as 3 primeiras letras do nome ("Suportes" → SUP).
/// Se já estiver em [taken] (ou for GER), tenta SU2, SU3…
String newCategoryCode(String name, Iterable<String> taken) {
  final letters = plainUpper(name).replaceAll(RegExp(r"[^A-Z0-9]"), "");
  final base = letters.isEmpty ? "CAT" : letters.substring(0, letters.length < 3 ? letters.length : 3);
  final used = taken.toSet();
  for (var n = 1; ; n++) {
    final code = n == 1 ? base : "${base.substring(0, base.length < 2 ? base.length : 2)}$n";
    if (code != noCategoryCode && !used.contains(code)) return code;
  }
}

/// O SKU do próximo produto com este código, sabendo os SKU que já existem: CD3-SUP-03.
String nextProductSku(String? categoryCode, Iterable<String> existingSkus) {
  final prefix = "$skuPrefix-${categoryCode ?? noCategoryCode}-";
  var max = 0;
  for (final sku in existingSkus) {
    if (!sku.startsWith(prefix)) continue;
    final number = int.tryParse(sku.substring(prefix.length));
    if (number != null && number > max) max = number;
  }
  return "$prefix${(max + 1).toString().padLeft(2, "0")}";
}

/// "Ação & Côr!" → "ACAO-COR"; um nome vazio dá "" (a variante é o próprio produto).
String variantSlug(String name) {
  if (name.trim().isEmpty) return "";
  String trimDashes(String s) => s.replaceAll(RegExp(r"^-+|-+$"), "");
  var slug = trimDashes(plainUpper(name).replaceAll(RegExp(r"[^A-Z0-9]+"), "-"));
  if (slug.length > _variantSlugMax) slug = trimDashes(slug.substring(0, _variantSlugMax));
  return slug.isEmpty ? "V" : slug;
}

/// O SKU de uma variante: o do produto, mais o nome.
String variantSku(String productSku, String variantName) {
  final slug = variantSlug(variantName);
  return slug.isEmpty ? productSku : "$productSku-$slug";
}
