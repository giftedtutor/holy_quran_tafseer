import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum BookmarkType { page, verse, surah, juz }

class Bookmark {
  const Bookmark({
    required this.type,
    required this.label,
    required this.subtitle,
    required this.savedAt,
    this.page,
    this.surahId,
    this.ayahId,
    this.surahName,
    this.surahEnglishName,
    this.juz,
  });

  final BookmarkType type;
  final String label;
  final String subtitle;
  final DateTime savedAt;
  final int? page;
  final int? surahId;
  final int? ayahId;
  final String? surahName;
  final String? surahEnglishName;
  final int? juz;

  String get key => switch (type) {
        BookmarkType.page => 'page:$page',
        BookmarkType.juz => 'juz:$juz',
        BookmarkType.surah => 'surah:$surahId',
        BookmarkType.verse => 'verse:$surahId:$ayahId',
      };

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'label': label,
        'subtitle': subtitle,
        'savedAt': savedAt.toIso8601String(),
        'page': page,
        'surahId': surahId,
        'ayahId': ayahId,
        'surahName': surahName,
        'surahEnglishName': surahEnglishName,
        'juz': juz,
      };

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String? ?? 'verse';
    return Bookmark(
      type: BookmarkType.values.firstWhere(
        (t) => t.name == typeName,
        orElse: () => BookmarkType.verse,
      ),
      label: json['label'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      savedAt: DateTime.parse(json['savedAt'] as String),
      page: json['page'] as int?,
      surahId: json['surahId'] as int?,
      ayahId: json['ayahId'] as int?,
      surahName: json['surahName'] as String?,
      surahEnglishName: json['surahEnglishName'] as String?,
      juz: json['juz'] as int?,
    );
  }
}

class PreferencesService extends ChangeNotifier {
  static const _darkModeKey = 'dark_mode';
  static const _arabicFontSizeKey = 'arabic_font_size';
  static const _translationFontSizeKey = 'translation_font_size';
  static const _tafseerFontSizeKey = 'tafseer_font_size';
  static const _lineSpacingKey = 'line_spacing';
  static const _pageBrightnessKey = 'page_brightness';
  static const _showTranslationKey = 'show_translation';
  static const _showTafseerKey = 'show_tafseer';
  static const _lastSurahKey = 'last_surah';
  static const _lastAyahKey = 'last_ayah';
  static const _lastPageKey = 'last_page';
  static const _bookmarksKey = 'bookmarks';

  bool _isDarkMode = false;
  double _arabicFontSize = 27;
  double _translationFontSize = 16;
  double _tafseerFontSize = 18;
  double _lineSpacing = 1.5;
  int _pageBrightness = 70;
  bool _showTranslation = true;
  bool _showTafseer = true;
  int _lastSurah = 1;
  int _lastAyah = 1;
  int _lastPage = 1;
  List<Bookmark> _bookmarks = [];

  bool get isDarkMode => _isDarkMode;
  double get arabicFontSize => _arabicFontSize;
  double get translationFontSize => _translationFontSize;
  double get tafseerFontSize => _tafseerFontSize;
  double get lineSpacing => _lineSpacing;
  int get pageBrightness => _pageBrightness;
  bool get showTranslation => _showTranslation;
  bool get showTafseer => _showTafseer;
  int get lastSurah => _lastSurah;
  int get lastAyah => _lastAyah;
  int get lastPage => _lastPage;
  List<Bookmark> get bookmarks => List.unmodifiable(_bookmarks);
  double get arabicLineHeight => _arabicFontSize * _lineSpacing;
  double get tafseerLineHeight => _tafseerFontSize * 1.8;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    _arabicFontSize = prefs.getDouble(_arabicFontSizeKey) ?? 27;
    _translationFontSize = prefs.getDouble(_translationFontSizeKey) ?? 16;
    _tafseerFontSize = prefs.getDouble(_tafseerFontSizeKey) ?? 18;
    _lineSpacing = prefs.getDouble(_lineSpacingKey) ?? 1.5;
    _pageBrightness = prefs.getInt(_pageBrightnessKey) ?? 70;
    _showTranslation = prefs.getBool(_showTranslationKey) ?? true;
    _showTafseer = prefs.getBool(_showTafseerKey) ?? true;
    _lastSurah = prefs.getInt(_lastSurahKey) ?? 1;
    _lastAyah = prefs.getInt(_lastAyahKey) ?? 1;
    _lastPage = prefs.getInt(_lastPageKey) ?? 1;

    final bookmarksJson = prefs.getString(_bookmarksKey);
    if (bookmarksJson != null) {
      final list = jsonDecode(bookmarksJson) as List<dynamic>;
      _bookmarks = list
          .map((e) => Bookmark.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    notifyListeners();
  }

  Future<void> resetSettings() async {
    _isDarkMode = false;
    _arabicFontSize = 27;
    _translationFontSize = 16;
    _tafseerFontSize = 18;
    _lineSpacing = 1.5;
    _pageBrightness = 70;
    _showTranslation = true;
    _showTafseer = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_darkModeKey);
    await prefs.remove(_arabicFontSizeKey);
    await prefs.remove(_translationFontSizeKey);
    await prefs.remove(_tafseerFontSizeKey);
    await prefs.remove(_lineSpacingKey);
    await prefs.remove(_pageBrightnessKey);
    await prefs.remove(_showTranslationKey);
    await prefs.remove(_showTafseerKey);
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  Future<void> setArabicFontSize(double value) async {
    _arabicFontSize = value.clamp(20, 50);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_arabicFontSizeKey, _arabicFontSize);
  }

