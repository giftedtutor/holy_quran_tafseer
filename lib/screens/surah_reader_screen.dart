import 'package:flutter/material.dart';
import 'package:quran_with_tafsir/quran_with_tafsir.dart';

import '../services/preferences_service.dart';
import '../services/urdu_quran_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/reader_viewport_builder.dart';
import '../widgets/screen_header.dart';
import '../widgets/viewport_paged_content.dart';

class SurahReaderScreen extends StatefulWidget {
  const SurahReaderScreen({
    super.key,
    required this.prefs,
    required this.surahId,
    this.initialAyahId,
  });

  final PreferencesService prefs;
  final int surahId;
  final int? initialAyahId;

  @override
  State<SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends State<SurahReaderScreen> {
  final _quran = QuranService.instance;
  final _urdu = UrduQuranService.instance;
  late final Surah _arabicSurah;

  Map<int, String> _urduTranslations = {};
  Map<int, String> _urduTafseer = {};
  bool _loadingUrdu = true;
  late int _ayahIndex;
  int _slideIndex = 0;
  int _slideCount = 1;

  @override
  void initState() {
    super.initState();
    _arabicSurah = _quran.getSurah(widget.surahId);
    _ayahIndex = ((widget.initialAyahId ?? 1) - 1).clamp(
      0,
      _arabicSurah.verses.length - 1,
    );
    _loadUrduContent();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.prefs.saveLastRead(
        surah: widget.surahId,
        ayah: widget.initialAyahId ?? 1,
      );
    });
  }

  Future<void> _loadUrduContent() async {
    final translations = <int, String>{};
    for (final ayah in _arabicSurah.verses) {
      translations[ayah.id] =
          _urdu.getTranslation(widget.surahId, ayah.id) ?? '';
    }
    final tafseer = await _urdu.getTafseerForSurah(widget.surahId);
    if (!mounted) return;
    setState(() {
      _urduTranslations = translations;
      _urduTafseer = tafseer;
      _loadingUrdu = false;
    });
  }

  void _saveAyahProgress() {
    widget.prefs.saveLastRead(
      surah: widget.surahId,
      ayah: _arabicSurah.verses[_ayahIndex].id,
    );
  }

  void _goToAyah(int index) {
    if (index < 0 || index >= _arabicSurah.verses.length) return;
    setState(() {
      _ayahIndex = index;
      _slideIndex = 0;
    });
    _saveAyahProgress();
  }

  void _goToNextAyah() {
    if (_ayahIndex >= _arabicSurah.verses.length - 1) return;
    _goToAyah(_ayahIndex + 1);
  }

  void _goToPreviousAyah() {
    if (_ayahIndex <= 0) return;
    _goToAyah(_ayahIndex - 1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeData.fromDarkMode(widget.prefs.isDarkMode);
    final meta = _quran.getSurahMetadata(widget.surahId);
    final totalAyahs = _arabicSurah.verses.length;
    final currentAyah = _arabicSurah.verses[_ayahIndex];

    return ListenableBuilder(
      listenable: widget.prefs,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: theme.background,
          body: Column(
            children: [
              ReaderToolbar(
                title: meta.nameEn,
                subtitle: meta.nameAr,
                counter: _slideCount > 1
                    ? 'Ayah ${_ayahIndex + 1} · ${_slideIndex + 1}/$_slideCount'
                    : 'Ayah ${_ayahIndex + 1} / $totalAyahs',
                actions: [
                  IconButton(
                    onPressed: () {
                      widget.prefs.toggleSurahBookmark(
                        surahId: widget.surahId,
                        surahName: meta.nameAr,
                        surahEnglishName: meta.nameEn,
                      );
                    },
                    icon: Icon(
                      widget.prefs.isSurahBookmarked(widget.surahId)
                          ? Icons.bookmark
                          : Icons.bookmark_outline,
                      color: widget.prefs.isSurahBookmarked(widget.surahId)
                          ? AppColors.accent
                          : AppColors.accentLight,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.visibility_outlined, color: AppColors.accentLight),
                    onSelected: (value) {
                      switch (value) {
                        case 'translation':
                          widget.prefs.setShowTranslation(!widget.prefs.showTranslation);
                        case 'tafseer':
                          widget.prefs.setShowTafseer(!widget.prefs.showTafseer);
                      }
                    },
                    itemBuilder: (context) => [
                      CheckedPopupMenuItem(
                        value: 'translation',
                        checked: widget.prefs.showTranslation,
                        child: const Text('Show Translation'),
                      ),
                      CheckedPopupMenuItem(
                        value: 'tafseer',
                        checked: widget.prefs.showTafseer,
                        child: const Text('Show Tafseer'),
                      ),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: _loadingUrdu
                    ? Center(
                        child: Text(
                          'Loading Urdu translation and tafseer...',
                          style: AppTheme.translationText(
                            fontSize: 16,
                            color: theme.textSecondary,
                          ),
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final contentWidth = constraints.maxWidth - 40;
                          final contentHeight = constraints.maxHeight - 24;
                          final leadingHeader = _ayahIndex == 0
                              ? _SurahHeader(
                                  theme: theme,
                                  meta: meta,
                                  englishName: meta.nameEn,
                                  prefs: widget.prefs,
                                )
                              : null;
                          final leadingHeaderHeight = _ayahIndex == 0 ? 180.0 : 0.0;

                          final pages = buildSurahAyahViewportPages(
                            ayah: currentAyah,
                            prefs: widget.prefs,
                            arabicText: currentAyah.text,
                            translationText: _urduTranslations[currentAyah.id] ?? '',
                            tafseerText: _urduTafseer[currentAyah.id],
                            maxWidth: contentWidth,
                            maxHeight: contentHeight - leadingHeaderHeight,
                            leadingHeader: leadingHeader,
                            leadingHeaderHeight: leadingHeaderHeight,
                          );

                          if (_slideCount != pages.length) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) setState(() => _slideCount = pages.length);
                            });
                          }

                          return ViewportPagedContent(
                            key: ValueKey(
                              'ayah-$_ayahIndex-${widget.prefs.arabicFontSize}-${widget.prefs.showTranslation}-${widget.prefs.showTafseer}',
                            ),
                            backgroundColor: theme.background,
                            pages: pages.isEmpty ? [[]] : pages,
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                            onSlideChanged: (index) => setState(() => _slideIndex = index),
                            onRequestNext: _goToNextAyah,
                            onRequestPrevious: _goToPreviousAyah,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SurahHeader extends StatelessWidget {
  const _SurahHeader({
    required this.theme,
    required this.meta,
    required this.englishName,
    required this.prefs,
  });

  final AppThemeData theme;
  final SurahMetadata meta;
  final String englishName;
  final PreferencesService prefs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            meta.nameAr,
            textDirection: TextDirection.rtl,
            style: AppTheme.arabicText(
              fontSize: 28,
              lineHeight: 40,
              color: AppColors.accentLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            englishName,
            style: AppTypography.h2(AppColors.textOnPrimary).copyWith(fontSize: 22),
          ),
          const SizedBox(height: 8),
          Text(
            '${meta.ayahCount} Ayahs · ${meta.revelationType ?? ''}',
            style: AppTypography.bodySmall(
              AppColors.textOnPrimary.withValues(alpha: 0.85),
            ),
          ),
          if (meta.number != 1 && meta.number != 9) ...[
            const SizedBox(height: 16),
            Text(
              'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: AppTheme.arabicText(
                fontSize: prefs.arabicFontSize,
                lineHeight: prefs.arabicLineHeight,
                color: AppColors.accent,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
