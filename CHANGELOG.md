## 1.0.2

- **Custom Page Footer Builder**:
  - Added `pageFooterBuilder` to both `QuranPageView` and `QuranSinglePageWidget` (mirroring `pageHeaderBuilder`), allowing full customization of bottom page UI (Juz/Hizb progress, custom navigation controls, page numbers, or reading markers).
- **Typographic Consistency & Ayah Medallions**:
  - Unified Ayah number symbol size and baseline alignment across all pages, ensuring pages 1 and 2 (Al-Fatiha and Al-Baqarah) match standard body pages in rosette scale.
  - Improved vertical alignment and spacing between Ayah symbols and verse glyphs.

## 1.0.1

- **Medina Mushaf Styling & Customization**:
  - Unified Surah header banner to a single transparent-background Medina ornament (`assets/surah_banner.png`) for both light and dark modes, allowing the underlying page theme to show through seamlessly.
  - Added granular color customization for Surah header and Ayah number medallions:
    - `surahHeaderColor`, `surahHeaderLightColor`, `surahHeaderDarkColor`, and `surahHeaderTextColor`.
    - `ayahSymbolColor`, `ayahSymbolLightColor`, and `ayahSymbolDarkColor`.
    - `surahHeaderBottomPadding` to control spacing between the Surah header banner and the Basmallah.
  - In dark mode, `SurahHeaderWidget` automatically tints the banner linework with a soft, muted warm sand-bronze (`#A89680`) and Surah name text with white by default, blending gently with dark backgrounds and white verse text without harsh glare.
  - Updated Ayah number symbol rendering: replaced default colored Tajweed rosette with authentic Medina bronze/sand rosette medallion (`#814E13` light / `#A89680` dark) with transparent inner fill.
  - Added `ayahNumberBuilder` parameter across `QuranPageView`, `QuranSinglePageWidget`, and `QuranLine` for complete custom Ayah number widget rendering.
  - Added `ayahSymbolPadding` and `ayahSymbolVerticalOffset` for fine-tuning Ayah medallion spacing.
  - Enhanced Ayah medallion typographic alignment using alphabetic baseline alignment and synchronized `StrutStyle` with verse text.
  - Refactored example app into clean modular tabs and screens.
  - Updated README with new high-resolution screenshots for standard and Tajweed modes in light and dark themes.

## 1.0.0

- **Initial Release of `quran_data_kit`**:
  - Unified, modern Flutter/Dart Quran package combining complete Quran dataset, QCF Tajweed font rendering, and rich metadata lookups.
  - **QCF Page Views**:
    - `QuranPageView`: High-performance horizontal reader with page caching, lazy font loading, Tajweed colors, and dark-mode support.
    - `QuranSinglePageWidget`: Single-page layout widget supporting headers, Basmallah, and QCF line rendering.
  - **Rich Metadata & Lookups**:
    - Surah metadata (Arabic, English, Turkish, French, Russian names, revelation place, verse counts).
    - Page-to-verse and verse-to-page mappings (all 604 Hafs pages).
    - Juz and Hizb quarter / Rub el-Hizb (1-240) markers.
    - Prostration of recitation (`Sajdah`) detection.
  - **Built-in Translations**:
    - 16 languages bundled in-memory: English (Saheeh, Clear Quran), Turkish, Malayalam, Persian/Dari, French, Italian, Dutch, Portuguese, Russian, Urdu, Bengali, Chinese, Indonesian, Spanish, and Swedish.
    - Verse translation lookup and translation search capabilities.
  - **Reciters & Audio Streaming**:
    - CDN audio URLs for full Surahs and individual verses with reciter identifiers.
  - **Arabic Text Utilities**:
    - Diacritic removal (`removeDiacritics`).
    - Full text normalization (`normalise`, `normalizeArabicText`).
    - In-memory Arabic text search across both Emlaey and Uthmanic scripts.
  - **Random Verse**:
    - `RandomVerse` class for verse-of-the-day features.
