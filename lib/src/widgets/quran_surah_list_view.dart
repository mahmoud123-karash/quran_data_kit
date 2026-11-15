import 'package:flutter/material.dart';

import '../../quran_data_kit.dart';

/// A vertical scrollable reader for an entire Quranic Surah (chapter).
///
/// Displays Surah metadata headers, optional Basmallah, and the sequence of
/// verses with support for highlights, word/verse gestures, translations,
/// and custom styles.
class QuranSurahListView extends StatelessWidget {
  /// The 1-based index of the Surah to display (1 to 114).
  final int surahNumber;

  /// Verses to be highlighted (e.g. bookmarks or search hits).
  final List<HighlightVerse> highlights;

  /// Callback fired when an Ayah is long-pressed.
  final void Function(
    int surahNumber,
    int verseNumber,
    LongPressStartDetails details,
  )?
  onLongPress;

  /// Callback fired when an Ayah is tapped.
  final void Function(int surahNumber, int verseNumber)? onAyahTap;

  /// Whether to render in dark mode styling. Defaults to `false`.
  final bool isDarkMode;

  /// Whether to show the ornate Surah header banner. Defaults to `true`.
  final bool showHeader;

  /// Whether to show the Basmallah banner above verses. Defaults to `true`.
  /// Automatically omitted for Surah At-Tawbah (9) and Surah Al-Fatihah (1).
  final bool showBasmalah;

  /// Custom builder for Surah headers.
  final Widget Function(BuildContext context, int surahNumber)?
  surahHeaderBuilder;

  /// Custom builder for the Basmallah.
  final Widget Function(BuildContext context, int surahNumber)?
  basmallahBuilder;

  /// Custom builder for individual Ayah tiles.
  final Widget Function(BuildContext context, Ayah ayah, bool isHighlighted)?
  ayahBuilder;

  /// Text style applied to the Arabic verse text.
  final TextStyle? ayahStyle;

  /// Optional bundled translation to display beneath each verse.
  final Translation? translation;

  /// Text style applied to the verse translation text.
  final TextStyle? translationStyle;

  /// Scroll controller for the list.
  final ScrollController? controller;

  /// Scroll physics for the list.
  final ScrollPhysics? physics;

  /// Outer padding for the scroll view.
  final EdgeInsetsGeometry? padding;

  /// Background color of the container.
  final Color? backgroundColor;

  /// Color of the divider between verses.
  final Color? dividerColor;

  /// Whether to display a divider line between verses. Defaults to `true`.
  final bool showDivider;

  const QuranSurahListView({
    super.key,
    required this.surahNumber,
    this.highlights = const [],
    this.onLongPress,
    this.onAyahTap,
    this.isDarkMode = false,
    this.showHeader = true,
    this.showBasmalah = true,
    this.surahHeaderBuilder,
    this.basmallahBuilder,
    this.ayahBuilder,
    this.ayahStyle,
    this.translation,
    this.translationStyle,
    this.controller,
    this.physics,
    this.padding,
    this.backgroundColor,
    this.dividerColor,
    this.showDivider = true,
  }) : assert(
         surahNumber >= 1 && surahNumber <= 114,
         'surahNumber must be between 1 and 114',
       );

  @override
  Widget build(BuildContext context) {
    final surahData = surahs[surahNumber - 1];
    final ayahs = surahData.ayahs;

    final defaultTextColor = isDarkMode ? Colors.white : Colors.black87;
    final defaultSecondaryColor =
        isDarkMode ? Colors.white70 : Colors.black54;

    final baseAyahStyle =
        ayahStyle ??
        QuranTextStyles.hafsStyle(
          fontSize: 24,
          height: 1.8,
          color: defaultTextColor,
        );

    final baseTranslationStyle =
        translationStyle ??
        TextStyle(
          fontSize: 14,
          height: 1.5,
          color: defaultSecondaryColor,
        );

    // Build lookup set for highlighted verse numbers in this surah
    final highlightMap = <int, Color>{};
    for (final h in highlights) {
      if (h.surah == surahNumber) {
        highlightMap[h.verseNumber] = h.color;
      }
    }

    final effectivePadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);

    return Container(
      color: backgroundColor ?? Colors.transparent,
      child: ListView.builder(
        controller: controller,
        physics: physics ?? const BouncingScrollPhysics(),
        padding: effectivePadding,
        itemCount: ayahs.length + (showHeader ? 1 : 0) + (_shouldShowBasmalah() ? 1 : 0),
        itemBuilder: (context, index) {
          int offset = 0;

          // 1. Surah Header
          if (showHeader) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: surahHeaderBuilder?.call(context, surahNumber) ??
                    SurahHeaderWidget(
                      surahNumber: surahNumber,
                      isDark: isDarkMode,
                    ),
              );
            }
            offset++;
          }

