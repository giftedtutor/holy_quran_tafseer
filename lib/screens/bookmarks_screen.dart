import 'package:flutter/material.dart';

import '../services/preferences_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/quran_navigation.dart';
import '../utils/rtl_navigation.dart';
import '../widgets/screen_header.dart';
import 'page_reader_screen.dart';
import 'surah_reader_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key, required this.prefs});

  final PreferencesService prefs;

  IconData _iconFor(BookmarkType type) => switch (type) {
        BookmarkType.page => Icons.menu_book_outlined,
        BookmarkType.surah => Icons.auto_stories_outlined,
        BookmarkType.juz => Icons.library_books_outlined,
        BookmarkType.verse => Icons.place_outlined,
      };

  void _openBookmark(BuildContext context, Bookmark bookmark) {
    switch (bookmark.type) {
      case BookmarkType.page:
        if (bookmark.page != null) {
          pushPage(
            context,
            PageReaderScreen(
              prefs: prefs,
              initialPage: bookmark.page,
            ),
          );
        }
      case BookmarkType.juz:
        final page = bookmark.juz != null ? juzStartPage(bookmark.juz!) : 1;
        pushPage(
          context,
          PageReaderScreen(
            prefs: prefs,
            initialPage: page,
          ),
        );
      case BookmarkType.surah:
        if (bookmark.surahId != null) {
          pushPage(
            context,
            SurahReaderScreen(
              prefs: prefs,
              surahId: bookmark.surahId!,
            ),
          );
        }
      case BookmarkType.verse:
        if (bookmark.surahId != null) {
          pushPage(
            context,
            SurahReaderScreen(
              prefs: prefs,
              surahId: bookmark.surahId!,
              initialAyahId: bookmark.ayahId,
            ),
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeData.fromDarkMode(prefs.isDarkMode);

    return ListenableBuilder(
      listenable: prefs,
      builder: (context, _) {
        final bookmarks = prefs.bookmarks;

        return Scaffold(
          backgroundColor: theme.background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ScreenHeader(
                  title: 'Bookmarks',
                  subtitle: bookmarks.isEmpty
                      ? 'No bookmarks yet'
                      : '${bookmarks.length} saved ${bookmarks.length == 1 ? 'place' : 'places'}',
                ),
                Expanded(
                  child: bookmarks.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bookmark_border, size: 56, color: theme.textMuted),
                                const SizedBox(height: 12),
                                Text('No bookmarks yet', style: AppTypography.h3(theme.text)),
                                Text(
                                  'Bookmark pages, surahs, or verses while reading',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.bodySmall(theme.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                          itemCount: bookmarks.length,
                          itemBuilder: (context, index) {
                            final bookmark = bookmarks[index];
                            return Dismissible(
                              key: ValueKey(bookmark.key),
                              direction: DismissDirection.endToStart,
                              onDismissed: (_) => prefs.removeBookmark(bookmark.key),
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Material(
                                  color: theme.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  child: InkWell(
                                    onTap: () => _openBookmark(context, bookmark),
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: theme.borderLight),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            _iconFor(bookmark.type),
                                            color: AppColors.primary,
                                            size: 28,
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  bookmark.label,
                                                  style: AppTypography.h3(theme.text).copyWith(fontSize: 16),
                                                ),
                                                Text(
                                                  bookmark.subtitle,
                                                  style: AppTypography.bodySmall(theme.textSecondary),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(Icons.chevron_right, color: theme.textMuted),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
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
