library;

// ---------------------------------------------------------------------------
// Internal data imports
// ---------------------------------------------------------------------------
import 'package:quran_data_kit/src/data/juzs.dart';
import 'package:quran_data_kit/src/data/page_data.dart';
import 'package:quran_data_kit/src/data/quarters.dart';
import 'package:quran_data_kit/src/data/quran_data.dart';
import 'package:quran_data_kit/src/data/sajdah_verses.dart';
import 'package:quran_data_kit/src/data/suwar.dart';
import 'package:quran_data_kit/src/models/ayah.dart';
import 'package:quran_data_kit/src/models/quran_page.dart';
import 'package:quran_data_kit/src/models/quarter.dart';
import 'package:quran_data_kit/src/models/surah.dart';
import 'package:quran_data_kit/src/services/get_page.dart';
import 'package:quran_data_kit/src/utils/quran_helpers.dart';

// ---------------------------------------------------------------------------
// 1. UI Widgets
// ---------------------------------------------------------------------------
export 'src/widgets/quran_page_view.dart';
export 'src/widgets/quran_single_page_widget.dart';
export 'src/widgets/surah_header_widget.dart';
export 'src/widgets/surah_text_widget.dart';
export 'src/widgets/basmallah_widget.dart';

// ---------------------------------------------------------------------------
// 2. Models
// ---------------------------------------------------------------------------
export 'src/models/ayah.dart';
export 'src/models/highlight_verse.dart';
export 'src/models/highlight_word.dart';
export 'src/models/quran_page.dart';
export 'src/models/quarter.dart';
export 'src/models/random_verse.dart';
export 'src/models/surah.dart';

// ---------------------------------------------------------------------------
// 3. Raw Data
// ---------------------------------------------------------------------------
export 'src/data/juzs.dart';
export 'src/data/page_data.dart';
export 'src/data/quarters.dart';
export 'src/data/sajdah_verses.dart';
export 'src/data/suwar.dart';

// ---------------------------------------------------------------------------
// 4. Services & Utilities
// ---------------------------------------------------------------------------
export 'src/services/get_page.dart';
export 'src/utils/font_loader_service.dart';
export 'src/utils/quran_helpers.dart';
export 'src/utils/quran_text_styles.dart';
export 'src/utils/quran_translation.dart';

// ---------------------------------------------------------------------------
// 5. Global Constants
// ---------------------------------------------------------------------------

/// Total pages in the standard Hafs Mushaf (604 pages).
const int totalPagesCount = 604;

/// Total number of Makki (Meccan) Surahs.
const int totalMakkiSurahsCount = 89;

/// Total number of Madani (Medinan) Surahs.
const int totalMadaniSurahsCount = 25;

/// Total Juz count in the Holy Quran.
const int totalJuzCount = 30;

/// Total Hizb count in the Holy Quran.
const int totalHizbCount = 60;

/// Total Rub el-Hizb (quarters) count in the Holy Quran.
const int quartersCount = 240;

/// Total Surah count in the Holy Quran.
const int totalSurahCount = 114;

/// Total verse (Ayah) count in the Holy Quran.
const int totalVerseCount = 6236;

/// The sacred Basmalah formula.
const String basmala = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';

/// The Arabic Sajdah indicator label.
const String sajdah = 'سَجْدَةٌ';

// ---------------------------------------------------------------------------
// 6. Page Data Helpers
// ---------------------------------------------------------------------------

/// Returns the raw page-data list for [pageNumber] (1–604).
///
/// Each entry in the list is a map `{surah, start, end}` describing the
/// Surah ranges that appear on that page.
List<Map<String, dynamic>> getPageData(int pageNumber) {
  _validatePage(pageNumber);
  return List<Map<String, dynamic>>.from(pageData[pageNumber - 1]);
}

/// Returns all Surah numbers appearing on [pageNumber].
List<int> getSurahsInPage(int pageNumber) {
  return getPageData(pageNumber).map<int>((e) => e['surah'] as int).toList();
}

/// Returns the first Surah number appearing on [pageNumber].
int getFirstSurahInPage(int pageNumber) {
  return getPageData(pageNumber).first['surah'] as int;
}

/// Returns the list of [Ayah]s on [pageNumber] (1–604).
List<Ayah> getPageAyahs(int pageNumber) {
  _validatePage(pageNumber);
  return pages[pageNumber - 1].ayahs;
}

// ---------------------------------------------------------------------------
// 7. Surah Metadata Helpers
// ---------------------------------------------------------------------------

/// Returns the transliterated (romanised) Surah name for [surahNumber].
String getSurahName(int surahNumber) {
  _validateSurah(surahNumber);
  return surah[surahNumber - 1]['name'].toString();
}

/// Returns the English meaning/name of [surahNumber].
String getSurahNameEnglish(int surahNumber) {
  _validateSurah(surahNumber);
  return surah[surahNumber - 1]['english'].toString();
}

