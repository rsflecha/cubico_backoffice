import 'package:cubico_backoffice/features/etsy/domain/etsy_status.dart';
import 'package:cubico_backoffice/features/etsy/presentation/etsy_providers.dart';
import 'package:cubico_backoffice/features/etsy/presentation/etsy_section.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test("lê o estado como a API o manda (snake_case, datas do MariaDB)", () {
    final s = EtsyStatus.fromJson({
      "configured": true,
      "connected": true,
      "shop_name": "CubicoDesign3D",
      "connected_at": "2026-11-16 18:00:00",
      "refresh_expires_at": "2027-02-14 18:00:00",
    });
    expect(s.shopName, "CubicoDesign3D");
    expect(s.refreshExpiresAt, DateTime(2027, 2, 14, 18));
    expect(s.expiresSoon(DateTime(2026, 11, 20)), isFalse);
    expect(s.expiresSoon(DateTime(2027, 2, 5)), isTrue);
  });

  Future<void> show(WidgetTester tester, EtsyStatus status) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [etsyStatusProvider.overrideWith((ref) async => status)],
      child: const MaterialApp(home: Scaffold(body: EtsySection())),
    ));
    await tester.pump();
  }

  testWidgets("sem chave no servidor: diz o que falta, sem botão de ligar", (tester) async {
    await show(tester, const EtsyStatus());
    expect(find.textContaining("falta a chave"), findsOneWidget);
    expect(find.text("Ligar à Etsy"), findsNothing);
  });

  testWidgets("com chave e por ligar: botão Ligar à Etsy", (tester) async {
    await show(tester, const EtsyStatus(configured: true));
    expect(find.text("Ligar à Etsy"), findsOneWidget);
  });

  testWidgets("ligada: nome da loja e desligar", (tester) async {
    await show(tester, EtsyStatus(
      configured: true,
      connected: true,
      shopName: "CubicoDesign3D",
      connectedAt: DateTime(2026, 11, 16),
      refreshExpiresAt: DateTime.now().add(const Duration(days: 80)),
    ));
    expect(find.text("Etsy: ligada à loja «CubicoDesign3D»"), findsOneWidget);
    expect(find.textContaining("Desde 16/11/2026."), findsOneWidget);
    expect(find.text("Desligar"), findsOneWidget);
  });
}
