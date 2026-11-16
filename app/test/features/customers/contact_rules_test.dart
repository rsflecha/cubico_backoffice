import 'package:cubico_backoffice/features/customers/domain/contact_rules.dart';
import 'package:cubico_backoffice/features/customers/domain/customer.dart';
import 'package:cubico_backoffice/features/customers/domain/postal_code.dart';
import 'package:cubico_backoffice/features/customers/presentation/customer_form_screen.dart';
import 'package:cubico_backoffice/features/customers/presentation/customers_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Uma base dos CTT de faz-de-conta, que conta quantas vezes lhe perguntam.
class _FakePostalCodes implements PostalCodeRepository {
  final asked = <String>[];

  @override
  Future<PostalCodeInfo?> lookup(String postalCode) async {
    asked.add(postalCode);
    if (postalCode != "3700-008") return null;
    return const PostalCodeInfo(
      postalCode: "3700-008",
      locality: "São João da Madeira",
      municipality: "São João da Madeira",
      district: "Aveiro",
    );
  }
}

void main() {
  group("telemóvel", () {
    test("portugueses: telemóvel e fixo, com espaços e indicativo", () {
      for (final ok in ["912345678", "912 345 678", "+351 912 345 678", "00351912345678", "229 876 543", "+351229876543"]) {
        expect(isValidPhone(ok), isTrue, reason: ok);
      }
    });

    test("portugueses errados", () {
      for (final bad in ["91234567", "9123456789", "812345678", "+351 812 345 678", "abc", "912-345-67x"]) {
        expect(isValidPhone(bad), isFalse, reason: bad);
      }
    });

    test("estrangeiros (Etsy): + ou 00 e 8 a 15 algarismos", () {
      expect(isValidPhone("+44 7700 900123"), isTrue);
      expect(isValidPhone("0049 151 23456789"), isTrue);
      expect(isValidPhone("+1 (555) 123-4567"), isTrue);
      expect(isValidPhone("+44 123"), isFalse);
      expect(isValidPhone("+1234567890123456"), isFalse); // 16 algarismos
    });

    test("o campo é opcional: vazio não é erro", () {
      expect(phoneError(""), isNull);
      expect(phoneError(null), isNull);
      expect(phoneError("123"), isNotNull);
    });
  });

  test("o hífen do código postal aparece sozinho e não passa dos 7 algarismos", () {
    final f = PtPostalCodeFormatter();
    String type(String text) => f.formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: text)).text;
    expect(type("4700"), "4700");
    expect(type("47000"), "4700-0");
    expect(type("4700000"), "4700-000");
    expect(type("4700-0009"), "4700-000");
    expect(type("47a00b000"), "4700-000");
  });

  test("a zona por baixo do campo não repete o concelho quando é igual ao distrito", () {
    const braga = PostalCodeInfo(postalCode: "4700-000", locality: "Braga", municipality: "Braga", district: "Braga");
    expect(braga.area, "Braga");
    const sjm = PostalCodeInfo(
        postalCode: "3700-008", locality: "São João da Madeira", municipality: "São João da Madeira", district: "Aveiro");
    expect(sjm.area, "São João da Madeira, Aveiro");
  });

  group("formulário do cliente", () {
    Future<_FakePostalCodes> show(WidgetTester tester) async {
      final fake = _FakePostalCodes();
      tester.view.physicalSize = const Size(900, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ProviderScope(
        overrides: [
          postalCodeRepositoryProvider.overrideWithValue(fake),
          customersProvider.overrideWith((ref) async => <Customer>[]),
        ],
        child: const MaterialApp(home: CustomerFormScreen()),
      ));
      await tester.pump();
      return fake;
    }

    Finder byLabel(String label) => find.widgetWithText(TextFormField, label);

    testWidgets("o código postal preenche a localidade e mostra o concelho", (tester) async {
      final fake = await show(tester);
      await tester.enterText(byLabel("Código postal"), "3700008");
      await tester.pumpAndSettle();

      expect(find.text("3700-008"), findsOneWidget); // o hífen apareceu
      expect(fake.asked, ["3700-008"]); // só pergunta com o código completo
      expect(find.text("São João da Madeira"), findsOneWidget); // a localidade
      expect(find.text("São João da Madeira, Aveiro"), findsOneWidget); // por baixo do campo
    });

    testWidgets("não troca uma localidade escrita à mão", (tester) async {
      await show(tester);
      await tester.enterText(byLabel("Localidade"), "Oliveira de Azeméis");
      await tester.enterText(byLabel("Código postal"), "3700008");
      await tester.pumpAndSettle();
      expect(find.text("Oliveira de Azeméis"), findsOneWidget);
    });

    testWidgets("código que não existe: avisa e deixa escrever", (tester) async {
      await show(tester);
      await tester.enterText(byLabel("Código postal"), "1234567");
      await tester.pumpAndSettle();
      expect(find.text("Código postal não encontrado nos CTT."), findsOneWidget);
    });

    testWidgets("telemóvel errado não deixa guardar", (tester) async {
      await show(tester);
      await tester.enterText(byLabel("Nome"), "Ana");
      await tester.enterText(byLabel("Telemóvel (opcional)"), "12345");
      await tester.tap(find.text("Guardar"));
      await tester.pumpAndSettle();
      expect(find.textContaining("Telemóvel inválido"), findsOneWidget);
    });
  });
}
