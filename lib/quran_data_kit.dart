library;

// ---------------------------------------------------------------------------
// Internal data imports (used by helper functions below)
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
export 'src/widgets/surah_text_widget.dart';

// ---------------------------------------------------------------------------
// 2. Models
// ---------------------------------------------------------------------------
export 'src/models/highlight_verse.dart';
export 'src/models/ayah.dart';
export 'src/models/quran_page.dart';
export 'src/models/quarter.dart';
export 'src/models/surah.dart';
export 'src/models/highlight_word.dart';
export 'src/models/quran_constants.dart';
export 'src/models/random_verse.dart';

// ---------------------------------------------------------------------------
// 3. Data
// ---------------------------------------------------------------------------
export 'src/data/quarters.dart';
export 'src/data/juzs.dart';
export 'src/data/page_data.dart';
export 'src/data/suwar.dart';
export 'src/data/sajdah_verses.dart';

// ---------------------------------------------------------------------------
// 4. Services & Utilities
// ---------------------------------------------------------------------------
export 'src/services/get_page.dart';
export 'src/utils/quran_text_styles.dart';
export 'src/utils/font_loader_service.dart';
export 'src/utils/quran_helpers.dart';
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

/// Total quarters count in the Holy Quran.
const int quartersCount = totalHizbCount * 2;

/// Total Surah count in the Holy Quran.
const int totalSurahCount = 114;

/// Total verse (Ayah) count in the Holy Quran.
const int totalVerseCount = 6236;

/// The sacred Basmalah formula.
const String basmala = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';

/// The Arabic Sajdah indicator label.
const String sajdah = 'سَجْدَةٌ';

// ---------------------------------------------------------------------------
// 6. Page-level Data Helpers
// ---------------------------------------------------------------------------

/// Returns the raw page-data list for [pageNumber] (1–604).
///
/// Each entry in the list is a map `{surah, start, end}` describing the
/// Surah ranges that appear on that page.
///
/// Throws if [pageNumber] is outside the valid range.
List getPageData(int pageNumber) {
  if (pageNumber < 1 || pageNumber > 604) {
    throw 'Invalid page number. Page number must be between 1 and 604.';
  }
  return pageData[pageNumber - 1];
}

/// Returns the number of distinct Surahs that appear on [pageNumber].
int getSurahCountByPage(int pageNumber) {
  if (pageNumber < 1 || pageNumber > 604) {
    throw 'Invalid page number. Page number must be between 1 and 604.';
  }
  return pageData[pageNumber - 1].length;
}

