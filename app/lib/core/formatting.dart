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
