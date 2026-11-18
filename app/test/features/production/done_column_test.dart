import 'package:cubico_backoffice/features/production/domain/print_job.dart';
import 'package:cubico_backoffice/features/production/presentation/production_providers.dart';
import 'package:cubico_backoffice/features/production/presentation/production_screen.dart';
import 'package:cubico_backoffice/features/products/presentation/products_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets("«Concluído» mostra a de há 2 horas e esconde as de há 2 e 3 dias", (tester) async {
    final now = DateTime.now();
    PrintJob done(int id, int hoursAgo, String notes) => PrintJob(
        id: id, variantId: 1, estimatedMin: 60, status: PrintJobStatus.done,
        startedAt: now.subtract(Duration(hours: hoursAgo + 1)),
        finishedAt: now.subtract(Duration(hours: hoursAgo)), notes: notes);

    await tester.binding.setSurfaceSize(const Size(375, 2000)); // telemóvel, alto para caber tudo
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(ProviderScope(
      overrides: [
        printJobsProvider.overrideWith((ref) async => [
              done(1, 2, "Acabada há 2 horas"),
              done(2, 50, "Acabada há 2 dias"),
              done(3, 74, "Acabada há 3 dias"),
            ]),
        allVariantsProvider.overrideWith((ref) async => []),
        productsProvider.overrideWith((ref) async => []),
      ],
      child: const MaterialApp(home: ProductionScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text("Acabada há 2 horas"), findsOneWidget);
    expect(find.text("Acabada há 2 dias"), findsNothing);
    expect(find.text("Acabada há 3 dias"), findsNothing);
    expect(find.text("+2 concluídas há mais de 1 dia"), findsOneWidget);
  });
}