/// Returns the total verse count on [pageNumber].
int getVerseCountByPage(int pageNumber) {
  if (pageNumber < 1 || pageNumber > 604) {
    throw 'Invalid page number. Page number must be between 1 and 604.';
  }
  int total = 0;
  for (final e in pageData[pageNumber - 1]) {
    total += int.parse(e!['end'].toString());
  }
  return total;
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
String getSurahNameArabic(int surahNumber) {
  _validateSurah(surahNumber);
  return surah[surahNumber - 1]['arabic'].toString();
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

/// Returns the total Ayah count in [surahNumber].
int getVerseCount(int surahNumber) {
  _validateSurah(surahNumber);
  return int.parse(surah[surahNumber - 1]['aya'].toString());
}

/// Returns every page number (1–604) on which [surahNumber] appears.
List<int> getSurahPages(int surahNumber) {
  _validateSurah(surahNumber);
  final List<int> pages = [];
  for (int page = 1; page <= totalPagesCount; page++) {
    for (final entry in getPageData(page)) {
      if (entry['surah'] == surahNumber) {
        pages.add(page);
        break;
      }
    }
  }
  return pages;
}

// ---------------------------------------------------------------------------
// 8. Page / Verse Lookup
// ---------------------------------------------------------------------------

/// Returns the Mushaf page number (1–604) where [surahNumber]/[ayaNo] is located.
///
/// Throws if the verse is not found.
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
  throw 'Invalid verse number.';
}

/// Returns the Arabic verse text for [surahNumber]/[ayaNo].
///
/// Set [verseEndSymbol] to `true` to append the ornate verse-number glyph.
String getVerse(int surahNumber, int ayaNo, {bool verseEndSymbol = false}) {
  for (final i in quran) {
    if (i['sora'] == surahNumber && i['aya_no'] == ayaNo) {
      final verse = i['aya_text'].toString().replaceAll('۩', '');
      return verse;
    }
  }
  throw 'No verse found with given surahNumber and aya_no.';
}

/// Returns the QCF glyph string for [surahNumber]/[ayaNo] for font rendering.
///
/// Uses a persistent cache to avoid redundant list scans after the first call
/// for any given verse.
String getAyaNoQCF(int surahNumber, int ayaNo) {
  final key = '${surahNumber}_$ayaNo';
  if (_verseGlyphCache.containsKey(key)) return _verseGlyphCache[key]!;

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
  throw 'No verse found with given surahNumber and aya_no.';
}

/// Returns the QCF (Quran Complex Font) text for [surahNumber]/[ayaNo].
String getVerseQCF(int surahNumber, int ayaNo, {bool verseEndSymbol = false}) {
  for (final i in quran) {
    if (i['sora'] == surahNumber && i['aya_no'] == ayaNo) {
      final qcf = i['qcfData']?.toString() ?? '';
      return qcf + (verseEndSymbol ? getVerseEndSymbol(ayaNo) : '');
    }
  }
  throw 'No verse found with given surahNumber and aya_no.';
}

/// Returns the Quran.com web URL for [juzNumber].
String getJuzURL(int juzNumber) => 'https://quran.com/juz/$juzNumber';

/// Returns the Quran.com web URL for [surahNumber].
String getSurahURL(int surahNumber) => 'https://quran.com/$surahNumber';

/// Returns the Quran.com web URL for [surahNumber] and [verseNumber].
String getVerseURL(int surahNumber, int verseNumber) =>
    'https://quran.com/$surahNumber/$verseNumber';

/// Controls how Surah headers are separated when fetching page text.
enum SurahSeperator {
  none,
  surahName,
  surahNameArabic,
  surahNameEnglish,
  surahNameTurkish,
  surahNameFrench,
  surahNameRussian,
}

/// Returns the formatted verse strings for [pageNumber].
List<String> getVersesTextByPage(
  int pageNumber, {
  bool verseEndSymbol = false,
  SurahSeperator surahSeperator = SurahSeperator.none,
  String customSurahSeperator = '',
}) {
  if (pageNumber > totalPagesCount || pageNumber <= 0) {
    throw 'Invalid pageNumber';
  }

  final List<String> verses = [];
  final pData = getPageData(pageNumber);
  for (final data in pData) {
    final sNumber = int.parse(data['surah'].toString());
    if (customSurahSeperator.isNotEmpty) {
      verses.add(customSurahSeperator);
    } else if (surahSeperator == SurahSeperator.surahName) {
      verses.add(getSurahName(sNumber));
    } else if (surahSeperator == SurahSeperator.surahNameArabic) {
      verses.add(getSurahNameArabic(sNumber));
    } else if (surahSeperator == SurahSeperator.surahNameEnglish) {
      verses.add(getSurahNameEnglish(sNumber));
    } else if (surahSeperator == SurahSeperator.surahNameTurkish) {
      verses.add(getSurahNameTurkish(sNumber));
    } else if (surahSeperator == SurahSeperator.surahNameFrench) {
      verses.add(getSurahNameFrench(sNumber));
    } else if (surahSeperator == SurahSeperator.surahNameRussian) {
      verses.add(getSurahNameRussian(sNumber));
    }
    final int start = int.parse(data['start'].toString());
    final int end = int.parse(data['end'].toString());
    for (int j = start; j <= end; j++) {
      verses.add(getVerse(sNumber, j, verseEndSymbol: verseEndSymbol));
    }
  }
  return verses;
}

// ignore: prefer_final_fields
Map<String, String> _verseGlyphCache = {};

// ---------------------------------------------------------------------------
// 9. Juz Helpers
// ---------------------------------------------------------------------------

/// Returns the Juz number (1–30) for [surahNumber]/[ayaNo].
///
/// Returns -1 if the combination does not match any known verse range.
int getJuzNumber(int surahNumber, int ayaNo) {
  for (final j in juz) {
    if (j['verses'].keys.contains(surahNumber)) {
      if (ayaNo >= j['verses'][surahNumber][0] &&
          ayaNo <= j['verses'][surahNumber][1]) {
        return int.parse(j['id'].toString());
      }
    }
  }
  return -1;
}

/// Returns the map of Surah number → [startVerse, endVerse] for [juzNumber].
Map<int, List<int>> getSurahAndVersesFromJuz(int juzNumber) =>
    juz[juzNumber - 1]['verses'];

// ---------------------------------------------------------------------------
// 10. Quarter / Hizb Helpers
// ---------------------------------------------------------------------------

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

/// Returns the Arabic hizb/quarter label **only** if a new quarter starts
/// exactly on [pageNumber].
///
/// Returns an empty string if no quarter starts on that page.
/// Pass [isArabic] as `false` for English output.
String getHizbTextByPage(int pageNumber, {bool isArabic = true}) {
  final idx = quarters.indexWhere(
    (q) => getPageNumber(q['surah']!, q['ayah']!) == pageNumber,
  );
  if (idx == -1) return '';
  return _buildHizbLabel(idx + 1, isArabic);
}

/// Returns the currently active Hizb/quarter label for the top of [pageNumber].
///
/// Unlike [getHizbTextByPage], this returns the label even when the quarter
/// started on a previous page.
String getCurrentHizbTextForPage(int pageNumber, {bool isArabic = true}) {
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
// 11. Arabic Text Search
// ---------------------------------------------------------------------------

/// Normalises Arabic [text] for robust search:
/// removes diacritics, unifies alif/hamza/ya/ta-marbuta variants,
/// and collapses whitespace.
String normalizeArabicText(String text) {
  if (text.isEmpty) return text;
  text = text.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');
  text = text.replaceAll(RegExp(r'[إأآا]'), 'ا');
  text = text.replaceAll(RegExp(r'[يى]'), 'ي');
  text = text.replaceAll('ة', 'ه');
  return text.replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// Searches the embedded Quran data for the [query] string.
///
/// First searches Emlaey (plain spelling) text; falls back to Uthmanic if no
/// results are found. Returns up to [limit] results (default 50).
///
/// The returned map has:
/// - `occurences`: number of matches.
/// - `result`: list of `{sora, aya_no, text}` maps.
Map<String, dynamic> searchWords(String query, {int limit = 50}) {
  if (query.trim().isEmpty) return {'occurences': 0, 'result': []};

  final normalized = normalizeArabicText(query.toLowerCase());
  if (normalized.isEmpty) return {'occurences': 0, 'result': []};

  final searchQuery = normalized.replaceAll(RegExp(r'\s+'), '');
  if (searchQuery.isEmpty) return {'occurences': 0, 'result': []};

  bool contains(String text) {
    final norm = normalizeArabicText(
      text.toLowerCase(),
    ).replaceAll(RegExp(r'\s+'), '');
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
      'text':
          emlaey.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim(),
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
        'text':
            othmanic
                .replaceAll('\n', ' ')
                .replaceAll(RegExp(r'\s+'), ' ')
                .trim(),
      });
      if (result.length >= limit) break;
    }
  }

  return {'occurences': result.length, 'result': result};
}

