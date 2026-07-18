import 'package:flutter/material.dart';
import 'package:quran_with_tafsir/quran_with_tafsir.dart';

import '../services/preferences_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/arabic_utils.dart';

class AyahCard extends StatelessWidget {
  const AyahCard({
    super.key,
    required this.ayah,
    required this.arabicText,
    required this.translationText,
    required this.tafseerText,
    required this.prefs,
    this.highlight = false,
    this.onBookmarkTap,
  });

  final Ayah ayah;
  final String arabicText;
  final String translationText;
  final String? tafseerText;
  final PreferencesService prefs;
  final bool highlight;
  final VoidCallback? onBookmarkTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeData.fromDarkMode(prefs.isDarkMode);
    final sajdahColor = theme.isDark ? AppColors.sajdahDark : AppColors.sajdah;

    return ListenableBuilder(
      listenable: prefs,
      builder: (context, _) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: highlight ? AppColors.accent : theme.borderLight,
              width: highlight ? 1.5 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        toArabicNumerals(ayah.id),
                        style: AppTheme.arabicText(
                          fontSize: 14,
                          lineHeight: 20,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (ayah.isSajda)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: sajdahColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Sajdah',
                          textDirection: TextDirection.rtl,
                          style: AppTheme.translationText(
                            fontSize: 12,
                            color: sajdahColor,
                          ),
                        ),
                      ),
                    const Spacer(),
                    if (onBookmarkTap != null)
                      IconButton(
                        onPressed: onBookmarkTap,
                        icon: Icon(
                          prefs.isVerseBookmarked(ayah.surahNumber, ayah.id)
                              ? Icons.bookmark
                              : Icons.bookmark_outline,
                          color: prefs.isVerseBookmarked(ayah.surahNumber, ayah.id)
                              ? AppColors.accent
                              : AppColors.primary,
                          size: 22,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                    Text(
                      'Juz ${ayah.juz}',
                      textDirection: TextDirection.rtl,
                      style: AppTheme.translationText(
                        fontSize: 12,
                        color: theme.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  arabicText,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: AppTheme.arabicText(
                    fontSize: prefs.arabicFontSize,
                    lineHeight: prefs.arabicLineHeight,
                    color: ayah.isSajda ? sajdahColor : theme.textArabic,
                  ),
                ),
                if (prefs.showTranslation) ...[
                  Divider(color: theme.divider, height: 24),
                  Row(
                    children: [
                      Icon(Icons.translate, size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Translation',
                        textDirection: TextDirection.rtl,
                        style: AppTheme.translationText(
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    translationText,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: AppTheme.translationText(
                      fontSize: prefs.translationFontSize,
                      color: theme.text,
                    ),
                  ),
                ],
                if (prefs.showTafseer && tafseerText != null && tafseerText!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.tafseerBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.menu_book_outlined, size: 14, color: AppColors.accent),
                            const SizedBox(width: 6),
                            Text(
                              'Tafseer Ibn Kathir',
                              textDirection: TextDirection.rtl,
                              style: AppTheme.translationText(
                                fontSize: 12,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tafseerText!,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: AppTheme.tafseerText(
                            fontSize: prefs.tafseerFontSize,
                            lineHeight: prefs.tafseerLineHeight,
                            color: theme.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
