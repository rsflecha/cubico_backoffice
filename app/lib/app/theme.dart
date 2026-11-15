import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

/// Cores da marca CubicoDesign3D.
abstract final class AppColors {
  static const black = Color(0xFF18181B);
  static const background = Color(0xFFF4F3EF);
  static const orange = Color(0xFFC2410C); // provisório até haver cor oficial
}

/// Estilos de texto que não pertencem ao TextTheme.
abstract final class AppTextStyles {
  /// Valores, nº de encomenda e SKU.
  static TextStyle get mono => GoogleFonts.jetBrainsMono();
  static TextStyle get brand =>
      GoogleFonts.poppins(fontWeight: FontWeight.w600);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.orange,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  );

  final base = ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    inputDecorationTheme: const InputDecorationTheme(
      // a etiqueta fica sempre por cima, esteja o campo vazio ou não
      floatingLabelBehavior: FloatingLabelBehavior.always,
      // fundo branco: o campo destaca-se do cartão (antes era transparente
      // sobre o rosado do cartão, e no telemóvel quase não se via)
      filled: true,
      fillColor: Colors.white,
      // caixas com cantos arredondados, como nos desenhos
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      // borda cinzenta-escura bem visível (contraste ≥ 3:1 com o branco)
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Color(0xFF78716C)),
      ),
      // no campo onde se está a escrever, a borda fica laranja e mais grossa
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: AppColors.orange, width: 2),
      ),
      // a etiqueta ("Preço pago", "Cor"…) a escuro e mais forte
      labelStyle: TextStyle(color: AppColors.black, fontWeight: FontWeight.w600),
      floatingLabelStyle: TextStyle(color: AppColors.black, fontWeight: FontWeight.w600),
      // as ajudas por baixo podem ocupar até 3 linhas, em vez de serem cortadas
      helperMaxLines: 3,
      errorMaxLines: 3,
      isDense: true,
    ),
  );

  final manrope = GoogleFonts.manropeTextTheme(base.textTheme);

  return base.copyWith(
    textTheme: manrope.copyWith(
      displayLarge: GoogleFonts.poppins(textStyle: manrope.displayLarge),
      displayMedium: GoogleFonts.poppins(textStyle: manrope.displayMedium),
      displaySmall: GoogleFonts.poppins(textStyle: manrope.displaySmall),
      headlineLarge: GoogleFonts.poppins(textStyle: manrope.headlineLarge),
    ),
  );
}
