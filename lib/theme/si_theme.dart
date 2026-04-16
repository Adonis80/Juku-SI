import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'si_colors.dart';

class SiTheme {
  static ThemeData dark() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: SiColors.primary,
      onPrimary: Colors.black,
      primaryContainer: Color(0xFF0C4A6E),
      onPrimaryContainer: SiColors.textGlow,
      secondary: SiColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFF4C1D95),
      onSecondaryContainer: Color(0xFFEDE9FE),
      tertiary: SiColors.warning,
      onTertiary: Colors.black,
      error: SiColors.danger,
      onError: Colors.white,
      surface: SiColors.surface,
      onSurface: SiColors.textPrimary,
      outline: SiColors.outline,
      outlineVariant: Color(0xFF0F2040),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: SiColors.background,
      colorScheme: scheme,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: SiColors.background,
        foregroundColor: SiColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: SiColors.textGlow,
          letterSpacing: 2,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: SiColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: SiColors.outline, width: 0.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SiColors.surface,
        hintStyle: GoogleFonts.inter(color: SiColors.textMuted, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SiColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SiColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SiColors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: SiColors.primary,
          foregroundColor: Colors.black,
          minimumSize: const Size.fromHeight(48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
