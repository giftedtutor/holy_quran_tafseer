import 'package:flutter/material.dart';

import '../services/preferences_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/about_sections.dart';
import '../widgets/screen_header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.prefs});

  final PreferencesService prefs;

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeData.fromDarkMode(prefs.isDarkMode);
    final previewBg = pageBackground(prefs.pageBrightness, prefs.isDarkMode);

    return ListenableBuilder(
      listenable: prefs,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: theme.background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ScreenHeader(
                  title: 'Settings',
                  subtitle: 'Customize your reading experience',
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                    children: [
                      Text('Appearance', style: AppTypography.h3(theme.text)),
                      const SizedBox(height: 12),
                      _SettingRow(
                        theme: theme,
                        label: 'Dark Mode',
                        subtitle: 'Easier on the eyes in low light',
                        trailing: Switch(
                          value: prefs.isDarkMode,
                          onChanged: prefs.setDarkMode,
                          activeThumbColor: AppColors.accent,
                          activeTrackColor: AppColors.primaryLight,
                        ),
                      ),
                      _SliderSetting(
                        theme: theme,
                        label: 'Page Brightness',
                        subtitle: 'Adjust page reader background brightness',
                        value: prefs.pageBrightness.toDouble(),
                        min: 20,
                        max: 100,
                        divisions: 16,
                        display: '${prefs.pageBrightness}%',
                        onChanged: (v) => prefs.setPageBrightness(v.round()),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: previewBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: theme.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                              style: AppTheme.arabicText(
                                fontSize: prefs.arabicFontSize,
                                lineHeight: prefs.arabicLineHeight,
                                color: theme.textArabic,
                              ),
                            ),
                            Divider(color: theme.divider, height: 20),
                            Text(
                              'اللہ کے نام سے جو رحمان و رحیم ہے',
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                              style: AppTheme.translationText(
                                fontSize: prefs.translationFontSize,
                                color: theme.text,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text('Display', style: AppTypography.h3(theme.text)),
                      const SizedBox(height: 12),
                      _SettingRow(
                        theme: theme,
                        label: 'Show Translation',
                        subtitle: 'Urdu translation — Maulana Maududi',
                        trailing: Switch(
                          value: prefs.showTranslation,
                          onChanged: prefs.setShowTranslation,
                          activeThumbColor: AppColors.accent,
                          activeTrackColor: AppColors.primaryLight,
                        ),
                      ),
                      _SettingRow(
                        theme: theme,
                        label: 'Show Tafseer',
                        subtitle: 'Urdu tafseer — Ibn Kathir',
                        trailing: Switch(
                          value: prefs.showTafseer,
                          onChanged: prefs.setShowTafseer,
                          activeThumbColor: AppColors.accent,
                          activeTrackColor: AppColors.primaryLight,
                        ),
                      ),
                      Text('Reading', style: AppTypography.h3(theme.text)),
                      const SizedBox(height: 12),
                      _SliderSetting(
                        theme: theme,
                        label: 'Arabic Font Size',
                        subtitle: 'Controls Quran text size (20–50)',
                        value: prefs.arabicFontSize,
                        min: 20,
                        max: 50,
                        divisions: 30,
                        display: '${prefs.arabicFontSize.round()}px',
                        onChanged: prefs.setArabicFontSize,
                      ),
                      _SliderSetting(
                        theme: theme,
                        label: 'Translation Font Size',
                        subtitle: 'Urdu translation size (12–24)',
                        value: prefs.translationFontSize,
                        min: 12,
                        max: 24,
                        divisions: 12,
                        display: '${prefs.translationFontSize.round()}px',
                        onChanged: prefs.setTranslationFontSize,
                      ),
                      _SliderSetting(
                        theme: theme,
                        label: 'Tafseer Font Size',
                        subtitle: 'Urdu tafseer text size',
                        value: prefs.tafseerFontSize,
                        min: 14,
                        max: 28,
                        divisions: 14,
                        display: '${prefs.tafseerFontSize.round()}px',
                        onChanged: prefs.setTafseerFontSize,
                      ),
                      _SliderSetting(
                        theme: theme,
                        label: 'Line Spacing',
                        subtitle: 'Space between lines of Arabic text',
                        value: prefs.lineSpacing,
                        min: 1.2,
                        max: 2.5,
                        divisions: 13,
                        display: '${prefs.lineSpacing.toStringAsFixed(1)}x',
                        onChanged: prefs.setLineSpacing,
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: prefs.resetSettings,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Reset All Settings',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('About', style: AppTypography.h3(theme.text)),
                      const SizedBox(height: 12),
                      AuthenticityCard(theme: theme),
                      const SizedBox(height: 12),
                      DeveloperNoteCard(theme: theme),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.theme,
    required this.label,
    required this.subtitle,
    required this.trailing,
  });

  final AppThemeData theme;
  final String label;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.h3(theme.text).copyWith(fontSize: 16)),
                Text(subtitle, style: AppTypography.caption(theme.textSecondary)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _SliderSetting extends StatelessWidget {
  const _SliderSetting({
    required this.theme,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.display,
    required this.onChanged,
  });

  final AppThemeData theme;
  final String label;
  final String subtitle;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String display;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTypography.h3(theme.text).copyWith(fontSize: 16)),
                    Text(subtitle, style: AppTypography.caption(theme.textSecondary)),
                  ],
                ),
              ),
              Text(display, style: AppTypography.bodySmall(theme.textSecondary)),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
