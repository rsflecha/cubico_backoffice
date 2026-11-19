/// SKU automático — decisão de 2026-11-16 (variantes por número desde 2026-11-19).
/// Ninguém escreve SKU à mão:
///   categoria "Suportes"                → código SUP (3 letras do nome, sem acentos)
///   produto                             → CD3-SUP-01, CD3-SUP-02… (recomeça em cada categoria)
///   produto sem categoria               → CD3-GER-01… (GER fica reservado)
///   variantes com nome                  → CD3-SUP-01-01, CD3-SUP-01-02… (pela ordem de criação;
///                                         mudar o nome não muda o número)
///   variante sem nome (modelo único)    → CD3-SUP-01
///
/// Quem manda é a API (api/src/sku.php): estas funções são as MESMAS regras, para o
/// modo demo e para a app mostrar o SKU antes de gravar. Se mudares uma, muda a outra.
library;

const skuPrefix = "CD3";
const noCategoryCode = "GER";

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

/// O SKU de uma variante: o do produto, mais o número (3 → "-03"). Sem número = o do produto.
String variantSku(String productSku, int? number) =>
    number == null ? productSku : "$productSku-${number.toString().padLeft(2, "0")}";

/// O número de uma variante, lido do SKU dela ("CD3-NAT-01-03" → 3). null se não tiver.
int? variantNumber(String productSku, String sku) {
  final prefix = "$productSku-";
  if (!sku.startsWith(prefix)) return null;
  final rest = sku.substring(prefix.length);
  return RegExp(r"^\d+$").hasMatch(rest) ? int.parse(rest) : null;
}

/// O número da próxima variante com nome: o maior já usado nos [siblingSkus], mais 1.
int nextVariantNumber(String productSku, Iterable<String> siblingSkus) {
  var max = 0;
  for (final sku in siblingSkus) {
    final n = variantNumber(productSku, sku);
    if (n != null && n > max) max = n;
  }
  return max + 1;
}
