import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF0D4A3E);
  static const primaryLight = Color(0xFF1A6B5C);
  static const primaryDark = Color(0xFF083028);
  static const accent = Color(0xFFC9A227);
  static const accentLight = Color(0xFFE8C84A);
  static const background = Color(0xFFF8F6F1);
  static const surface = Color(0xFFFFFFFF);
  static const text = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF5C5C5C);
  static const textMuted = Color(0xFF8A8A8A);
  static const textOnPrimary = Color(0xFFFFFFFF);
  static const textArabic = Color(0xFF0D4A3E);
  static const border = Color(0xFFE8E4DC);
  static const borderLight = Color(0xFFF0ECE4);
  static const divider = Color(0xFFEDE9E1);
  static const error = Color(0xFFC0392B);
  static const bookmark = Color(0xFFC9A227);
  static const sajdah = Color(0xFF1A6B5C);
  static const sajdahDark = Color(0xFF4DB89E);
  static const tafseerBg = Color(0xFFF3F0E8);

  static const darkBackground = Color(0xFF0A1F1A);
  static const darkSurface = Color(0xFF122A24);
  static const darkSurfaceElevated = Color(0xFF1A3830);
  static const darkText = Color(0xFFF5F0E8);
  static const darkTextSecondary = Color(0xFFB8B0A4);
  static const darkTextMuted = Color(0xFF7A7268);
  static const darkTextArabic = Color(0xFFE8C84A);
  static const darkBorder = Color(0xFF1F3D35);
  static const darkBorderLight = Color(0xFF163028);
  static const darkDivider = Color(0xFF1A3028);
  static const darkTafseerBg = Color(0xFF152822);
}

Color pageBackground(int brightness, bool darkMode) {
  final t = brightness.clamp(0, 100) / 100.0;
  if (darkMode) {
    final r = (10 + t * 30).round();
    final g = (18 + t * 35).round();
    final b = (16 + t * 30).round();
    return Color.fromARGB(255, r, g, b);
  }
  final r = (232 + t * 23).round();
  final g = (226 + t * 29).round();
  final b = (216 + t * 39).round();
  return Color.fromARGB(255, r, g, b);
}

class AppThemeData {
  const AppThemeData({
    required this.isDark,
    required this.background,
    required this.surface,
    required this.text,
    required this.textSecondary,
    required this.textMuted,
    required this.textArabic,
    required this.border,
    required this.borderLight,
    required this.divider,
    required this.tafseerBg,
  });

  final bool isDark;
  final Color background;
  final Color surface;
  final Color text;
  final Color textSecondary;
  final Color textMuted;
  final Color textArabic;
  final Color border;
  final Color borderLight;
  final Color divider;
  final Color tafseerBg;

  static AppThemeData fromDarkMode(bool isDark) {
    if (isDark) {
      return const AppThemeData(
        isDark: true,
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        text: AppColors.darkText,
        textSecondary: AppColors.darkTextSecondary,
        textMuted: AppColors.darkTextMuted,
        textArabic: AppColors.darkTextArabic,
        border: AppColors.darkBorder,
        borderLight: AppColors.darkBorderLight,
        divider: AppColors.darkDivider,
        tafseerBg: AppColors.darkTafseerBg,
      );
    }
    return const AppThemeData(
      isDark: false,
      background: AppColors.background,
      surface: AppColors.surface,
      text: AppColors.text,
      textSecondary: AppColors.textSecondary,
      textMuted: AppColors.textMuted,
      textArabic: AppColors.textArabic,
      border: AppColors.border,
      borderLight: AppColors.borderLight,
      divider: AppColors.divider,
      tafseerBg: AppColors.tafseerBg,
    );
  }
}
