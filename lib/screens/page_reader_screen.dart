import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quran_with_tafsir/quran_with_tafsir.dart';

import '../services/preferences_service.dart';
import '../services/urdu_quran_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/arabic_utils.dart';
import '../utils/quran_navigation.dart';
import '../utils/rtl_navigation.dart';
import '../widgets/page_ayah_block.dart';
import '../widgets/screen_header.dart';
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
  late final PageController _controller;
  late int _currentPage;
  final _tafsirCache = <int, Map<int, String>>{};

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage ?? widget.prefs.lastPage;
    _controller = PageController(initialPage: _currentPage - 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<Map<int, String>> _tafsirForSurah(int surahId) async {
    if (_tafsirCache.containsKey(surahId)) return _tafsirCache[surahId]!;
    final map = await _urdu.getTafseerForSurah(surahId);
    _tafsirCache[surahId] = map;
    return map;
  }

  int get _currentSurahId {
    final ayahs = _quran.getPage(_currentPage);
    if (ayahs.isEmpty) return 1;
    return ayahs.first.surahNumber;
  }

  Future<void> _togglePageBookmark() async {
    final ayahs = _quran.getPage(_currentPage);
    final subtitle = ayahs.isEmpty
        ? 'Page $_currentPage'
        : _quran.getSurahMetadata(ayahs.first.surahNumber).nameEn;
    await widget.prefs.togglePageBookmark(_currentPage, subtitle);
  }

  Future<void> _toggleSurahBookmark() async {
    final meta = _quran.getSurahMetadata(_currentSurahId);
    await widget.prefs.toggleSurahBookmark(
      surahId: meta.number,
      surahName: meta.nameAr,
      surahEnglishName: meta.nameEn,
    );
  }

  void _showBookmarkMenu() {
    final pageBookmarked = widget.prefs.isPageBookmarked(_currentPage);
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
                Text(
                  'Bookmarks',
                  style: AppTypography.h3(theme.text),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: Icon(
                    pageBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    pageBookmarked ? 'Remove page bookmark' : 'Bookmark this page',
                  ),
                  subtitle: Text('Page $_currentPage'),
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

  Widget _buildPage(int pageNumber) {
    final theme = AppThemeData.fromDarkMode(widget.prefs.isDarkMode);
    final paper = pageBackground(widget.prefs.pageBrightness, theme.isDark);
    final ink = theme.isDark ? AppColors.darkText : AppColors.text;
    final arabicAyahs = _quran.getPage(pageNumber);

    if (arabicAyahs.isEmpty) {
      return ColoredBox(
        color: paper,
        child: Center(
          child: Text(
            'Page $pageNumber',
            textDirection: TextDirection.rtl,
            style: AppTheme.translationText(fontSize: 14, color: ink),
          ),
        ),
      );
    }

    final juz = arabicAyahs.first.juz;
    final firstSurah = _quran.getSurahMetadata(arabicAyahs.first.surahNumber);
    final lastSurah = _quran.getSurahMetadata(arabicAyahs.last.surahNumber);
    final headerLabel = firstSurah.number == lastSurah.number
        ? '${firstSurah.nameAr} ${toArabicNumerals(arabicAyahs.first.id)}-${toArabicNumerals(arabicAyahs.last.id)}'
        : '${firstSurah.nameAr} - ${lastSurah.nameAr}';

    final surahIds = arabicAyahs.map((a) => a.surahNumber).toSet();

    return ColoredBox(
      color: paper,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    headerLabel,
                    textDirection: TextDirection.rtl,
                    style: AppTheme.translationText(fontSize: 12, color: ink),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  toArabicNumerals(pageNumber),
                  style: AppTheme.arabicText(
                    fontSize: 14,
                    lineHeight: 20,
                    color: ink,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Juz $juz',
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: AppTheme.translationText(fontSize: 12, color: ink),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: ink.withValues(alpha: 0.15), height: 1),
          Expanded(
            child: FutureBuilder<List<Map<int, String>>>(
              future: Future.wait(surahIds.map(_tafsirForSurah)),
              builder: (context, snapshot) {
                final tafseerMaps = <int, Map<int, String>>{};
                if (snapshot.hasData) {
                  var i = 0;
                  for (final id in surahIds) {
                    tafseerMaps[id] = snapshot.data![i++];
                  }
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  itemCount: arabicAyahs.length,
                  itemBuilder: (context, index) {
                    final arabic = arabicAyahs[index];
                    return PageAyahBlock(
                      arabicAyah: arabic,
                      urduTranslation: _urdu.getTranslation(arabic.surahNumber, arabic.id) ?? '',
                      tafseerText: tafseerMaps[arabic.surahNumber]?[arabic.id],
                      prefs: widget.prefs,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeData.fromDarkMode(widget.prefs.isDarkMode);

    return ListenableBuilder(
      listenable: widget.prefs,
      builder: (context, _) {
        final pageBookmarked = widget.prefs.isPageBookmarked(_currentPage);
        final surahBookmarked = widget.prefs.isSurahBookmarked(_currentSurahId);
        final anyBookmarked = pageBookmarked || surahBookmarked;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: theme.background,
            body: Column(
              children: [
                ReaderToolbar(
                  title: 'Page Reader',
                  counter: '($_currentPage/$totalPages)',
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
                        final page = await pushRtl<int>(
                          context,
                          PageJumpScreen(prefs: widget.prefs),
                        );
                        if (page != null && mounted) {
                          _controller.jumpToPage(page - 1);
                          setState(() => _currentPage = page);
                          widget.prefs.saveLastRead(page: page);
                        }
                      },
                      icon: const Icon(Icons.pin_outlined, color: AppColors.accentLight),
                      tooltip: 'Go to page',
                    ),
                  ],
                ),
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: totalPages,
                      onPageChanged: (index) {
                        final page = index + 1;
                        setState(() => _currentPage = page);
                        widget.prefs.saveLastRead(page: page);
                        final ayahs = _quran.getPage(page);
                        if (ayahs.isNotEmpty) {
                          widget.prefs.saveLastRead(
                            surah: ayahs.first.surahNumber,
                            ayah: ayahs.first.id,
                            page: page,
                          );
                        }
                      },
                      itemBuilder: (context, index) => _buildPage(index + 1),
                    ),
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
