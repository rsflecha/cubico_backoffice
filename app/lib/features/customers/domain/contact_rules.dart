import 'package:flutter/services.dart';

// Regras dos contactos e das moradas dos clientes.
// Ficam fora do ecrã para se poderem testar sozinhas (test/features/customers/).

/// O código postal português: 4 algarismos, um hífen, 3 algarismos.
final ptPostalCode = RegExp(r"^\d{4}-\d{3}$");

/// Telemóvel ou telefone válido?
/// - português: 9 algarismos a começar por 9 (telemóvel) ou 2/3 (fixo),
///   com ou sem o indicativo (+351 ou 00351) e com os espaços que quiserem;
/// - estrangeiro (clientes da Etsy): começa por "+" ou "00" e tem 8 a 15 algarismos.
bool isValidPhone(String text) {
  final t = text.trim();
  final digits = t.replaceAll(RegExp(r"\D"), "");
  // só algarismos, espaços, hífens, pontos, parênteses e o "+" do início
  if (!RegExp(r"^\+?[\d\s\-.()]+$").hasMatch(t)) return false;

  var national = digits;
  if (t.startsWith("+351")) {
    national = digits.substring(3);
  } else if (digits.startsWith("00351")) {
    national = digits.substring(5);
  } else if (t.startsWith("+") || digits.startsWith("00")) {
    // outro país: só se confere o tamanho (a norma E.164 vai até 15 algarismos)
    final international = digits.startsWith("00") ? digits.substring(2) : digits;
    return international.length >= 8 && international.length <= 15;
  }
  return RegExp(r"^[923]\d{8}$").hasMatch(national);
}

/// O erro do campo do telemóvel, ou null se estiver bem (ou vazio: é opcional).
String? phoneError(String? value) {
  final t = (value ?? "").trim();
  if (t.isEmpty || isValidPhone(t)) return null;
  return "Telemóvel inválido (ex.: 912 345 678 ou +44 7700 900123).";
}

/// Põe o hífen do código postal português enquanto se escreve: "4700000" → "4700-000".
/// (O mesmo formatador do curso, na app xlo_mobx.)
class PtPostalCodeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r"\D"), "");
    final limited = digits.length > 7 ? digits.substring(0, 7) : digits;
    final text = limited.length <= 4 ? limited : "${limited.substring(0, 4)}-${limited.substring(4)}";
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
