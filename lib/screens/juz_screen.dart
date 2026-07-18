import 'package:flutter/material.dart';

import '../services/preferences_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/quran_navigation.dart';
import '../utils/rtl_navigation.dart';
import '../widgets/screen_header.dart';
import 'page_reader_screen.dart';

class JuzScreen extends StatelessWidget {
  const JuzScreen({super.key, required this.prefs});

  final PreferencesService prefs;

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeData.fromDarkMode(prefs.isDarkMode);

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenHeader(
              title: 'Juz / Para',
              subtitle: '30 Parts of the Quran',
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                itemCount: 30,
                itemBuilder: (context, index) {
                  final juz = index + 1;
                  final startPage = juzStartPage(juz);
                  return ListenableBuilder(
                    listenable: prefs,
                    builder: (context, _) {
                      final bookmarked = prefs.isJuzBookmarked(juz);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          color: theme.surface,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            onTap: () => pushPage(
                              context,
                              PageReaderScreen(
                                prefs: prefs,
                                initialPage: startPage,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: theme.borderLight),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primaryLight,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '$juz',
                                      style: AppTypography.h3(AppColors.accent).copyWith(fontSize: 18),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Juz $juz', style: AppTypography.h3(theme.text)),
                                        Text(
                                          juzNames[index],
                                          style: AppTypography.bodySmall(theme.textSecondary),
                                        ),
                                        Text(
                                          'Starts at page $startPage',
                                          style: AppTypography.caption(theme.textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => prefs.toggleJuzBookmark(
                                      juz: juz,
                                      subtitle: juzNames[index],
                                    ),
                                    icon: Icon(
                                      bookmarked ? Icons.bookmark : Icons.bookmark_outline,
                                      color: bookmarked ? AppColors.accent : AppColors.primary,
                                    ),
                                  ),
                                  Icon(Icons.chevron_right, color: theme.textMuted),
                                ],
                              ),
                            ),
                          ),
                        ),
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
  }
}