// ---------------------------------------------------------------------------
// 12. Full Quran Data & Lookups
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

/// Returns all 240 Rub el-Hizb (quarters) of the Holy Quran.
List<Quarter> getQuarters() => quartersList;

/// Fetches a specific [Ayah] by [surahNumber] and [ayahNumber].
Ayah getAyah(int surahNumber, int ayahNumber) => allAyahs.firstWhere(
  (a) => a.surahNumber == surahNumber && a.ayahNumber == ayahNumber,
);

/// Returns the text of a specific verse.
String getVerseText(int surahNumber, int ayahNumber) =>
    getAyah(surahNumber, ayahNumber).text;

/// Returns the list of [Ayah]s for [pageNumber] (1–604).
List<Ayah> getPageAyahs(int pageNumber) {
  if (pageNumber < 1 || pageNumber > totalPagesCount) {
    throw 'Invalid page number ($pageNumber)';
  }
  return pages[pageNumber - 1].ayahs;
}

/// Returns all Surah numbers appearing on [pageNumber].
List<int> getSurahsInPage(int pageNumber) {
  final p = getPageData(pageNumber);
  return p.map<int>((e) => e['surah'] as int).toList();
}

/// Returns the first Surah number appearing on [pageNumber].
int getFirstSurahInPage(int pageNumber) {
  return getPageData(pageNumber)[0]['surah'] as int;
}

/// Returns the last Surah number appearing on [pageNumber], or null if only one Surah is present.
int? getLastSurahInPage(int pageNumber) {
  final p = getPageData(pageNumber);
  return p.length > 1 ? p.last['surah'] as int : null;
}

