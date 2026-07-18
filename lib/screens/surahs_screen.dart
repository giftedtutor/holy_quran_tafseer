import 'package:flutter/material.dart';
import 'package:quran_with_tafsir/quran_with_tafsir.dart';

import '../services/preferences_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/rtl_navigation.dart';
import '../widgets/screen_header.dart';
import 'surah_reader_screen.dart';

class SurahsScreen extends StatefulWidget {
  const SurahsScreen({super.key, required this.prefs});

  final PreferencesService prefs;

  @override
  State<SurahsScreen> createState() => _SurahsScreenState();
}

class _SurahsScreenState extends State<SurahsScreen> {
  String _query = '';
  final _quran = QuranService.instance;

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeData.fromDarkMode(widget.prefs.isDarkMode);
    var surahs = _quran.getAllSurahs();
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      surahs = surahs
          .where(
            (s) =>
                s.nameEn.toLowerCase().contains(q) ||
                s.nameAr.contains(_query) ||
                '${s.number}' == _query,
          )
          .toList();
    }

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenHeader(
              title: 'Surahs',
              subtitle: '114 Chapters',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search surah by name or number...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: surahs.length,
                itemBuilder: (context, index) {
                  final surah = surahs[index];
                  return _SurahCard(
                    theme: theme,
                    prefs: widget.prefs,
                    surahId: surah.number,
                    number: surah.number,
                    name: surah.nameEn,
                    nameArabic: surah.nameAr,
                    versesCount: surah.ayahCount,
                    revelation: surah.revelationType ?? '',
                    onTap: () => pushRtl(
                      context,
                      SurahReaderScreen(
                        prefs: widget.prefs,
                        surahId: surah.number,
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
  }
}

class _SurahCard extends StatelessWidget {
  const _SurahCard({
    required this.theme,
    required this.prefs,
    required this.surahId,
    required this.number,
    required this.name,
    required this.nameArabic,
    required this.versesCount,
    required this.revelation,
    required this.onTap,
  });

  final AppThemeData theme;
  final PreferencesService prefs;
  final int surahId;
  final int number;
  final String name;
  final String nameArabic;
  final int versesCount;
  final String revelation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: prefs,
      builder: (context, _) {
        final bookmarked = prefs.isSurahBookmarked(surahId);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
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
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$number',
                        style: AppTypography.h3(AppColors.accent).copyWith(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: AppTypography.h3(theme.text).copyWith(fontSize: 16),
                                ),
                              ),
                              Text(
                                nameArabic,
                                textDirection: TextDirection.rtl,
                                style: AppTheme.arabicText(
                                  fontSize: 18,
                                  lineHeight: 28,
                                  color: theme.textArabic,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$versesCount Ayahs · $revelation',
                            style: AppTypography.caption(theme.textMuted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => prefs.toggleSurahBookmark(
                        surahId: surahId,
                        surahName: nameArabic,
                        surahEnglishName: name,
                      ),
                      icon: Icon(
                        bookmarked ? Icons.bookmark : Icons.bookmark_outline,
                        color: bookmarked ? AppColors.accent : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
