import 'package:quran_with_tafsir/quran_with_tafsir.dart';

const totalPages = 604;

const juzNames = [
  'Alif Lam Meem', 'Sayaqool', 'Tilkal Rusul', 'Lan Tanaloo', 'Wal Mohsanat',
  'La Yuhibbullah', 'Wa Iza Sami\'oo', 'Wa Lau Annana', 'Qalal Malao', 'Wa A\'lamu',
  'Yatazeroon', 'Wa Ma Min Da\'abbah', 'Wa Ma Ubarri\'oo', 'Rubama', 'Subhanallazi',
  'Qal Alam', 'Aqtaraba', 'Qad Aflaha', 'Wa Qalallazina', 'A\'man Khalaq',
  'Utlu Ma Oohi', 'Wa Man Yaqnut', 'Wa Mali', 'Faman Azlam', 'Elahi Yuraddu',
  'Ha\'a Meem', 'Qala Fama Khatbukum', 'Qad Sami\'a', 'Tabarakallazi', 'Amma Yatasa\'aloon',
];

int juzStartPage(int juz) {
  final ayahs = QuranService.instance.getJuz(juz);
  if (ayahs.isEmpty) return 1;
  return ayahs.first.page;
}
