import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTypography {
  static TextStyle h1(Color color) => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: color,
      );

  static TextStyle h2(Color color) => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle h3(Color color) => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle body(Color color) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: color,
      );

  static TextStyle bodySmall(Color color) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color,
      );

  static TextStyle caption(Color color) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color,
      );
}

class AppTheme {
  static const quranFontFamily = 'PDMSSaleemQuranFont';
  static const tafseerFontFamily = 'AmiriQuran';
  static const urduFontFamily = 'NotoNastaliqUrdu';

  static TextStyle arabicText({
    required double fontSize,
    required double lineHeight,
    required Color color,
  }) {
    return TextStyle(
      fontFamily: quranFontFamily,
      fontSize: fontSize,
      height: lineHeight / fontSize,
      color: color,
      letterSpacing: 0.2,
    );
  }

  static TextStyle tafseerText({
    required double fontSize,
    required double lineHeight,
    required Color color,
  }) {
    return TextStyle(
      fontFamily: urduFontFamily,
      fontFamilyFallback: const [urduFontFamily, 'Arial'],
      fontSize: fontSize,
      height: lineHeight / fontSize,
      color: color,
    );
  }

  static TextStyle translationText({
    required double fontSize,
    required Color color,
  }) {
    return TextStyle(
      fontFamily: urduFontFamily,
      fontFamilyFallback: const [urduFontFamily, 'Arial'],
      fontSize: fontSize,
      height: 1.85,
      color: color,
    );
  }

  static ThemeData materialTheme(bool isDark) {
    final app = AppThemeData.fromDarkMode(isDark);
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: app.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: app.surface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: app.background,
        foregroundColor: app.text,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: app.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: app.borderLight),
        ),
      ),
      dividerTheme: DividerThemeData(color: app.divider),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: app.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : app.textMuted,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: app.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: app.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: app.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
