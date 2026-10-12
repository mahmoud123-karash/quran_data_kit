import 'package:quran_data_kit/src/data/reciters.dart';
import 'package:quran_data_kit/src/data/sajdah_verses.dart';

// ---------------------------------------------------------------------------
// Audio URL Helpers
// ---------------------------------------------------------------------------

/// Returns the CDN audio URL for a full Surah recitation by [surahNumber],
/// using Mishary Alafasy as the default reciter.
///
/// Example: `getAudioURLBySurah(1)` → `"https://cdn.islamic.network/..."`
String getAudioURLBySurah(int surahNumber) =>
    'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/$surahNumber.mp3';

/// Returns the CDN audio URL for a specific verse identified by its
/// unique [verseNumber] (1-based sequential number across the whole Quran)
/// and [reciterIdentifier] (e.g. `"ar.alafasy"`).
///
/// Some reciters use 128kbps while others are served at 64kbps.
String getAudioURLByVerse(int verseNumber, String reciterIdentifier) {
  const highBitrateReciters = {
    'ar.parhizgar',
    'ar.muhammadjibreel',
    'ar.muhammadayyoub',
    'ar.ibrahimakhbar',
    'ar.minshawi',
  };
  final bitrate = highBitrateReciters.contains(reciterIdentifier) ? 128 : 64;
  return 'https://cdn.islamic.network/quran/audio/$bitrate/$reciterIdentifier/$verseNumber.mp3';
}

/// Returns the CDN audio URL for a verse by its [verseNumber] using
/// Mishary Alafasy as the default reciter at 128kbps.
String getAudioURLByVerseNumber(int verseNumber) =>
    'https://cdn.islamic.network/quran/audio/128/ar.alafasy/$verseNumber.mp3';

// ---------------------------------------------------------------------------
// Verse End Symbol
// ---------------------------------------------------------------------------

/// Returns the ornate Arabic end-of-verse sign ('۝') with the [verseNumber]
/// rendered inside it.
///
/// Set [arabicNumeral] to `false` to use Western digits instead of
/// Eastern Arabic numerals. Defaults to `true`.
String getVerseEndSymbol(int verseNumber, {bool arabicNumeral = true}) {
  if (!arabicNumeral) return '\u06dd${verseNumber.toString()}';

  const Map<String, String> arabicNumbers = {
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

  final arabicNumeric = verseNumber
      .toString()
      .split('')
      .map((d) => arabicNumbers[d] ?? d)
      .join();

  return '\u06dd$arabicNumeric';
}

// ---------------------------------------------------------------------------
// Sajdah Tilawah
// ---------------------------------------------------------------------------

/// Returns `true` if the Ayah at [surahNumber]/[verseNumber] requires a
/// prostration of recitation (Sajdah Tilawah).
bool isSajdahVerse(int surahNumber, int verseNumber) =>
    sajdahVerses[surahNumber] == verseNumber;

// ---------------------------------------------------------------------------
// Reciters
// ---------------------------------------------------------------------------

/// Returns the full list of supported Quran reciters.
///
/// Each entry is a map with keys `identifier`, `name`, `englishName`,
/// `language`, `format`, `type`, and `direction`.
List<Map<String, dynamic>> getReciters() => List.unmodifiable(reciters);

// ---------------------------------------------------------------------------
// Arabic Text Normalization
// ---------------------------------------------------------------------------

/// Normalises [input] Arabic text by stripping Koranic annotations,
/// tatweel, tashkeel (diacritics), and unifying common letter variants
/// (alif forms, ya/hamza, ta-marbuta, waw-hamza).
///
/// Useful before comparing or searching Quran text programmatically.
String normalise(String input) => input
    .replaceAll('\u0610', '')
    .replaceAll('\u0611', '')
    .replaceAll('\u0612', '')
    .replaceAll('\u0613', '')
    .replaceAll('\u0614', '')
    .replaceAll('\u0615', '')
    .replaceAll('\u0616', '')
    .replaceAll('\u0617', '')
    .replaceAll('\u0618', '')
    .replaceAll('\u0619', '')
    .replaceAll('\u061A', '')
    .replaceAll('\u06D6', '')
    .replaceAll('\u06D7', '')
    .replaceAll('\u06D8', '')
    .replaceAll('\u06D9', '')
    .replaceAll('\u06DA', '')
    .replaceAll('\u06DB', '')
    .replaceAll('\u06DC', '')
    .replaceAll('\u06DD', '')
    .replaceAll('\u06DE', '')
    .replaceAll('\u06DF', '')
    .replaceAll('\u06E0', '')
    .replaceAll('\u06E1', '')
    .replaceAll('\u06E2', '')
    .replaceAll('\u06E3', '')
    .replaceAll('\u06E4', '')
    .replaceAll('\u06E5', '')
    .replaceAll('\u06E6', '')
    .replaceAll('\u06E7', '')
    .replaceAll('\u06E8', '')
    .replaceAll('\u06E9', '')
    .replaceAll('\u06EA', '')
    .replaceAll('\u06EB', '')
    .replaceAll('\u06EC', '')
    .replaceAll('\u06ED', '')
    .replaceAll('\u0640', '')
    .replaceAll('\u064B', '')
    .replaceAll('\u064C', '')
    .replaceAll('\u064D', '')
    .replaceAll('\u064E', '')
    .replaceAll('\u064F', '')
    .replaceAll('\u0650', '')
    .replaceAll('\u0651', '')
    .replaceAll('\u0652', '')
    .replaceAll('\u0653', '')
    .replaceAll('\u0654', '')
    .replaceAll('\u0655', '')
    .replaceAll('\u0656', '')
    .replaceAll('\u0657', '')
    .replaceAll('\u0658', '')
    .replaceAll('\u0659', '')
    .replaceAll('\u065A', '')
    .replaceAll('\u065B', '')
    .replaceAll('\u065C', '')
    .replaceAll('\u065D', '')
    .replaceAll('\u065E', '')
    .replaceAll('\u065F', '')
    .replaceAll('\u0670', '')
    .replaceAll('\u0624', '\u0648') // و hamza → و
    .replaceAll('\u0629', '\u0647') // ة → ه
    .replaceAll('\u064A', '\u0649') // ي → ى
    .replaceAll('\u0626', '\u0649') // ئ → ى
    .replaceAll('\u0622', '\u0627') // آ → ا
    .replaceAll('\u0623', '\u0627') // أ → ا
    .replaceAll('\u0625', '\u0627'); // إ → ا

/// Removes Arabic diacritics (tashkeel & sukun) from [input] while
/// preserving all base letters.
String removeDiacritics(String input) {
  final pattern = RegExp(r'[\u064B-\u065F\u0670]');
  return input.replaceAll(pattern, '');
}
