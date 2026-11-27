import 'package:cubico_backoffice/features/stock/domain/weighing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("weighedTotal soma rolos fechados e o líquido dos abertos", () {
    expect(weighedTotal(closedSpools: 2, spoolWeightG: 1000, openGrossG: [712], emptySpoolG: 250), 2462);
    expect(weighedTotal(closedSpools: 3, spoolWeightG: 750, openGrossG: [], emptySpoolG: 0), 2250);
    expect(weighedTotal(closedSpools: 0, spoolWeightG: 1000, openGrossG: [712.5, 300], emptySpoolG: 250), 512.5);
  });

  test("weighingProblem usa as mesmas regras da API", () {
    expect(weighingProblem(closedSpools: 0, openGrossG: [240], emptySpoolG: 250), contains("carretel"));
    expect(weighingProblem(closedSpools: 0, openGrossG: [500], emptySpoolG: 0), contains("Custos e preços"));
    expect(weighingProblem(closedSpools: 2, openGrossG: [], emptySpoolG: 0), isNull);
    expect(weighingProblem(closedSpools: -1, openGrossG: [], emptySpoolG: 250), isNotNull);
    expect(weighingProblem(closedSpools: 0, openGrossG: [0], emptySpoolG: 250), contains("maior que zero"));
  });
}
