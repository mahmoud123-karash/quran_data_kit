# 📖 Quran Data Kit (`quran_data_kit`)

A modern, comprehensive, and high-performance Flutter/Dart package for Holy Quran applications.

`quran_data_kit` brings together an authentic **QCF (Quran Complex Font) Mushaf rendering engine**, rich **Quranic metadata** (Surahs, Juzs, Pages, Hizb quarters, Sajdah marks), **bundled offline translations in 16 languages**, **audio stream URLs**, and **Arabic text search and normalization utilities** — all in one clean, modular, and publication-ready package.

[![Pub Version](https://img.shields.io/pub/v/quran_data_kit?color=blue&style=flat-square)](https://pub.dev/packages/quran_data_kit)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Platform-Flutter%20%7C%20Dart-02569B.svg)](https://flutter.dev)

---

## ✨ Features

- 📜 **Complete Quran Dataset**: In-memory metadata and text for all 114 Surahs, 6,236 Ayahs, 604 Hafs pages, 30 Juzs, and 240 Hizb quarters (Rub el-Hizb).
- 🎨 **QCF Tajweed Rendering Engine**:
  - `QuranPageView`: Authentic page-by-page Mushaf reader with smooth horizontal scrolling, responsive two-page layout on tablets, and lazy font caching.
  - `QuranSurahListView`: Vertical continuous scrollable Surah reader with line-by-line or verse-by-verse presentation and translations.
  - Dark mode and light mode Tajweed coloring.
  - Interactive Ayah and word highlighting (for audio sync, bookmarks, or memorization).
- 🌍 **16 Offline Translations**: English (Saheeh International, Clear Quran), Turkish, Malayalam, Persian/Dari, French, Italian, Dutch, Portuguese, Russian, Urdu, Bengali, Chinese, Indonesian, Spanish, and Swedish.
- 🔊 **Audio Streaming Helpers**: CDN URLs for full Surahs and individual verses with multiple reciter identifiers.
- 🔍 **Arabic Text Utilities**: Diacritic removal, flexible orthographic normalization, and in-memory search across Emlaey and Uthmanic scripts.
- 🎲 **Random Verse Generator**: Simple `RandomVerse` class for verse-of-the-day widgets.
- ⚡ **Zero-Jank Performance**: Static caching and background Isolate offset computation ensures 60/120 FPS scrolling without asset I/O bottlenecks.

---

## 🚀 Getting Started

Add `quran_data_kit` to your `pubspec.yaml`:

```yaml
dependencies:
  quran_data_kit: ^1.0.0
```

Then run:

```bash
flutter pub get
```

---

## 📖 Usage Guide

### 1. Rendering a Full Mushaf Page (`QuranPageView`)

```dart
import 'package:flutter/material.dart';
import 'package:quran_data_kit/quran_data_kit.dart';

class MushafScreen extends StatefulWidget {
  const MushafScreen({super.key});

  @override
  State<MushafScreen> createState() => _MushafScreenState();
}

class _MushafScreenState extends State<MushafScreen> {
  final PageController _controller = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: QuranPageView(
          pageController: _controller,
          isTajweed: true,
          isDarkMode: Theme.of(context).brightness == Brightness.dark,
          onPageChanged: (pageIndex) {
            debugPrint('Current page: $pageIndex');
          },
          onLongPress: (surah, verse, details, {ayahBottomY, ayahTopY}) {
            debugPrint('Long pressed on Surah $surah, Ayah $verse');
          },
        ),
      ),
    );
  }
}
```

### 2. Vertical Surah Reader with Highlights (`QuranSurahListView`)

```dart
import 'package:flutter/material.dart';
import 'package:quran_data_kit/quran_data_kit.dart';

class SurahReaderScreen extends StatelessWidget {
  final int surahNumber;
  const SurahReaderScreen({super.key, required this.surahNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(getSurahName(surahNumber))),
      body: QuranSurahListView(
        surahNumber: surahNumber,
        translation: Translation.enSaheeh,
        highlights: [
          // Highlight verse 1 with amber tint
          HighlightVerse(
            surah: surahNumber,
            verseNumber: 1,
            page: getPageNumber(surahNumber, 1),
            color: Colors.amber.withValues(alpha: 0.3),
          ),
        ],
        onLongPress: (surah, verse, details) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ayah: $surah:$verse')),
          );
        },
      ),
    );
  }
}
```

### 3. Metadata & Lookups

```dart
import 'package:quran_data_kit/quran_data_kit.dart';

// Surah metadata
String nameAr = getSurahNameArabic(1);     // "الفاتحة"
String nameEn = getSurahNameEnglish(1);    // "The Opening"
String place = getPlaceOfRevelation(1);    // "Makkah"
int totalVerses = getVerseCount(1);        // 7

// Multi-language names
String nameTr = getSurahNameTurkish(1);    // "Fâtiha"
String nameFr = getSurahNameFrench(1);     // "L'ouverture"
String nameRu = getSurahNameRussian(1);    // "Открывающая Коран"

// Page & Verse lookups
int page = getPageNumber(2, 255);          // 42 (Ayat Al-Kursi)
int juz = getJuzNumber(2, 255);            // 3
int quarter = getQuarterNumber(2, 255);    // 8

// Prostration (Sajdah) detection
bool isSajda = isSajdahVerse(32, 15);       // true
```

### 4. Bundled Offline Translations

```dart
import 'package:quran_data_kit/quran_data_kit.dart';

// English (Saheeh International)
String enText = getVerseTranslation(1, 1, translation: Translation.enSaheeh);

// French (Hamidullah)
String frText = getVerseTranslation(1, 1, translation: Translation.frHamidullah);

// Search words across translations
Map searchRes = searchWordsInTranslation(['mercy', 'forgiveness'], translation: Translation.enSaheeh);
debugPrint('Matches found: ${searchRes['occurences']}');
```

### 5. Audio URLs & Reciters

```dart
import 'package:quran_data_kit/quran_data_kit.dart';

// Full Surah audio
String surahAudio = getAudioURLBySurah(1);

// Verse audio by global ID and reciter
String verseAudio = getAudioURLByVerse(1, 'ar.alafasy');

// Reciter metadata list
List<Map<String, dynamic>> reciters = getReciters();
```

### 6. Verse of the Day (`RandomVerse`)

```dart
import 'package:quran_data_kit/quran_data_kit.dart';

final random = RandomVerse();
debugPrint('Surah: ${random.surahNumber}');
debugPrint('Ayah: ${random.verseNumber}');
debugPrint('Arabic: ${random.verse}');
debugPrint('Translation: ${random.translation}');
```

---

## 🛠️ Package Structure

```
quran_data_kit/
├── assets/
│   ├── fonts/           # Arsura, Hafs, and Basmalah fonts
│   └── surah_banner.png # Vector banner for Surah headers
├── example/             # Complete runnable demo Flutter app
├── lib/
│   ├── quran_data_kit.dart  # Top-level API and facade exports
│   └── src/
│       ├── data/            # In-memory Quran dataset, quarters, suwar, translations
│       ├── models/          # Ayah, Surah, QuranPage, Line, HighlightVerse, RandomVerse
│       ├── services/        # GetPage parser and isolate processor
│       ├── utils/           # QdkFontLoader, QuranTextStyles, text normalizers
│       └── widgets/         # QuranPageView, QuranSurahListView, header & basmallah widgets
```

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
