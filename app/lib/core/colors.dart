import 'package:material_ui/material_ui.dart';

/// Transforma "#1F2937" numa Color. Se o texto não for válido, devolve um cinzento.
Color colorFromHex(String? hex) {
  final clean = (hex ?? "").replaceAll("#", "");
  final value = int.tryParse(clean, radix: 16);
  if (clean.length != 6 || value == null) return const Color(0xFFA1A1AA);
  return Color(0xFF000000 | value);
}