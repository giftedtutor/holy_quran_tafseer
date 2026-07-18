import 'package:flutter/material.dart';
import 'package:quran_with_tafsir/quran_with_tafsir.dart';

import '../services/preferences_service.dart';
import '../services/urdu_quran_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/ayah_card.dart';
import '../widgets/screen_header.dart';

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
  late final PageController _pageController;
  late final Surah _arabicSurah;

  Map<int, String> _urduTranslations = {};
  Map<int, String> _urduTafseer = {};
  bool _loadingUrdu = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _arabicSurah = _quran.getSurah(widget.surahId);
    final initialIndex = ((widget.initialAyahId ?? 1) - 1).clamp(
      0,
      _arabicSurah.verses.length - 1,
    );
    _currentIndex = initialIndex;
    _pageController = PageController(initialPage: initialIndex);
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    widget.prefs.saveLastRead(
      surah: widget.surahId,
      ayah: _arabicSurah.verses[index].id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeData.fromDarkMode(widget.prefs.isDarkMode);
    final meta = _quran.getSurahMetadata(widget.surahId);
    final totalAyahs = _arabicSurah.verses.length;

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
                counter: 'Ayah ${_currentIndex + 1} / $totalAyahs',
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
                    : PageView.builder(
                        controller: _pageController,
                        itemCount: totalAyahs,
                        onPageChanged: _onPageChanged,
                        itemBuilder: (context, index) {
                          final arabicAyah = _arabicSurah.verses[index];
                          return SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                            child: Column(
                              children: [
                                if (index == 0)
                                  _SurahHeader(
                                    theme: theme,
                                    meta: meta,
                                    englishName: meta.nameEn,
                                    prefs: widget.prefs,
                                  ),
                                if (index == 0) const SizedBox(height: 16),
                                AyahCard(
                                  ayah: arabicAyah,
                                  arabicText: arabicAyah.text,
                                  translationText: _urduTranslations[arabicAyah.id] ?? '',
                                  tafseerText: _urduTafseer[arabicAyah.id],
                                  prefs: widget.prefs,
                                  highlight: widget.initialAyahId == arabicAyah.id,
                                  onBookmarkTap: () {
                                    widget.prefs.toggleVerseBookmark(
                                      surahId: widget.surahId,
                                      ayahId: arabicAyah.id,
                                      surahName: meta.nameAr,
                                      surahEnglishName: meta.nameEn,
                                      preview: _urduTranslations[arabicAyah.id] ?? arabicAyah.text,
                                    );
                                  },
                                ),
                              ],
                            ),
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
