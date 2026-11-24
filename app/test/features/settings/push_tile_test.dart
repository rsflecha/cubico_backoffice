import 'package:cubico_backoffice/core/api/api_exception.dart';
import 'package:cubico_backoffice/features/settings/data/push_service.dart';
import 'package:cubico_backoffice/features/settings/presentation/widgets/push_tile.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Um aparelho e uma API de mentira: o estado inicial, e o que a pessoa faz.
class _Fake extends PushService {
  _Fake(this.current, {this.key = "CHAVE", this.grant = true}) : super(Dio());
  PushState current;
  final String? key;
  final bool grant;
  final calls = <String>[];

  @override
  Future<PushState> state() async => current;

  @override
  Future<String> publicKey() async {
    if (key == null) throw const ApiException("Os avisos ainda não estão configurados no servidor.");
    return key!;
  }

  @override
  Future<bool> enable(String publicKey) async {
    calls.add("enable:$publicKey");
    return grant;
  }

  @override
  Future<void> disable() async => calls.add("disable");

  @override
  Future<int> sendTest() async {
    calls.add("test");
    return 1;
  }
}

Future<void> _show(WidgetTester tester, _Fake fake) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [pushServiceProvider.overrideWithValue(fake)],
    child: const MaterialApp(home: Scaffold(body: PushTile())),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets("desligado → ligar (com a chave já trazida) → ligado; testar; desligar", (tester) async {
    final fake = _Fake(PushState.off);
    await _show(tester, fake);
    await tester.tap(find.text("Ligar avisos neste aparelho"));
    await tester.pumpAndSettle();
    expect(fake.calls, ["enable:CHAVE"]);
    expect(find.text("Avisos ligados neste aparelho."), findsOneWidget);
    expect(find.text("Ligados neste aparelho."), findsOneWidget);

    await tester.tap(find.text("Enviar aviso de teste"));
    await tester.pumpAndSettle();
    expect(find.text("Aviso de teste enviado. Deve chegar em segundos."), findsOneWidget);

    await tester.tap(find.text("Desligar"));
    await tester.pumpAndSettle();
    expect(fake.calls, ["enable:CHAVE", "test", "disable"]);
    expect(find.text("Ligar avisos neste aparelho"), findsOneWidget);
  });

  testWidgets("recusar a autorização: explica onde se volta a autorizar", (tester) async {
    await _show(tester, _Fake(PushState.off, grant: false));
    await tester.tap(find.text("Ligar avisos neste aparelho"));
    await tester.pumpAndSettle();
    expect(find.textContaining("estão bloqueados neste aparelho"), findsOneWidget);
    expect(find.text("Ligar avisos neste aparelho"), findsNothing);
  });

  testWidgets("iPhone fora do ecrã principal: diz como fazer, sem botões", (tester) async {
    await _show(tester, _Fake(PushState.homeScreen));
    expect(find.textContaining("Adicionar ao ecrã principal"), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets("servidor sem chaves: diz que não está configurado", (tester) async {
    await _show(tester, _Fake(PushState.off, key: null));
    expect(find.text("Os avisos ainda não estão configurados no servidor."), findsOneWidget);
  });
}
