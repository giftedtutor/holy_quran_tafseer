import 'package:flutter/material.dart';
import 'package:quran_with_tafsir/quran_with_tafsir.dart';

import '../services/preferences_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/arabic_utils.dart';

class PageAyahBlock extends StatelessWidget {
  const PageAyahBlock({
    super.key,
    required this.arabicAyah,
    required this.urduTranslation,
    required this.tafseerText,
    required this.prefs,
  });

  final Ayah arabicAyah;
  final String urduTranslation;
  final String? tafseerText;
  final PreferencesService prefs;

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeData.fromDarkMode(prefs.isDarkMode);
    final sajdahColor = theme.isDark ? AppColors.sajdahDark : AppColors.sajdah;
    final ink = theme.isDark ? AppColors.darkText : AppColors.text;
    final arabicColor = arabicAyah.isSajda ? sajdahColor : theme.textArabic;

    return ListenableBuilder(
      listenable: prefs,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      toArabicNumerals(arabicAyah.id),
                      style: AppTheme.arabicText(
                        fontSize: 11,
                        lineHeight: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  if (arabicAyah.isSajda) ...[
                    const SizedBox(width: 8),
                    Text(
                      'Sajdah',
                      textDirection: TextDirection.rtl,
                      style: AppTheme.translationText(fontSize: 12, color: sajdahColor),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                arabicAyah.text,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: AppTheme.arabicText(
                  fontSize: prefs.arabicFontSize,
                  lineHeight: prefs.arabicLineHeight,
                  color: arabicColor,
                ),
              ),
              if (prefs.showTranslation) ...[
                const SizedBox(height: 8),
                Text(
                  urduTranslation,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: AppTheme.translationText(
                    fontSize: prefs.translationFontSize - 1,
                    color: ink.withValues(alpha: 0.85),
                  ),
                ),
              ],
              if (prefs.showTafseer && tafseerText != null && tafseerText!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.tafseerBg.withValues(alpha: theme.isDark ? 0.6 : 1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: theme.borderLight),
                  ),
                  child: Text(
                    tafseerText!,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: AppTheme.tafseerText(
                      fontSize: prefs.tafseerFontSize - 2,
                      lineHeight: prefs.tafseerLineHeight,
                      color: ink,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
