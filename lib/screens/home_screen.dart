import 'package:flutter/material.dart';
import 'package:quran_with_tafsir/quran_with_tafsir.dart';

import '../services/preferences_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/rtl_navigation.dart';
import '../widgets/screen_header.dart';
import 'page_jump_screen.dart';
import 'page_reader_screen.dart';
import 'search_screen.dart';
import 'surah_reader_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.prefs,
    required this.onSelectTab,
  });

  final PreferencesService prefs;
  final ValueChanged<int> onSelectTab;

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final _quran = QuranService.instance;

  void _openSurah(int surahId, {int? ayahId}) {
    pushRtl(
      context,
      SurahReaderScreen(
        prefs: widget.prefs,
        surahId: surahId,
        initialAyahId: ayahId,
      ),
    );
  }

  void _openPageReader({int? page}) {
    pushRtl(
      context,
      PageReaderScreen(
        prefs: widget.prefs,
        initialPage: page,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeData.fromDarkMode(widget.prefs.isDarkMode);
    final lastSurahMeta = _quran.getSurahMetadata(widget.prefs.lastSurah);

    return Scaffold(
      backgroundColor: theme.background,
      body: Column(
        children: [
          HomeHeader(
            arabicLine: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
            title: 'Quran Tafseer & Translation',
            subtitle: 'التفسير والترجمة',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              children: [
                _ContinueCard(
                  surahName: lastSurahMeta.nameEn,
                  surahNameAr: lastSurahMeta.nameAr,
                  ayahId: widget.prefs.lastAyah,
                  page: widget.prefs.lastPage,
                  theme: theme,
                  onTapSurah: () => _openSurah(
                    widget.prefs.lastSurah,
                    ayahId: widget.prefs.lastAyah,
                  ),
                  onTapPage: () => _openPageReader(page: widget.prefs.lastPage),
                ),
                const SizedBox(height: 24),
                Text('Quick Access', style: AppTypography.h3(theme.text)),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _QuickAction(
                      icon: Icons.auto_stories_outlined,
                      title: 'Page Reader',
                      subtitle: '604 pages',
                      theme: theme,
                      onTap: () => _openPageReader(),
                    ),
                    _QuickAction(
                      icon: Icons.format_list_bulleted,
                      title: 'Surahs',
                      subtitle: '114 chapters',
                      theme: theme,
                      onTap: () => widget.onSelectTab(1),
                    ),
                    _QuickAction(
                      icon: Icons.library_books_outlined,
                      title: 'Juz / Para',
                      subtitle: '30 parts',
                      theme: theme,
                      onTap: () => widget.onSelectTab(2),
                    ),
                    _QuickAction(
                      icon: Icons.bookmark_outline,
                      title: 'Bookmarks',
                      subtitle: 'Saved places',
                      theme: theme,
                      onTap: () => widget.onSelectTab(3),
                    ),
                    _QuickAction(
                      icon: Icons.search_outlined,
                      title: 'Search',
                      subtitle: 'Arabic & Urdu',
                      theme: theme,
                      onTap: () => pushRtl(
                        context,
                        SearchScreen(prefs: widget.prefs),
                      ),
                    ),
                    _QuickAction(
                      icon: Icons.pin_outlined,
                      title: 'Go to Page',
                      subtitle: 'Jump to page',
                      theme: theme,
                      onTap: () async {
                        final page = await pushRtl<int>(
                          context,
                          PageJumpScreen(prefs: widget.prefs),
                        );
                        if (page != null && context.mounted) {
                          _openPageReader(page: page);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
    required this.surahName,
    required this.surahNameAr,
    required this.ayahId,
    required this.page,
    required this.theme,
    required this.onTapSurah,
    required this.onTapPage,
  });

  final String surahName;
  final String surahNameAr;
  final int ayahId;
  final int page;
  final AppThemeData theme;
  final VoidCallback onTapSurah;
  final VoidCallback onTapPage;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.surface,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accent),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: onTapPage,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.auto_stories_outlined, color: AppColors.accent),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Continue Page Reading',
                            style: AppTypography.h3(theme.text).copyWith(fontSize: 16),
                          ),
                          Text(
                            'Page $page of 604',
                            style: AppTypography.bodySmall(theme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_left, color: AppColors.primary, size: 28),
                  ],
                ),
              ),
            ),
            Divider(color: theme.divider, height: 1),
            InkWell(
              onTap: onTapSurah,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.menu_book, color: AppColors.accent),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Continue Surah Reading',
                            style: AppTypography.h3(theme.text).copyWith(fontSize: 16),
                          ),
                          Text(
                            '$surahName · Ayah $ayahId',
                            style: AppTypography.bodySmall(theme.textSecondary),
                          ),
                          Text(
                            surahNameAr,
                            textDirection: TextDirection.rtl,
                            style: AppTheme.arabicText(
                              fontSize: 16,
                              lineHeight: 24,
                              color: theme.textArabic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_left, color: AppColors.primary, size: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.theme,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final AppThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.sizeOf(context).width - 52) / 2;
    return SizedBox(
      width: width,
      child: Material(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: AppColors.primary, size: 28),
                const SizedBox(height: 8),
                Text(title, style: AppTypography.h3(theme.text).copyWith(fontSize: 16)),
                Text(subtitle, style: AppTypography.caption(theme.textMuted)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
