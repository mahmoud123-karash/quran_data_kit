import 'dart:math';

import 'package:quran_data_kit/quran_data_kit.dart';

/// Represents a randomly selected Ayah (verse) from the Holy Quran,
/// complete with its Surah index, Ayah index, Arabic text, and translation.
class RandomVerse {
  /// The Surah number (1-114).
  late final int surahNumber;

  /// The verse number within the Surah (1-based).
  late final int verseNumber;

  /// The Arabic text of the verse.
  late final String verse;

  /// The translation of the verse (defaults to Saheeh International).
  late final String translation;

  /// Creates a new [RandomVerse] instance by selecting a random verse
  /// across all 114 Surahs.
  RandomVerse({Translation translationType = Translation.enSaheeh}) {
    final random = Random();
    surahNumber = random.nextInt(totalSurahCount) + 1;
    verseNumber = random.nextInt(getVerseCount(surahNumber)) + 1;
    verse = getVerse(surahNumber, verseNumber);
    translation = getVerseTranslation(
      surahNumber,
      verseNumber,
      translation: translationType,
    );
  }
}
