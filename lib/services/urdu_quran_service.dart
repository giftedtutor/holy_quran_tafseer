import 'dart:convert';

import 'package:flutter/services.dart';

class UrduSurahMeta {
  const UrduSurahMeta({
    required this.id,
    required this.nameArabic,
    required this.nameUrdu,
    required this.transliteration,
  });

  final int id;
  final String nameArabic;
  final String nameUrdu;
  final String transliteration;
}

class UrduAyahMatch {
  const UrduAyahMatch({
    required this.surahId,
    required this.ayahId,
    required this.translation,
  });

  final int surahId;
  final int ayahId;
  final String translation;
}

class UrduQuranService {
  UrduQuranService._();

  static final UrduQuranService instance = UrduQuranService._();

  final _translations = <int, Map<int, String>>{};
  final _tafseerCache = <int, Map<int, String>>{};
  final _surahMeta = <int, UrduSurahMeta>{};

  bool _loaded = false;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;

    final raw = await rootBundle.loadString('assets/data/quran_ur.json');
    final surahs = jsonDecode(raw) as List<dynamic>;

    for (final item in surahs) {
      final map = item as Map<String, dynamic>;
      final id = map['id'] as int;
      _surahMeta[id] = UrduSurahMeta(
        id: id,
        nameArabic: map['name'] as String? ?? '',
        nameUrdu: map['translation'] as String? ?? '',
        transliteration: map['transliteration'] as String? ?? '',
      );

      final verses = map['verses'] as List<dynamic>;
      final ayahMap = <int, String>{};
      for (final verse in verses) {
        final v = verse as Map<String, dynamic>;
        ayahMap[v['id'] as int] = v['translation'] as String? ?? '';
      }
      _translations[id] = ayahMap;
    }

    _loaded = true;
  }

  UrduSurahMeta? surahMeta(int surahId) => _surahMeta[surahId];

  String getSurahNameUrdu(int surahId) =>
      _surahMeta[surahId]?.nameUrdu ?? 'سورت $surahId';

  String? getTranslation(int surahId, int ayahId) =>
      _translations[surahId]?[ayahId];

  Future<Map<int, String>> getTafseerForSurah(int surahId) async {
    if (_tafseerCache.containsKey(surahId)) {
      return _tafseerCache[surahId]!;
    }

    final raw = await rootBundle.loadString('assets/data/tafseer/$surahId.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final ayahs = data['ayahs'] as List<dynamic>;
    final map = <int, String>{};
    for (final item in ayahs) {
      final ayah = item as Map<String, dynamic>;
      map[ayah['ayah'] as int] = ayah['text'] as String? ?? '';
    }
    _tafseerCache[surahId] = map;
    return map;
  }

  Future<String?> getTafseer(int surahId, int ayahId) async {
    final tafseer = await getTafseerForSurah(surahId);
    return tafseer[ayahId];
  }

  List<UrduAyahMatch> searchTranslation(String query, {int limit = 50}) {
    if (query.trim().isEmpty) return [];
    final q = query.trim();
    final results = <UrduAyahMatch>[];

    for (final entry in _translations.entries) {
      for (final ayah in entry.value.entries) {
        if (ayah.value.contains(q)) {
          results.add(
            UrduAyahMatch(
              surahId: entry.key,
              ayahId: ayah.key,
              translation: ayah.value,
            ),
          );
          if (results.length >= limit) return results;
        }
      }
    }
    return results;
  }
}
