import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quran_with_tafsir/quran_with_tafsir.dart';

import '../services/preferences_service.dart';
import '../services/urdu_quran_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/arabic_utils.dart';
import '../utils/quran_navigation.dart';
import '../utils/reader_viewport_builder.dart';
import '../utils/rtl_navigation.dart';
import '../widgets/screen_header.dart';
import '../widgets/viewport_paged_content.dart';
import 'page_jump_screen.dart';

class PageReaderScreen extends StatefulWidget {
  const PageReaderScreen({
    super.key,
    required this.prefs,
    this.initialPage,
  });

  final PreferencesService prefs;
  final int? initialPage;

  @override
  State<PageReaderScreen> createState() => _PageReaderScreenState();
}

class _PageReaderScreenState extends State<PageReaderScreen> {
  final _quran = QuranService.instance;
  final _urdu = UrduQuranService.instance;

  late int _quranPage;
  int _slideIndex = 0;
  int _slideCount = 1;
  final _tafsirCache = <int, Map<int, String>>{};

  @override
  void initState() {
    super.initState();
    _quranPage = widget.initialPage ?? widget.prefs.lastPage;
  }

  Future<Map<int, String>> _tafsirForSurah(int surahId) async {
    if (_tafsirCache.containsKey(surahId)) return _tafsirCache[surahId]!;
    final map = await _urdu.getTafseerForSurah(surahId);
    _tafsirCache[surahId] = map;
    return map;
  }

  int get _currentSurahId {
    final ayahs = _quran.getPage(_quranPage);
    if (ayahs.isEmpty) return 1;
    return ayahs.first.surahNumber;
  }

  Future<void> _togglePageBookmark() async {
    final ayahs = _quran.getPage(_quranPage);
    final subtitle = ayahs.isEmpty
        ? 'Page $_quranPage'
        : _quran.getSurahMetadata(ayahs.first.surahNumber).nameEn;
    await widget.prefs.togglePageBookmark(_quranPage, subtitle);
  }

  Future<void> _toggleSurahBookmark() async {
    final meta = _quran.getSurahMetadata(_currentSurahId);
    await widget.prefs.toggleSurahBookmark(
      surahId: meta.number,
      surahName: meta.nameAr,
      surahEnglishName: meta.nameEn,
    );
  }

  void _saveProgress() {
    widget.prefs.saveLastRead(page: _quranPage);
    final ayahs = _quran.getPage(_quranPage);
    if (ayahs.isNotEmpty) {
      widget.prefs.saveLastRead(
        surah: ayahs.first.surahNumber,
        ayah: ayahs.first.id,
        page: _quranPage,
      );
    }
  }

  void _goToQuranPage(int page) {
    if (page < 1 || page > totalPages) return;
    setState(() {
      _quranPage = page;
      _slideIndex = 0;
    });
    _saveProgress();
  }

  void _goToNextQuranPage() {
    if (_quranPage >= totalPages) return;
    _goToQuranPage(_quranPage + 1);
  }

  void _goToPreviousQuranPage() {
    if (_quranPage <= 1) return;
    _goToQuranPage(_quranPage - 1);
  }