          // 2. Basmallah
          if (_shouldShowBasmalah()) {
            if (index == offset) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: basmallahBuilder?.call(context, surahNumber) ??
                    BasmallahWidget(
                      surahNumber,
                      isDark: isDarkMode,
                    ),
              );
            }
            offset++;
          }

          final ayahIndex = index - offset;
          final ayah = ayahs[ayahIndex];
          final isHighlighted = highlightMap.containsKey(ayah.ayahNumber);
          final highlightColor = highlightMap[ayah.ayahNumber];

          if (ayahBuilder != null) {
            return ayahBuilder!(context, ayah, isHighlighted);
          }

          return _buildDefaultAyahTile(
            context: context,
            ayah: ayah,
            isHighlighted: isHighlighted,
            highlightColor: highlightColor,
            ayahStyle: baseAyahStyle,
            translationStyle: baseTranslationStyle,
          );
        },
      ),
    );
  }

  bool _shouldShowBasmalah() {
    if (!showBasmalah) return false;
    // Surah At-Tawbah does not have Basmalah; Al-Fatihah includes it as verse 1
    return surahNumber != 9 && surahNumber != 1;
  }

  Widget _buildDefaultAyahTile({
    required BuildContext context,
    required Ayah ayah,
    required bool isHighlighted,
    required Color? highlightColor,
    required TextStyle ayahStyle,
    required TextStyle translationStyle,
  }) {
    String? verseTranslation;
    if (translation != null) {
      try {
        verseTranslation = getVerseTranslation(
          ayah.surahNumber,
          ayah.ayahNumber,
          translation: translation!,
        );
      } catch (_) {
        verseTranslation = null;
      }
    }

    final effectiveHighlightColor =
        highlightColor ??
        (isDarkMode
            ? Colors.amber.withValues(alpha: 0.25)
            : Colors.amber.withValues(alpha: 0.35));

    return GestureDetector(
      onTap: () => onAyahTap?.call(ayah.surahNumber, ayah.ayahNumber),
      onLongPressStart: (details) {
        onLongPress?.call(ayah.surahNumber, ayah.ayahNumber, details);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isHighlighted ? effectiveHighlightColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
          border: showDivider
              ? Border(
                  bottom: BorderSide(
                    color: dividerColor ??
                        (isDarkMode
                            ? Colors.white12
                            : Colors.black.withValues(alpha: 0.06)),
                  ),
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Row with Ayah number, Sajdah indicator, and Arabic verse text
            Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ayah number badge
                  _AyahNumberBadge(
                    ayahNumber: ayah.ayahNumber,
                    isDark: isDarkMode,
                  ),
                  const SizedBox(width: 12),
                  // Ayah text
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: ayah.othmanicAyah.isNotEmpty
                                ? ayah.othmanicAyah
                                : ayah.ayah,
                            style: ayahStyle,
                          ),
                          if (ayah.sajda) ...[
                            const WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.0),
                                child: _SajdahBadge(),
                              ),
                            ),
                          ],
                        ],
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
            ),
            // Optional translation
            if (verseTranslation != null && verseTranslation.isNotEmpty) ...[
              const SizedBox(height: 8),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Padding(
                  padding: const EdgeInsets.only(left: 44.0, right: 8.0),
                  child: Text(
                    verseTranslation,
                    style: translationStyle,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Ornate circular badge displaying an Ayah's sequence number.
class _AyahNumberBadge extends StatelessWidget {
  final int ayahNumber;
  final bool isDark;

  const _AyahNumberBadge({
    required this.ayahNumber,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark ? Colors.amber.shade700 : const Color(0xFF8A6D3B);
    final bgColor = isDark
        ? Colors.amber.withValues(alpha: 0.15)
        : const Color(0xFFF9F5EB);

    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Text(
        '$ayahNumber',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.amber.shade200 : const Color(0xFF5A4426),
        ),
      ),
    );
  }
}

/// Small tag indicating a prostration of recitation (Sajdah Tilawah).
class _SajdahBadge extends StatelessWidget {
  const _SajdahBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.red.shade400, width: 0.8),
      ),
      child: const Text(
        '۩ سجدة',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.red,
        ),
      ),
    );
  }
}
