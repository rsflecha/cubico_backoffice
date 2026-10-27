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
  static TextStyle get brand => GoogleFonts.poppins(fontWeight: FontWeight.w600);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.orange,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  );

  final base = ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
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