/// Returns the Arabic name of [surahNumber].
String getSurahNameArabic(int surahNumber, {bool showSurahText = false}) {
  _validateSurah(surahNumber);
  final arabicName = surah[surahNumber - 1]['arabic'].toString();
  return showSurahText ? 'سورة $arabicName' : arabicName;
}

/// Returns the Turkish name of [surahNumber].
String getSurahNameTurkish(int surahNumber) {
  _validateSurah(surahNumber);
  return surah[surahNumber - 1]['turkish']?.toString() ?? '';
}

/// Returns the French name of [surahNumber].
String getSurahNameFrench(int surahNumber) {
  _validateSurah(surahNumber);
  return surah[surahNumber - 1]['french']?.toString() ?? '';
}

/// Returns the Russian name of [surahNumber].
String getSurahNameRussian(int surahNumber) {
  _validateSurah(surahNumber);
  return surah[surahNumber - 1]['russian']?.toString() ?? '';
}

/// Returns the place of revelation ('Makkah' or 'Madinah') for [surahNumber].
String getPlaceOfRevelation(int surahNumber) {
  _validateSurah(surahNumber);
  return surah[surahNumber - 1]['place'].toString();
}

/// Returns 'مكية' for Makkah or 'مدنية' for Madinah for [surahNumber].
String getPlaceOfRevelationArabic(int surahNumber) {
  return getPlaceOfRevelation(surahNumber) == 'Makkah' ? 'مكية' : 'مدنية';
}

/// Returns the total Ayah count in [surahNumber].
int getVerseCount(int surahNumber) {
  _validateSurah(surahNumber);
  return int.parse(surah[surahNumber - 1]['aya'].toString());
}

/// Returns every page number (1–604) on which [surahNumber] appears.
List<int> getSurahPages(int surahNumber) {
  _validateSurah(surahNumber);
  final List<int> surahPages = [];
  for (int page = 1; page <= totalPagesCount; page++) {
    for (final entry in getPageData(page)) {
      if (entry['surah'] == surahNumber) {
        surahPages.add(page);
        break;
      }
    }
  }
  return surahPages;
}

/// Searches Surahs by name in Arabic, English, or translated English name.
List<int> searchSurahNames(String query, {List<Surah>? surahList}) {
  final targetList = surahList ?? surahs;
  final normalizedQuery = normalise(query).toLowerCase().trim();
  return targetList
      .where(
        (s) =>
            normalise(s.arabicName).contains(normalizedQuery) ||
            s.englishName.toLowerCase().contains(normalizedQuery) ||
            s.englishNameTranslation.toLowerCase().contains(normalizedQuery),
      )
      .map((s) => s.surahNumber)
      .toList();
}

// ---------------------------------------------------------------------------
// 8. Page & Verse Lookups
// ---------------------------------------------------------------------------

/// Returns the Mushaf page number (1–604) where [surahNumber]/[ayaNo] is located.
int getPageNumber(int surahNumber, int ayaNo) {
  _validateSurah(surahNumber);
  for (int pageIndex = 0; pageIndex < pageData.length; pageIndex++) {
    for (final e in pageData[pageIndex]) {
      if (e['surah'] == surahNumber &&
          e['start'] <= ayaNo &&
          e['end'] >= ayaNo) {
        return pageIndex + 1;
      }
    }
  }
  throw ArgumentError('Verse $ayaNo not found in Surah $surahNumber.');
}

/// Returns the Arabic verse text for [surahNumber]/[ayaNo].
///
/// Set [verseEndSymbol] to `true` to append the ornate verse-number glyph.
String getVerse(int surahNumber, int ayaNo, {bool verseEndSymbol = false}) {
  for (final i in quran) {
    if (i['sora'] == surahNumber && i['aya_no'] == ayaNo) {
      final verse = i['aya_text'].toString().replaceAll('۩', '').trim();
      final endGlyph = getVerseEndSymbol(ayaNo);
      if (verseEndSymbol && !verse.contains(endGlyph)) {
        return '$verse $endGlyph';
      }
      return verse;
    }
  }
  throw ArgumentError('No verse found for Surah $surahNumber, Ayah $ayaNo.');
}

final Map<String, String> _verseGlyphCache = {};

/// Returns the QCF glyph string for [surahNumber]/[ayaNo] for font rendering.
String getAyaNoQCF(int surahNumber, int ayaNo) {
  final key = '${surahNumber}_$ayaNo';
  final cached = _verseGlyphCache[key];
  if (cached != null) return cached;

  for (final i in quran) {
    if (i['sora'] == surahNumber && i['aya_no'] == ayaNo) {
      final qcfData = i['qcfData'].toString().trim();
      if (qcfData.isNotEmpty) {
        final glyph = qcfData.substring(qcfData.length - 1);
        _verseGlyphCache[key] = glyph;
        return glyph;
      }
    }
  }
  throw ArgumentError('No QCF glyph found for Surah $surahNumber, Ayah $ayaNo.');
}