  void _showBookmarkMenu() {
    final pageBookmarked = widget.prefs.isPageBookmarked(_quranPage);
    final surahBookmarked = widget.prefs.isSurahBookmarked(_currentSurahId);
    final meta = _quran.getSurahMetadata(_currentSurahId);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppThemeData.fromDarkMode(widget.prefs.isDarkMode).surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final theme = AppThemeData.fromDarkMode(widget.prefs.isDarkMode);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Bookmarks', style: AppTypography.h3(theme.text)),
                const SizedBox(height: 12),
                ListTile(
                  leading: Icon(
                    pageBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    pageBookmarked ? 'Remove page bookmark' : 'Bookmark this page',
                  ),
                  subtitle: Text('Page $_quranPage'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _togglePageBookmark();
                  },
                ),
                ListTile(
                  leading: Icon(
                    surahBookmarked ? Icons.bookmark : Icons.auto_stories_outlined,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    surahBookmarked ? 'Remove surah bookmark' : 'Bookmark this surah',
                  ),
                  subtitle: Text(
                    '${meta.nameEn} · ${meta.nameAr}',
                    textDirection: TextDirection.rtl,
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _toggleSurahBookmark();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageHeader({
    required int pageNumber,
    required List<Ayah> ayahs,
    required Color ink,
  }) {
    if (ayahs.isEmpty) {
      return Text('Page $pageNumber', style: AppTypography.bodySmall(ink));
    }

    final juz = ayahs.first.juz;
    final firstSurah = _quran.getSurahMetadata(ayahs.first.surahNumber);
    final lastSurah = _quran.getSurahMetadata(ayahs.last.surahNumber);
    final headerLabel = firstSurah.number == lastSurah.number
        ? '${firstSurah.nameAr} ${toArabicNumerals(ayahs.first.id)}-${toArabicNumerals(ayahs.last.id)}'
        : '${firstSurah.nameAr} - ${lastSurah.nameAr}';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                headerLabel,
                textDirection: TextDirection.rtl,
                style: AppTypography.caption(ink),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '$pageNumber',
              style: AppTypography.h3(ink).copyWith(fontSize: 14),
            ),
            Expanded(
              child: Text(
                'Juz $juz',
                textAlign: TextAlign.right,
                style: AppTypography.caption(ink),
              ),
            ),
          ],
        ),
        Divider(color: ink.withValues(alpha: 0.15), height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeData.fromDarkMode(widget.prefs.isDarkMode);

    return ListenableBuilder(
      listenable: widget.prefs,
      builder: (context, _) {
        final pageBookmarked = widget.prefs.isPageBookmarked(_quranPage);
        final surahBookmarked = widget.prefs.isSurahBookmarked(_currentSurahId);
        final anyBookmarked = pageBookmarked || surahBookmarked;
        final paper = pageBackground(widget.prefs.pageBrightness, theme.isDark);
        final ink = theme.isDark ? AppColors.darkText : AppColors.text;
        final arabicAyahs = _quran.getPage(_quranPage);
        final surahIds = arabicAyahs.map((a) => a.surahNumber).toSet();

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: theme.background,
            body: Column(
              children: [
                ReaderToolbar(
                  title: 'Page Reader',
                  counter: _slideCount > 1
                      ? 'Page $_quranPage · ${_slideIndex + 1}/$_slideCount'
                      : 'Page $_quranPage / $totalPages',
                  actions: [
                    IconButton(
                      onPressed: _showBookmarkMenu,
                      icon: Icon(
                        anyBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                        color: AppColors.accent,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        final page = await pushPage<int>(
                          context,
                          PageJumpScreen(prefs: widget.prefs),
                        );
                        if (page != null && mounted) {
                          _goToQuranPage(page);
                        }
                      },
                      icon: const Icon(Icons.pin_outlined, color: AppColors.accentLight),
                      tooltip: 'Go to page',
                    ),
                  ],
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final contentWidth = constraints.maxWidth - 40;
                      final contentHeight = constraints.maxHeight - 24;

                      return FutureBuilder<List<Map<int, String>>>(
                        future: Future.wait(surahIds.map(_tafsirForSurah)),
                        builder: (context, snapshot) {
                          final tafseerMaps = <int, Map<int, String>>{};
                          if (snapshot.hasData) {
                            var i = 0;
                            for (final id in surahIds) {
                              tafseerMaps[id] = snapshot.data![i++];
                            }
                          }

                          final header = _buildPageHeader(
                            pageNumber: _quranPage,
                            ayahs: arabicAyahs,
                            ink: ink,
                          );

                          final pages = buildAyahViewportPages(
                            ayahs: arabicAyahs,
                            prefs: widget.prefs,
                            maxWidth: contentWidth,
                            maxHeight: contentHeight,
                            leadingHeader: header,
                            leadingHeaderHeight: arabicAyahs.isEmpty ? 24 : 52,
                            translationFor: (surahId, ayahId) =>
                                _urdu.getTranslation(surahId, ayahId) ?? '',
                            tafseerFor: (surahId, ayahId) =>
                                tafseerMaps[surahId]?[ayahId],
                          );

                          if (_slideCount != pages.length) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) setState(() => _slideCount = pages.length);
                            });
                          }

                          return ViewportPagedContent(
                            key: ValueKey('page-$_quranPage-${widget.prefs.arabicFontSize}-${widget.prefs.showTranslation}-${widget.prefs.showTafseer}'),
                            controller: null,
                            backgroundColor: paper,
                            pages: pages.isEmpty ? [[]] : pages,
                            onSlideChanged: (index) {
                              setState(() => _slideIndex = index);
                              _saveProgress();
                            },
                            onRequestNext: _goToNextQuranPage,
                            onRequestPrevious: _goToPreviousQuranPage,
                          );
                        },
                      );
                    },
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
