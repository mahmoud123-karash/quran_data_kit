import 'package:quran_data_kit/src/data/translations/bengali.dart';
import 'package:quran_data_kit/src/data/translations/chinese.dart';
import 'package:quran_data_kit/src/data/translations/en_clear_quran.dart';
import 'package:quran_data_kit/src/data/translations/en_saheeh.dart';
import 'package:quran_data_kit/src/data/translations/fa_hussein_dari.dart';
import 'package:quran_data_kit/src/data/translations/fr_hamidullah.dart';
import 'package:quran_data_kit/src/data/translations/indonesian.dart';
import 'package:quran_data_kit/src/data/translations/it_piccardo.dart';
import 'package:quran_data_kit/src/data/translations/ml_abdulhameed.dart';
import 'package:quran_data_kit/src/data/translations/nl_siregar.dart';
import 'package:quran_data_kit/src/data/translations/portuguese.dart';
import 'package:quran_data_kit/src/data/translations/ru_kuliev.dart';
import 'package:quran_data_kit/src/data/translations/spanish.dart';
import 'package:quran_data_kit/src/data/translations/swedish.dart';
import 'package:quran_data_kit/src/data/translations/tr_saheeh.dart';
import 'package:quran_data_kit/src/data/translations/urdu.dart';

/// Enum representing all bundled Quran translations.
///
/// Each value corresponds to a complete in-memory translation dataset.
/// Use [getVerseTranslation] to retrieve translated verse text.
enum Translation {
  /// English translation by Saheeh International.
  enSaheeh,

  /// English translation by the Clear Quran (Dr. Mustafa Khattab).
  enClearQuran,

  /// Turkish translation by Saheeh International.
  trSaheeh,

  /// Malayalam translation by Abdulhameed.
  mlAbdulHameed,

  /// Persian (Dari) translation by Hussein.
  faHusseinDari,

  /// French translation by Hamidullah.
  frHamidullah,

  /// Italian translation by Piccardo.
  itPiccardo,

  /// Dutch translation by Siregar.
  nlSiregar,

  /// Portuguese translation.
  portuguese,

  /// Russian translation by Kuliev.
  ruKuliev,

  /// Urdu translation.
  urdu,

  /// Bengali translation.
  bengali,

  /// Chinese translation.
  chinese,

  /// Indonesian translation.
  indonesian,

  /// Spanish translation.
  spanish,

  /// Swedish translation.
  swedish,
}

/// Returns the translation text for a specific [surahNumber] and [verseNumber].
///
/// Optionally append a verse-end symbol by setting [verseEndSymbol] to `true`.
/// The [translation] parameter selects which of the bundled translations to use.
/// Defaults to [Translation.enSaheeh].
///
/// Throws a [String] error message if no matching verse is found.
String getVerseTranslation(
  int surahNumber,
  int verseNumber, {
  bool verseEndSymbol = false,
  Translation translation = Translation.enSaheeh,
}) {
  final translationData = _getTranslationData(translation);
  String verse = '';

  for (final i in translationData) {
    if (i['surah_number'] == surahNumber && i['verse_number'] == verseNumber) {
      verse = i['content'].toString();
      break;
    }
  }

  if (verse.isEmpty) {
    throw 'No verse found with given surahNumber and verseNumber.';
  }

  return verse + (verseEndSymbol ? _getVerseEndSymbolLatin(verseNumber) : '');
}

/// Returns the verse end symbol using Western (Latin) digits.
String _getVerseEndSymbolLatin(int verseNumber) =>
    '\u06dd${verseNumber.toString()}';

/// Resolves the list of translation entries for the given [translation].
List<dynamic> _getTranslationData(Translation translation) {
  switch (translation) {
    case Translation.enSaheeh:
      return enSaheeh;
    case Translation.enClearQuran:
      return enClearQuran;
    case Translation.faHusseinDari:
      return faHusseinDari;
    case Translation.itPiccardo:
      return itPiccardo;
    case Translation.nlSiregar:
      return nlSiregar;
    case Translation.portuguese:
      return portuguese;
    case Translation.trSaheeh:
      return trSaheeh;
    case Translation.mlAbdulHameed:
      return mlAbdulHameed;
    case Translation.frHamidullah:
      return frHamidullah;
    case Translation.ruKuliev:
      return ruKuliev;
    case Translation.urdu:
      return urdu;
    case Translation.bengali:
      return bengali;
    case Translation.chinese:
      return chinese;
    case Translation.indonesian:
      return indonesian;
    case Translation.spanish:
      return spanish;
    case Translation.swedish:
      return swedish;
  }
}

/// Searches all verses in a given [translation] for occurrences of any of
/// the provided [words] (case-insensitive).
///
/// Returns a map with:
/// - `occurences`: total number of matching verses.
/// - `result`: a list of `{surah: int, verse: int}` maps.
Map<String, dynamic> searchWordsInTranslation(
  List<String> words, {
  Translation translation = Translation.enSaheeh,
}) {
  final translationData = _getTranslationData(translation);
  final List<Map<String, dynamic>> result = [];

  for (final i in translationData) {
    final content = i['content'].toString().toLowerCase();
    final matches = words.any((w) => content.contains(w.toLowerCase()));
    if (matches) {
      result.add({'surah': i['surah_number'], 'verse': i['verse_number']});
    }
  }

  return {'occurences': result.length, 'result': result};
}
