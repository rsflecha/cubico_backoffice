// Contas da pesagem. É só a pré-visualização: a API refaz a conta e é a dela que fica.

/// O stock total em gramas: rolos fechados × peso do rolo + o líquido de cada rolo aberto
/// (peso bruto menos o carretel vazio).
double weighedTotal({
  required int closedSpools,
  required int spoolWeightG,
  required List<double> openGrossG,
  required int emptySpoolG,
}) {
  final open = openGrossG.fold<double>(0, (sum, gross) => sum + (gross - emptySpoolG));
  return closedSpools * spoolWeightG + open;
}

/// O que está mal na pesagem, ou null se estiver bem. Mesmas regras e palavras da API.
String? weighingProblem({
  required int closedSpools,
  required List<double> openGrossG,
  required int emptySpoolG,
}) {
  if (closedSpools < 0) return "Os rolos fechados não podem ser negativos.";
  if (openGrossG.any((gross) => gross <= 0)) {
    return "O peso de cada rolo aberto tem de ser maior que zero.";
  }
  if (openGrossG.isNotEmpty && emptySpoolG <= 0) {
    return "Falta o peso do carretel vazio deste filamento, em Custos e preços.";
  }
  if (openGrossG.any((gross) => gross < emptySpoolG)) {
    return "Um rolo aberto não pode pesar menos do que o carretel vazio ($emptySpoolG g).";
  }
  return null;
}
