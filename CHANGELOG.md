## 1.0.0

* **Initial Release of `quran_data_kit`**:
  * Unified, modern Flutter/Dart Quran package combining complete Quran dataset, QCF Tajweed font rendering, and rich metadata lookups.
  * **QCF Page Views**:
    * `QuranPageView`: High-performance horizontal reader with page caching, lazy font loading, Tajweed colors, and dark-mode support.
    * `QuranSinglePageWidget`: Single-page layout widget supporting headers, Basmallah, and QCF line rendering.
  * **Rich Metadata & Lookups**:
    * Surah metadata (Arabic, English, Turkish, French, Russian names, revelation place, verse counts).
    * Page-to-verse and verse-to-page mappings (all 604 Hafs pages).
    * Juz and Hizb quarter / Rub el-Hizb (1-240) markers.
    * Prostration of recitation (`Sajdah`) detection.
  * **Built-in Translations**:
    * 16 languages bundled in-memory: English (Saheeh, Clear Quran), Turkish, Malayalam, Persian/Dari, French, Italian, Dutch, Portuguese, Russian, Urdu, Bengali, Chinese, Indonesian, Spanish, and Swedish.
    * Verse translation lookup and translation search capabilities.
  * **Reciters & Audio Streaming**:
    * CDN audio URLs for full Surahs and individual verses with reciter identifiers.
  * **Arabic Text Utilities**:
    * Diacritic removal (`removeDiacritics`).
    * Full text normalization (`normalise`, `normalizeArabicText`).
    * In-memory Arabic text search across both Emlaey and Uthmanic scripts.
  * **Random Verse**:
    * `RandomVerse` class for verse-of-the-day features.
