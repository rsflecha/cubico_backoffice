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

/// Compara dois nomes para pôr uma lista por ordem alfabética, à portuguesa:
/// sem ligar a maiúsculas nem a acentos ("Árvore" vem antes de "Base", e não depois
/// de "Zebra", que é o que acontecia comparando o texto tal e qual).
int compareNames(String a, String b) {
  final byName = _sortKey(a).compareTo(_sortKey(b));
  // empate (ex.: "Ação" e "acao"): desempata pelo texto original, para a ordem ser sempre a mesma
  return byName != 0 ? byName : a.compareTo(b);
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
