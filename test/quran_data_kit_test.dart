import 'package:flutter_test/flutter_test.dart';
import 'package:quran_data_kit/quran_data_kit.dart';

void main() {
  group('Quran Constants & Metadata Tests', () {
    test('Global count constants are accurate', () {
      expect(totalSurahCount, 114);
      expect(totalPagesCount, 604);
      expect(totalVerseCount, 6236);
      expect(totalJuzCount, 30);
      expect(totalMakkiSurahsCount, 89);
      expect(totalMadaniSurahsCount, 25);
      expect(basmala, isNotEmpty);
      expect(sajdah, isNotEmpty);
    });

    test('Al-Fatiha metadata is correct', () {
      expect(getSurahName(1), 'Al Fatiha');
      expect(getSurahNameArabic(1), 'الفاتحة');
      expect(getSurahNameEnglish(1), 'The Opening');
      expect(getSurahNameTurkish(1), 'Fâtiha');
      expect(getSurahNameFrench(1), "L'ouverture");
      expect(getSurahNameRussian(1), 'Открывающая Коран');
      expect(getPlaceOfRevelation(1), 'Makkah');
      expect(getVerseCount(1), 7);
      expect(getSurahPages(1), [1]);
    });

    test('Surah Al-Baqarah metadata is correct', () {
      expect(getSurahName(2), 'Al Baqarah');
      expect(getSurahNameArabic(2), 'البقرة');
      expect(getPlaceOfRevelation(2), 'Madinah');
      expect(getVerseCount(2), 286);
      expect(getSurahPages(2).first, 2);
    });
  });

  group('Page & Verse Lookup Tests', () {
    test('Page number lookup for specific verses', () {
      expect(getPageNumber(1, 1), 1);
      expect(getPageNumber(2, 255), 42); // Ayat Al-Kursi
      expect(getPageNumber(114, 6), 604); // Last verse of An-Nas
    });

    test('Verse text retrieval', () {
      final v1 = getVerse(1, 1);
      expect(v1, contains('بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ'));

      final vWithEndSymbol = getVerse(1, 1, verseEndSymbol: true);
      expect(vWithEndSymbol, contains('١'));
    });

    test('QCF glyph and text retrieval', () {
      final glyph = getAyaNoQCF(1, 1);
      expect(glyph, isNotEmpty);

      final qcfText = getVerseQCF(1, 1);
      expect(qcfText, isNotEmpty);
    });

    test('getVersesTextByPage retrieves verses for page 1', () {
      final verses = getVersesTextByPage(1);
      expect(verses.length, 7);
    });
  });

  group('Juz & Quarter Helpers Tests', () {
    test('Juz lookup', () {
      expect(getJuzNumber(1, 1), 1);
      expect(getJuzNumber(2, 255), 3);
      expect(getJuzNumber(114, 1), 30);
    });

    test('Quarter (Rub el-Hizb) lookup', () {
      expect(getQuarterNumber(1, 1), 1);
      expect(getQuarterNumber(2, 255), greaterThan(1));
    });

    test('Hizb label formatting', () {
      final hizbText = getCurrentHizbTextForPage(1, isArabic: true);
      expect(hizbText, contains('الحزب'));

      final hizbEn = getCurrentHizbTextForPage(1, isArabic: false);
      expect(hizbEn, contains('Hizb'));
    });
  });

  group('Sajdah Detection Tests', () {
    test('Known Sajdah verses are detected', () {
      expect(isSajdahVerse(32, 15), isTrue); // As-Sajdah 15
      expect(isSajdahVerse(1, 1), isFalse);
      expect(isSajdahVerse(2, 255), isFalse);
    });
  });

  group('Audio & Reciters Tests', () {
    test('Surah and verse audio URLs', () {
      final surahAudio = getAudioURLBySurah(1);
      expect(surahAudio, contains('1.mp3'));
      expect(surahAudio, startsWith('https://'));

      final verseAudio = getAudioURLByVerse(1, 'ar.alafasy');
      expect(verseAudio, contains('1.mp3'));

      final verseNumAudio = getAudioURLByVerseNumber(1);
      expect(verseNumAudio, contains('1.mp3'));
    });

    test('Reciters list is populated', () {
      final reciters = getReciters();
      expect(reciters, isNotEmpty);
      expect(reciters.any((r) => r['identifier'] == 'ar.alafasy'), isTrue);
    });
  });

  group('Translations Tests', () {
    test('Verse translation retrieval in English', () {
      final trans = getVerseTranslation(
        1,
        1,
        translation: Translation.enSaheeh,
      );
      expect(trans, contains('Allah'));
    });

    test('Verse translation in French', () {
      final trans = getVerseTranslation(
        1,
        1,
        translation: Translation.frHamidullah,
      );
      expect(trans, contains('Allah'));
    });

    test('searchWordsInTranslation finds matches', () {
      final results = searchWordsInTranslation([
        'mercy',
      ], translation: Translation.enSaheeh);
      expect(results['occurences'], greaterThan(0));
      expect((results['result'] as List), isNotEmpty);
    });
  });

  group('Arabic Text Utilities Tests', () {
    test('Diacritic removal', () {
      final cleaned = removeDiacritics('بِسْمِ اللَّهِ');
      expect(cleaned, 'بسم الله');
    });

    test('Text normalisation', () {
      final norm = normalise('إِنَّا أَنزَلْنَاهُ');
      expect(norm, contains('انزلناه'));
    });

    test('searchWords finds verses', () {
      final res = searchWords('الرحمن');
      expect(res['occurences'], greaterThan(0));
    });
  });

  group('RandomVerse Tests', () {
    test('RandomVerse instantiates with valid data', () {
      final rv = RandomVerse();
      expect(rv.surahNumber, inInclusiveRange(1, 114));
      expect(rv.verseNumber, greaterThanOrEqualTo(1));
      expect(rv.verse, isNotEmpty);
      expect(rv.translation, isNotEmpty);
    });
  });

  group('GetPage & Repository Tests', () {
    test('GetPage parses Quran into pages and surahs', () {
      final getPage = GetPage();
      getPage.getQuran(604);
      expect(getPage.surahs.length, 114);
      expect(getPage.ayahs.length, 6236);
      expect(getPage.staticPages.length, 604);

      // Verify convenience getters
      final fatiha = getPage.surahs.first;
      expect(fatiha.surahNumber, 1);
      expect(fatiha.arabicName, 'الفَاتِحة');
      expect(fatiha.englishName, 'Al-Fātiḥah');
      expect(fatiha.revelationType, 'Makkah');
    });
  });
}
