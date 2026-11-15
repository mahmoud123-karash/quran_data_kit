import '../data/quran_data.dart';
import '../models/ayah.dart';
import '../models/quran_page.dart';
import '../models/surah.dart';

/// A service class responsible for processing raw Quranic data into
/// structured [QuranPage] and [Surah] objects.
///
/// Uses static memory caching so parsing runs exactly once per app lifecycle.
class GetPage {
  static List<QuranPage> _cachedStaticPages = [];
  static final List<Surah> _cachedSurahs = [];
  static final List<Ayah> _cachedAyahs = [];
  static bool _isParsed = false;

  /// Cached Mushaf pages.
  List<QuranPage> get staticPages => _cachedStaticPages;

  /// Cached Surahs with their verses.
  List<Surah> get surahs => _cachedSurahs;

  /// Cached sequential list of all 6,236 Ayahs.
  List<Ayah> get ayahs => _cachedAyahs;

  /// Entry point to initialize the Quranic data structure.
  /// Fully synchronous and cached after the first run.
  void getQuran(int quranPagesCount) {
    if (_isParsed && _cachedStaticPages.length == quranPagesCount) {
      return;
    }

    final List<Ayah> result = getQuranData();
    _processQuranData(result, quranPagesCount);

    _isParsed = true;
  }

  /// Fetches raw data and maps it into a list of [Ayah] objects.
  List<Ayah> getQuranData() {
    return quran.map((e) => Ayah.fromJson(e)).toList();
  }

  /// Orchestrates data processing into pages and surahs.
  void _processQuranData(List<Ayah> quranAyahsList, int quranPagesCount) {
    _cachedStaticPages = List.generate(
      quranPagesCount,
      (index) => QuranPage(pageNumber: index + 1, ayahs: [], lines: []),
    );

    _cachedSurahs.clear();
    _cachedAyahs.clear();

    int hizb = 1;
    int surahsIndex = 1;
    List<Ayah> thisSurahAyahs = [];

    for (final ayah in quranAyahsList) {
      // Logic for Surah transition and tracking
      if (ayah.surahNumber != surahsIndex) {
        if (_cachedSurahs.isNotEmpty) {
          _cachedSurahs.last.endPage = _cachedAyahs.last.page;
          _cachedSurahs.last.ayahs = List.from(thisSurahAyahs);
        }
        surahsIndex = ayah.surahNumber;
        thisSurahAyahs = [];
      }

      _cachedAyahs.add(ayah);
      thisSurahAyahs.add(ayah);
      _cachedStaticPages[ayah.page - 1].ayahs.add(ayah);

      // Detect Hizb (۞) marks and Sajda (۩)
      if (ayah.ayah.contains('۞')) {
        _cachedStaticPages[ayah.page - 1].hizb = hizb++;
      }
      if (ayah.ayah.contains('۩')) {
        _cachedStaticPages[ayah.page - 1].hasSajda = true;
      }

      // Handle the start of a new Surah (Ayah 1)
      if (ayah.ayahNumber == 1) {
        _cachedStaticPages[ayah.page - 1].numberOfNewSurahs++;
        _cachedSurahs.add(
          Surah(
            index: ayah.surahNumber,
            startPage: ayah.page,
            endPage: 0,
            nameEn: ayah.surahNameEn,
            nameAr: ayah.surahNameAr,
            ayahs: [],
          ),
        );
      }
    }

    // Close out the final Surah
    if (_cachedSurahs.isNotEmpty) {
      _cachedSurahs.last.endPage = _cachedAyahs.last.page;
      _cachedSurahs.last.ayahs = thisSurahAyahs;
    }

    // Proceed to slice Ayahs into visual lines
    _generateLines();
  }

  /// Splits Ayahs into [Line] objects based on newline characters (\n).
  void _generateLines() {
    for (final staticPage in _cachedStaticPages) {
      staticPage.lines.clear();
      List<Ayah> currentLineAyahs = [];

      for (final aya in staticPage.ayahs) {
        // If it's a new Surah start, force a line break for the header
        if (aya.ayahNumber == 1) {
          if (currentLineAyahs.isNotEmpty &&
              currentLineAyahs.any((a) => a.ayah.trim().isNotEmpty)) {
            staticPage.lines.add(Line(List.from(currentLineAyahs)));
            currentLineAyahs.clear();
          }
        }

        // Handle Ayahs that are split across multiple lines
        if (aya.ayah.contains('\n')) {
          final parts = aya.ayah.split('\n');
          final othmanicParts = aya.othmanicAyah.split('\n');
          final qcfParts = aya.qcfData.split('\n');

          for (int i = 0; i < parts.length; i++) {
            final textPart = parts[i].trim();
            if (textPart.isEmpty) continue;

            String othmanicPart = textPart;
            if (i < othmanicParts.length) {
              othmanicPart = othmanicParts[i].trim();
            }

            String qcfPart = textPart;
            if (i < qcfParts.length) {
              qcfPart = qcfParts[i].trim();
            }

            // Create a sub-Ayah for the specific line segment
            final subAyah = Ayah.fromAya(
              ayah: aya,
              aya: textPart,
              othmanicAyah: othmanicPart,
              qcfData: qcfPart,
              ayaText: textPart,
              centered: aya.centered && i == parts.length - 2,
            );

            currentLineAyahs.add(subAyah);

            // If there's more text after this part, it's a line break
            if (i < parts.length - 1) {
              staticPage.lines.add(Line(List.from(currentLineAyahs)));
              currentLineAyahs.clear();
            }
          }
        } else {
          // Ayah fits on a single line (or is part of a multi-Ayah line)
          currentLineAyahs.add(aya);
        }
      }

      // Add the remaining Ayahs to the final line of the page
      if (currentLineAyahs.isNotEmpty &&
          currentLineAyahs.any((a) => a.ayah.trim().isNotEmpty)) {
        staticPage.lines.add(Line(List.from(currentLineAyahs)));
      }
    }
  }
}