/// Returns the QCF (Quran Complex Font) text for [surahNumber]/[ayaNo].
String getVerseQCF(int surahNumber, int ayaNo, {bool verseEndSymbol = false}) {
  for (final i in quran) {
    if (i['sora'] == surahNumber && i['aya_no'] == ayaNo) {
      final qcf = i['qcfData']?.toString() ?? '';
      return qcf + (verseEndSymbol ? getVerseEndSymbol(ayaNo) : '');
    }
  }
  throw ArgumentError('No QCF verse found for Surah $surahNumber, Ayah $ayaNo.');
}

// ---------------------------------------------------------------------------
// 9. Juz & Quarter Helpers
// ---------------------------------------------------------------------------

/// Returns the Juz number (1–30) for [surahNumber]/[ayaNo].
///
/// Returns -1 if the combination does not match any known verse range.
int getJuzNumber(int surahNumber, int ayaNo) {
  for (final j in juz) {
    final verses = j['verses'] as Map<int, List<int>>;
    if (verses.containsKey(surahNumber)) {
      final range = verses[surahNumber]!;
      if (ayaNo >= range[0] && ayaNo <= range[1]) {
        return int.parse(j['id'].toString());
      }
    }
  }
  return -1;
}

/// Returns the Juz number for the first verse on [pageNumber].
int getJuzNumberByPage(int pageNumber) {
  final p = getPageData(pageNumber);
  return getJuzNumber(p[0]['surah'] as int, p[0]['start'] as int);
}

/// Returns the first page number for [juzNumber] (1–30).
int getFirstPageNumByJuz(int juzNumber) {
  if (juzNumber < 1 || juzNumber > totalJuzCount) {
    throw RangeError.range(juzNumber, 1, totalJuzCount, 'juzNumber');
  }
  return juzNumber == 1 ? 1 : (20 * (juzNumber - 1)) + 2;
}

/// Returns the two Hizb numbers contained within [juzNumber] (1–30).
List<int> getHizbNumbersByJuz(int juzNumber) {
  if (juzNumber < 1 || juzNumber > totalJuzCount) {
    throw RangeError.range(juzNumber, 1, totalJuzCount, 'juzNumber');
  }
  final first = (juzNumber - 1) * 2 + 1;
  return [first, first + 1];
}

/// Returns the Rub el-Hizb (quarter) number (1–240) for [surahNumber]/[ayaNo].
int getQuarterNumber(int surahNumber, int ayaNo) {
  int current = 1;
  for (int i = 0; i < quarters.length; i++) {
    final qSurah = quarters[i]['surah']!;
    final qAyah = quarters[i]['ayah']!;
    if (surahNumber > qSurah || (surahNumber == qSurah && ayaNo >= qAyah)) {
      current = i + 1;
    } else {
      break;
    }
  }
  return current;
}

/// Returns the currently active Hizb/quarter label for the top of [pageNumber].
String getCurrentHizbTextForPage(int pageNumber, {bool isArabic = true}) {
  _validatePage(pageNumber);
  int current = 0;
  for (int i = 0; i < quarters.length; i++) {
    final qPage = getPageNumber(quarters[i]['surah']!, quarters[i]['ayah']!);
    if (pageNumber >= qPage) {
      current = i;
    } else {
      break;
    }
  }
  return _buildHizbLabel(current + 1, isArabic);
}

/// Constructs the Arabic or English hizb label from a 1-based quarter index.
String _buildHizbLabel(int quarter, bool isArabic) {
  final hizb = ((quarter - 1) ~/ 4) + 1;
  final quarterInHizb = ((quarter - 1) % 4) + 1;
  final hizbStr = isArabic ? _toArabicNumber(hizb) : hizb.toString();

  if (isArabic) {
    return switch (quarterInHizb) {
      1 => 'الحزب $hizbStr',
      2 => 'ربع الحزب $hizbStr',
      3 => 'نصف الحزب $hizbStr',
      _ => 'ثلاثة أرباع الحزب $hizbStr',
    };
  } else {
    return switch (quarterInHizb) {
      1 => 'Hizb $hizbStr',
      2 => '1/4 Hizb $hizbStr',
      3 => '1/2 Hizb $hizbStr',
      _ => '3/4 Hizb $hizbStr',
    };
  }
}

// ---------------------------------------------------------------------------
// 10. Arabic Text Search & Normalization
// ---------------------------------------------------------------------------

