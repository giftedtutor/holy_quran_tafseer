import 'package:flutter/material.dart';
import 'package:quran_with_tafsir/quran_with_tafsir.dart';

import '../services/preferences_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/arabic_utils.dart';
import '../utils/viewport_pagination.dart';

const _metaRowHeight = 36.0;
const _blockGap = 14.0;
const _sectionGap = 8.0;
const _tafseerBoxPadding = 24.0;

List<List<ViewportSegment>> buildAyahViewportPages({
  required List<Ayah> ayahs,
  required PreferencesService prefs,
  required double maxWidth,
  required double maxHeight,
  required String Function(int surahId, int ayahId) translationFor,
  required String? Function(int surahId, int ayahId) tafseerFor,
  Widget? leadingHeader,
  double leadingHeaderHeight = 0,
}) {
  final theme = AppThemeData.fromDarkMode(prefs.isDarkMode);
  final ink = theme.isDark ? AppColors.darkText : AppColors.text;
  final segments = <ViewportSegment>[];

  if (leadingHeader != null && leadingHeaderHeight > 0) {
    segments.add(
      ViewportSegment(
        estimatedHeight: leadingHeaderHeight,
        builder: (_) => leadingHeader,
      ),
    );
  }

  for (final ayah in ayahs) {
    segments.addAll(
      _ayahSegments(
        ayah: ayah,
        prefs: prefs,
        theme: theme,
        ink: ink,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        translation: translationFor(ayah.surahNumber, ayah.id),
        tafseer: tafseerFor(ayah.surahNumber, ayah.id),
      ),
    );
  }

  return packSegmentsIntoViewportPages(
    segments: segments,
    maxHeight: maxHeight,
  );
}

List<ViewportSegment> _ayahSegments({
  required Ayah ayah,
  required PreferencesService prefs,
  required AppThemeData theme,
  required Color ink,
  required double maxWidth,
  required double maxHeight,
  required String translation,
  required String? tafseer,
}) {
  final sajdahColor = theme.isDark ? AppColors.sajdahDark : AppColors.sajdah;
  final arabicColor = ayah.isSajda ? sajdahColor : theme.textArabic;
  final arabicStyle = AppTheme.arabicText(
    fontSize: prefs.arabicFontSize,
    lineHeight: prefs.arabicLineHeight,
    color: arabicColor,
  );
  final translationStyle = AppTheme.translationText(
    fontSize: prefs.translationFontSize,
    color: ink.withValues(alpha: 0.9),
  );
  final tafseerStyle = AppTheme.tafseerText(
    fontSize: prefs.tafseerFontSize - 1,
    lineHeight: prefs.tafseerLineHeight,
    color: ink,
  );

  Widget metaRow() => Row(
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
              toArabicNumerals(ayah.id),
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1,
                color: AppColors.primary,
              ),
            ),
          ),
          if (ayah.isSajda) ...[
            const SizedBox(width: 8),
            Text(
              'Sajdah',
              style: AppTheme.translationText(fontSize: 12, color: sajdahColor),
            ),
          ],
        ],
      );

  final arabicHeight = measureTextHeight(
    text: ayah.text,
    style: arabicStyle,
    maxWidth: maxWidth,
  );
  final headerBlockHeight = _metaRowHeight + _sectionGap + arabicHeight;

  Widget arabicBlock({bool includeMeta = true}) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (includeMeta) ...[
            metaRow(),
            const SizedBox(height: _sectionGap),
          ],
          Text(
            ayah.text,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: arabicStyle,
          ),
        ],
      );

  Widget translationBlock(String text) => Text(
        text,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: translationStyle,
      );

  Widget tafseerBlock(String text, {String? label}) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.tafseerBg.withValues(alpha: theme.isDark ? 0.6 : 1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (label != null) ...[
              Text(
                label,
                textAlign: TextAlign.right,
                style: AppTheme.translationText(
                  fontSize: 11,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              text,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: tafseerStyle,
            ),
          ],
        ),
      );

  final segments = <ViewportSegment>[];
  final showTranslation = prefs.showTranslation && translation.isNotEmpty;
  final showTafseer = prefs.showTafseer && tafseer != null && tafseer.isNotEmpty;

  if (!showTranslation && !showTafseer) {
    segments.add(
      ViewportSegment(
        estimatedHeight: headerBlockHeight + _metaRowHeight * 0.5,
        builder: (_) => arabicBlock(),
      ),
    );
    return segments;
  }

  final translationChunks = showTranslation
      ? paginateText(
          text: translation,
          style: translationStyle,
          maxWidth: maxWidth,
          maxHeight: maxHeight * 0.45,
        )
      : <String>[];
  final tafseerChunks = showTafseer
      ? paginateText(
          text: tafseer,
          style: tafseerStyle,
          maxWidth: maxWidth - 24,
          maxHeight: maxHeight * 0.45,
        )
      : <String>[];

  var chunkIndex = 0;
  var tafseerIndex = 0;
  var tafseerPart = 0;
  var isFirst = true;

  while (isFirst || chunkIndex < translationChunks.length || tafseerIndex < tafseerChunks.length) {
    final parts = <Widget>[];
    var estimated = 0.0;

    if (isFirst) {
      parts.add(metaRow());
      estimated += _metaRowHeight + _sectionGap;
      parts.add(Text(
        ayah.text,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: arabicStyle,
      ));
      estimated += arabicHeight + _sectionGap;
      isFirst = false;
    }

    if (chunkIndex < translationChunks.length) {
      final chunk = translationChunks[chunkIndex++];
      final chunkHeight = measureTextHeight(
        text: chunk,
        style: translationStyle,
        maxWidth: maxWidth,
      );
      parts.add(translationBlock(chunk));
      estimated += chunkHeight + _sectionGap;
    } else if (tafseerIndex < tafseerChunks.length) {
      final chunk = tafseerChunks[tafseerIndex++];
      tafseerPart++;
      final chunkHeight = measureTextHeight(
        text: chunk,
        style: tafseerStyle,
        maxWidth: maxWidth - 24,
      );
      parts.add(tafseerBlock(
        chunk,
        label: tafseerPart == 1 ? 'Tafseer' : 'Tafseer (cont.)',
      ));
      estimated += chunkHeight + _tafseerBoxPadding + _sectionGap + 18;
    } else {
      break;
    }

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < parts.length; i++) ...[
          if (i > 0) const SizedBox(height: _sectionGap),
          parts[i],
        ],
      ],
    );

    segments.add(
      ViewportSegment(
        estimatedHeight: estimated + _blockGap,
        builder: (_) => column,
      ),
    );
  }

  if (segments.isEmpty) {
    segments.add(
      ViewportSegment(
        estimatedHeight: headerBlockHeight,
        builder: (_) => arabicBlock(),
      ),
    );
  }

  return segments;
}

List<List<ViewportSegment>> buildSurahAyahViewportPages({
  required Ayah ayah,
  required PreferencesService prefs,
  required String arabicText,
  required String translationText,
  required String? tafseerText,
  required double maxWidth,
  required double maxHeight,
  Widget? leadingHeader,
  double leadingHeaderHeight = 0,
}) {
  return buildAyahViewportPages(
    ayahs: [ayah],
    prefs: prefs,
    maxWidth: maxWidth,
    maxHeight: maxHeight,
    leadingHeader: leadingHeader,
    leadingHeaderHeight: leadingHeaderHeight,
    translationFor: (surahId, ayahId) => translationText,
    tafseerFor: (surahId, ayahId) => tafseerText,
  );
}
