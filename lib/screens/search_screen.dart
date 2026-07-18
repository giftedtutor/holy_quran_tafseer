import 'package:flutter/material.dart';
import 'package:quran_with_tafsir/quran_with_tafsir.dart';

import '../services/preferences_service.dart';
import '../services/urdu_quran_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/arabic_utils.dart';
import '../utils/rtl_navigation.dart';
import '../widgets/screen_header.dart';
import 'surah_reader_screen.dart';

enum _SearchMode { arabic, urdu }

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.prefs});

  final PreferencesService prefs;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _quran = QuranService.instance;
  final _urdu = UrduQuranService.instance;
  final _controller = TextEditingController();
  _SearchMode _mode = _SearchMode.urdu;
  List<Ayah> _arabicResults = [];
  List<UrduAyahMatch> _urduResults = [];
  bool _searched = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _arabicResults = [];
        _urduResults = [];
        _searched = false;
      });
      return;
    }
    setState(() {
      if (_mode == _SearchMode.arabic) {
        _arabicResults = _quran.search(query, limit: 50);
        _urduResults = [];
      } else {
        _urduResults = _urdu.searchTranslation(query, limit: 50);
        _arabicResults = [];
      }
      _searched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeData.fromDarkMode(widget.prefs.isDarkMode);
    final hasResults = _mode == _SearchMode.arabic
        ? _arabicResults.isNotEmpty
        : _urduResults.isNotEmpty;

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenHeader(
              showBack: true,
              title: 'Search',
              subtitle: 'Search Arabic Quran or Urdu translation',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: _mode == _SearchMode.arabic
                      ? 'Search in Arabic...'
                      : 'Search in Urdu...',
                  hintTextDirection: TextDirection.rtl,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _controller.clear();
                            _search('');
                          },
                        )
                      : null,
                ),
                onChanged: _search,
                textDirection: TextDirection.rtl,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SegmentedButton<_SearchMode>(
                segments: const [
                  ButtonSegment(
                    value: _SearchMode.arabic,
                    label: Text('Arabic'),
                  ),
                  ButtonSegment(
                    value: _SearchMode.urdu,
                    label: Text('Urdu'),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (selection) {
                  setState(() => _mode = selection.first);
                  _search(_controller.text);
                },
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.textOnPrimary;
                    }
                    return theme.text;
                  }),
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.primary;
                    }
                    return theme.surface;
                  }),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: !hasResults
                  ? Center(
                      child: Text(
                        _searched ? 'No results found' : 'Type to search',
                        style: AppTheme.translationText(
                          fontSize: 14,
                          color: theme.textMuted,
                        ),
                      ),
                    )
                  : _mode == _SearchMode.arabic
                      ? _buildArabicResults(theme)
                      : _buildUrduResults(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArabicResults(AppThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: _arabicResults.length,
      itemBuilder: (context, index) {
        final ayah = _arabicResults[index];
        final meta = _quran.getSurahMetadata(ayah.surahNumber);
        return _SearchResultCard(
          theme: theme,
          badge: '${meta.nameAr} ${toArabicNumerals(ayah.id)}',
          title: meta.nameAr,
          body: truncateArabic(ayah.text, maxLength: 120),
          bodyStyle: AppTheme.arabicText(
            fontSize: 18,
            lineHeight: 28,
            color: theme.textArabic,
          ),
          onTap: () => pushPage(
            context,
            SurahReaderScreen(
              prefs: widget.prefs,
              surahId: ayah.surahNumber,
              initialAyahId: ayah.id,
            ),
          ),
        );
      },
    );
  }

  Widget _buildUrduResults(AppThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: _urduResults.length,
      itemBuilder: (context, index) {
        final match = _urduResults[index];
        final meta = _quran.getSurahMetadata(match.surahId);
        return _SearchResultCard(
          theme: theme,
          badge: '${meta.nameEn} · Ayah ${match.ayahId}',
          title: meta.nameAr,
          body: truncateArabic(match.translation, maxLength: 120),
          bodyStyle: AppTheme.translationText(fontSize: 15, color: theme.text),
          onTap: () => pushPage(
            context,
            SurahReaderScreen(
              prefs: widget.prefs,
              surahId: match.surahId,
              initialAyahId: match.ayahId,
            ),
          ),
        );
      },
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.theme,
    required this.badge,
    required this.title,
    required this.body,
    required this.bodyStyle,
    required this.onTap,
  });

  final AppThemeData theme;
  final String badge;
  final String title;
  final String body;
  final TextStyle bodyStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badge,
                        textDirection: TextDirection.rtl,
                        style: AppTheme.translationText(fontSize: 12, color: AppColors.accent),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      title,
                      textDirection: TextDirection.rtl,
                      style: AppTheme.arabicText(
                        fontSize: 16,
                        lineHeight: 24,
                        color: theme.textArabic,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  body,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: bodyStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
