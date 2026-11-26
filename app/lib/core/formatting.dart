/// Formatação de valores para o ecrã, à portuguesa.
library;

/// Um valor em euros: 24.5 → "24,50 €".
String euro(double value) {
  return "${value.toStringAsFixed(2).replaceAll(".", ",")} €";
}

/// Um preço por unidade de medida: 13.43, "kg" → "13,43 €/kg".
/// Com [decimals] para valores pequenos: 0.075, "un.", decimals: 3 → "0,075 €/un.".
String euroPer(double value, String unit, {int decimals = 2}) {
  return "${value.toStringAsFixed(decimals).replaceAll(".", ",")} €/$unit";
}

/// Um número decimal para pôr num campo de texto: 24.0 → "24,00".
String decimalField(double value) {
  return value.toStringAsFixed(2).replaceAll(".", ",");
}

/// Lê um número escrito pelo utilizador: aceita vírgula ("0,21") e devolve 0 se estiver vazio.
double parseDecimal(String text) {
  return double.tryParse(text.trim().replaceAll(",", ".")) ?? 0;
}

/// Gramas para um campo de texto: no máximo 2 casas e sem zeros a mais.
/// 120.0 → "120", 86.4 → "86,4", 86.456 → "86,46".
String gramsField(double grams) {
  var text = grams.toStringAsFixed(2); // "86.40" (e arruma o lixo do double: 259.20000000000002)
  text = text.replaceFirst(RegExp(r"\.?0+$"), ""); // "86.4", "120"
  return text.replaceAll(".", ",");
}

/// Gramas para o ecrã: 86.4 → "86,4 g", 120.0 → "120 g".
String gramsText(double grams) => "${gramsField(grams)} g";

/// Compara dois nomes para pôr uma lista por ordem alfabética, à portuguesa:
/// sem ligar a maiúsculas nem a acentos ("Árvore" vem antes de "Base", e não depois
/// de "Zebra", que é o que acontecia comparando o texto tal e qual).
/// Os números contam pelo valor: "Rena 135mm" < "Rena 245mm" e "Caixa 9" < "Caixa 10"
/// (letra a letra, "10" vinha antes de "9").
int compareNames(String a, String b) {
  final byName = _compareNatural(_sortKey(a), _sortKey(b));
  // empate (ex.: "Ação" e "acao"): desempata pelo texto original, para a ordem ser sempre a mesma
  return byName != 0 ? byName : a.compareTo(b);
}

/// Parte o texto em pedaços de algarismos e de não-algarismos e compara-os um a um:
/// dois pedaços de algarismos comparam-se como números, os outros como texto.
int _compareNatural(String a, String b) {
  final chunk = RegExp(r"\d+|\D+");
  final pa = chunk.allMatches(a).map((m) => m.group(0)!).toList();
  final pb = chunk.allMatches(b).map((m) => m.group(0)!).toList();
  for (var i = 0; i < pa.length && i < pb.length; i++) {
    final na = int.tryParse(pa[i]);
    final nb = int.tryParse(pb[i]);
    final c = na != null && nb != null ? na.compareTo(nb) : pa[i].compareTo(pb[i]);
    if (c != 0) return c;
  }
  return pa.length.compareTo(pb.length);
}

/// O nome em minúsculas e sem acentos: "Árvore de Natal" → "arvore de natal".
String _sortKey(String text) {
  const from = "àáâãäçèéêëìíîïñòóôõöùúûü";
  const to = "aaaaaceeeeiiiinooooouuuu";
  final buffer = StringBuffer();
  for (final char in text.toLowerCase().split("")) {
    final i = from.indexOf(char);
    buffer.write(i == -1 ? char : to[i]);
  }
  return buffer.toString();
}