/// Normalises Arabic [text] for robust search:
/// removes diacritics, unifies alif/hamza/ya/ta-marbuta variants,
/// and collapses whitespace.
String normalizeArabicText(String text) {
  if (text.isEmpty) return text;
  var result = text.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');
  result = result.replaceAll(RegExp(r'[إأآا]'), 'ا');
  result = result.replaceAll(RegExp(r'[يى]'), 'ي');
  result = result.replaceAll('ة', 'ه');
  return result.replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// Searches the embedded Quran data for the [query] string.
///
/// First searches Emlaey (plain spelling) text; falls back to Uthmanic if no
/// results are found. Returns up to [limit] results (default 50).
Map<String, dynamic> searchWords(String query, {int limit = 50}) {
  if (query.trim().isEmpty) return {'occurences': 0, 'result': <Map<String, dynamic>>[]};

  final normalized = normalizeArabicText(query.toLowerCase());
  if (normalized.isEmpty) return {'occurences': 0, 'result': <Map<String, dynamic>>[]};

  final searchQuery = normalized.replaceAll(RegExp(r'\s+'), '');
  if (searchQuery.isEmpty) return {'occurences': 0, 'result': <Map<String, dynamic>>[]};

  bool contains(String text) {
    final norm = normalizeArabicText(text.toLowerCase()).replaceAll(RegExp(r'\s+'), '');
    return norm.contains(searchQuery);
  }

  final List<Map<String, dynamic>> result = [];

  // Pass 1 — Emlaey
  for (final aya in quran) {
    final emlaey = aya['aya_text_emlaey']?.toString() ?? '';
    if (emlaey.isEmpty || !contains(emlaey)) continue;
    result.add({
      'sora': aya['sora'],
      'aya_no': aya['aya_no'],
      'text': emlaey.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim(),
    });
    if (result.length >= limit) break;
  }

  // Pass 2 — Uthmanic fallback
  if (result.isEmpty) {
    for (final aya in quran) {
      final othmanic = aya['aya_text']?.toString() ?? '';
      if (othmanic.isEmpty || !contains(othmanic)) continue;
      result.add({
        'sora': aya['sora'],
        'aya_no': aya['aya_no'],
        'text': othmanic.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim(),
      });
      if (result.length >= limit) break;
    }
  }

  return {'occurences': result.length, 'result': result};
}

// ---------------------------------------------------------------------------
// 11. Full Dataset Accessors
// ---------------------------------------------------------------------------

GetPage get _getPage {
  final gp = GetPage();
  gp.getQuran(totalPagesCount);
  return gp;
}

/// All 114 Surahs of the Holy Quran with their full Ayahs.
List<Surah> get surahs => _getPage.surahs;

/// All 6,236 Ayahs of the Holy Quran in sequential order.
List<Ayah> get allAyahs => _getPage.ayahs;

/// All 604 Mushaf pages with their visual lines and Ayahs.
List<QuranPage> get pages => _getPage.staticPages;

List<Quarter>? _cachedQuarterList;

/// All 240 Rub el-Hizb (quarters) of the Holy Quran.
List<Quarter> get quartersList =>
    _cachedQuarterList ??=
        quarters
            .map((q) => Quarter(surah: q['surah']!, ayah: q['ayah']!))
            .toList();

/// Fetches a specific [Ayah] by [surahNumber] and [ayahNumber].
Ayah getAyah(int surahNumber, int ayahNumber) => allAyahs.firstWhere(
  (a) => a.surahNumber == surahNumber && a.ayahNumber == ayahNumber,
);

/// Returns all 15 Sajdah (prostration of recitation) verses of the Holy Quran.
List<Ayah> getSajdahVerses() {
  final List<Ayah> sajdahAyahs = [];
  for (final entry in sajdahVerses.entries) {
    final surah = surahs.firstWhere((s) => s.surahNumber == entry.key);
    for (final verseNumber in entry.value) {
      final ayah = surah.ayahs.firstWhere((a) => a.ayahNumber == verseNumber);
      sajdahAyahs.add(ayah);
    }
  }
  return sajdahAyahs;
}

// ---------------------------------------------------------------------------
// 12. Private Validation & Formatting Helpers
// ---------------------------------------------------------------------------

void _validateSurah(int surahNumber) {
  if (surahNumber < 1 || surahNumber > totalSurahCount) {
    throw RangeError.range(surahNumber, 1, totalSurahCount, 'surahNumber');
  }
}

void _validatePage(int pageNumber) {
  if (pageNumber < 1 || pageNumber > totalPagesCount) {
    throw RangeError.range(pageNumber, 1, totalPagesCount, 'pageNumber');
  }
}

String _toArabicNumber(int n) {
  const map = {
    '0': '٠',
    '1': '١',
    '2': '٢',
    '3': '٣',
    '4': '٤',
    '5': '٥',
    '6': '٦',
    '7': '٧',
    '8': '٨',
    '9': '٩',
  };
  return n.toString().split('').map((c) => map[c] ?? c).join();
}