/// Returns the Juz number for the first verse on [pageNumber].
int getJuzNumberByPage(int pageNumber) {
  final p = getPageData(pageNumber);
  return getJuzNumber(p[0]['surah'] as int, p[0]['start'] as int);
}

/// Returns the first page number for [juzNumber] (1–30).
int getFirstPageNumByJuz(int juzNumber) =>
    juzNumber == 1 ? 1 : (20 * (juzNumber - 1)) + 2;

/// Returns the two Hizb numbers contained within [juzNumber] (1–30).
List<int> getHizbNumbersByJuz(int juzNumber) {
  final first = (juzNumber - 1) * 2 + 1;
  return [first, first + 1];
}

/// Returns the 1-based Hizb number if [pageNumber] is the start of that Hizb, or null otherwise.
int? calculateHizbNumber(int pageNumber) {
  final hizbNumber = ((pageNumber - 1) ~/ 10) + 1;
  final firstPageOfHizb = (hizbNumber - 1) * 10 + 1;
  return pageNumber == firstPageOfHizb ? hizbNumber : null;
}

/// Returns 'مكية' for Makkah or 'مدنية' for Madinah for [surahNumber].
String getPlaceOfRevelationArabic(int surahNumber) {
  return getPlaceOfRevelation(surahNumber) == 'Makkah' ? 'مكية' : 'مدنية';
}

/// Splits page ayahs for Basmalah display between surahs on page.
List<List<Ayah>> getPageAyahsSeparatedForBasmalah(int pageNumber) {
  final pageAyahs = getPageAyahs(pageNumber);
  final List<List<Ayah>> result = [];
  List<Ayah> currentGroup = [];
  for (int i = 0; i < pageAyahs.length; i++) {
    if (i > 0 && pageAyahs[i].ayahNumber < pageAyahs[i - 1].ayahNumber) {
      result.add(currentGroup);
      currentGroup = [];
    }
    currentGroup.add(pageAyahs[i]);
  }
  if (currentGroup.isNotEmpty) result.add(currentGroup);
  return result;
}

/// Finds the Surah containing the Ayah with global unique index [ayahUQNumber].
Surah getSurahByAyahUQ(int ayahUQNumber) => surahs.firstWhere(
  (s) => s.ayahs.any((a) => a.ayahUQNumber == ayahUQNumber),
);

/// Returns the Surah Arabic name for the Ayah with global unique index [ayahUQNumber].
String getSurahNameByAyahUQ(int ayahUQNumber) =>
    getSurahByAyahUQ(ayahUQNumber).arabicName;

/// Finds the first Ayah on Mushaf [pageNumber] (1-based).
Ayah getFirstAyahOnPage(int pageNumber) =>
    allAyahs.firstWhere((a) => a.page == pageNumber);

/// Searches Surahs by name in Arabic, English, or translated English name.
List<int> searchSurahNames(String query, {List<Surah>? surahList}) {
  final targetList = surahList ?? surahs;
  final normalized = query.toLowerCase().trim();
  return targetList
      .where(
        (s) =>
            normalise(s.arabicName).contains(normalized) ||
            s.englishName.toLowerCase().contains(normalized) ||
            s.englishNameTranslation.toLowerCase().contains(normalized),
      )
      .map((s) => s.surahNumber)
      .toList();
}

/// Predefined page indexes where bookmark flags appear at the bottom.
const List<int> downThePageIndex = [
  75,
  206,
  330,
  340,
  348,
  365,
  375,
  413,
  416,
  444,
  451,
  497,
  505,
  524,
  547,
  554,
  556,
  583,
];

/// Predefined page indexes where bookmark flags appear at the top.
const List<int> topOfThePageIndex = [
  76,
  207,
  331,
  341,
  349,
  366,
  376,
  414,
  417,
  435,
  445,
  452,
  498,
  506,
  525,
  548,
  554,
  555,
  557,
  583,
  584,
];

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

/// Converts an integer to an Eastern Arabic numeral string.
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

/// Validates that [surahNumber] is within the 1–114 range.
void _validateSurah(int surahNumber) {
  if (surahNumber < 1 || surahNumber > 114) {
    throw 'No Surah found with given surahNumber ($surahNumber).';
  }
}

/// Returns all 15 Sajdah (prostration of recitation) verses of the Holy Quran
/// in sequential Mushaf order.
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