  Future<void> setTranslationFontSize(double value) async {
    _translationFontSize = value.clamp(12, 24);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_translationFontSizeKey, _translationFontSize);
  }

  Future<void> setTafseerFontSize(double value) async {
    _tafseerFontSize = value.clamp(14, 28);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_tafseerFontSizeKey, _tafseerFontSize);
  }

  Future<void> setLineSpacing(double value) async {
    _lineSpacing = value.clamp(1.2, 2.5);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_lineSpacingKey, _lineSpacing);
  }

  Future<void> setPageBrightness(int value) async {
    _pageBrightness = value.clamp(20, 100);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pageBrightnessKey, _pageBrightness);
  }

  Future<void> setShowTranslation(bool value) async {
    _showTranslation = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showTranslationKey, value);
  }

  Future<void> setShowTafseer(bool value) async {
    _showTafseer = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showTafseerKey, value);
  }

  Future<void> saveLastRead({int? surah, int? ayah, int? page}) async {
    if (surah != null) _lastSurah = surah.clamp(1, 114);
    if (ayah != null) _lastAyah = ayah.clamp(1, 286);
    if (page != null) _lastPage = page.clamp(1, 604);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (surah != null) await prefs.setInt(_lastSurahKey, _lastSurah);
    if (ayah != null) await prefs.setInt(_lastAyahKey, _lastAyah);
    if (page != null) await prefs.setInt(_lastPageKey, _lastPage);
  }

  bool isPageBookmarked(int page) =>
      _bookmarks.any((b) => b.type == BookmarkType.page && b.page == page);

  bool isVerseBookmarked(int surahId, int ayahId) => _bookmarks.any(
        (b) =>
            b.type == BookmarkType.verse &&
            b.surahId == surahId &&
            b.ayahId == ayahId,
      );

  bool isSurahBookmarked(int surahId) =>
      _bookmarks.any((b) => b.type == BookmarkType.surah && b.surahId == surahId);

  bool isJuzBookmarked(int juz) =>
      _bookmarks.any((b) => b.type == BookmarkType.juz && b.juz == juz);

  Future<void> togglePageBookmark(int page, String subtitle) async {
    final key = 'page:$page';
    final existing = _bookmarks.indexWhere((b) => b.key == key);
    if (existing >= 0) {
      _bookmarks.removeAt(existing);
    } else {
      _bookmarks.insert(
        0,
        Bookmark(
          type: BookmarkType.page,
          page: page,
          label: 'Page $page',
          subtitle: subtitle,
          savedAt: DateTime.now(),
        ),
      );
    }
    notifyListeners();
    await _saveBookmarks();
  }

  Future<void> toggleSurahBookmark({
    required int surahId,
    required String surahName,
    required String surahEnglishName,
  }) async {
    final key = 'surah:$surahId';
    final existing = _bookmarks.indexWhere((b) => b.key == key);
    if (existing >= 0) {
      _bookmarks.removeAt(existing);
    } else {
      _bookmarks.insert(
        0,
        Bookmark(
          type: BookmarkType.surah,
          surahId: surahId,
          surahName: surahName,
          surahEnglishName: surahEnglishName,
          label: surahName,
          subtitle: surahEnglishName,
          savedAt: DateTime.now(),
        ),
      );
    }
    notifyListeners();
    await _saveBookmarks();
  }

  Future<void> toggleVerseBookmark({
    required int surahId,
    required int ayahId,
    required String surahName,
    required String surahEnglishName,
    required String preview,
  }) async {
    final key = 'verse:$surahId:$ayahId';
    final existing = _bookmarks.indexWhere((b) => b.key == key);
    if (existing >= 0) {
      _bookmarks.removeAt(existing);
    } else {
      _bookmarks.insert(
        0,
        Bookmark(
          type: BookmarkType.verse,
          surahId: surahId,
          ayahId: ayahId,
          surahName: surahName,
          surahEnglishName: surahEnglishName,
          label: '$surahEnglishName · Ayah $ayahId',
          subtitle: preview,
          savedAt: DateTime.now(),
        ),
      );
    }
    notifyListeners();
    await _saveBookmarks();
  }

  Future<void> toggleJuzBookmark({
    required int juz,
    required String subtitle,
  }) async {
    final key = 'juz:$juz';
    final existing = _bookmarks.indexWhere((b) => b.key == key);
    if (existing >= 0) {
      _bookmarks.removeAt(existing);
    } else {
      _bookmarks.insert(
        0,
        Bookmark(
          type: BookmarkType.juz,
          juz: juz,
          label: 'Juz $juz',
          subtitle: subtitle,
          savedAt: DateTime.now(),
        ),
      );
    }
    notifyListeners();
    await _saveBookmarks();
  }

  Future<void> removeBookmark(String key) async {
    _bookmarks.removeWhere((b) => b.key == key);
    notifyListeners();
    await _saveBookmarks();
  }

  Future<void> _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_bookmarks.map((b) => b.toJson()).toList());
    await prefs.setString(_bookmarksKey, encoded);
  }
}
