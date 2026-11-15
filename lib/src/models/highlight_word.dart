import 'package:flutter/material.dart';

/// Represents a highlighted state for a specific word inside an Ayah.
///
/// Useful during audio recitation to track word-by-word playback,
/// vocabulary study, or word-level interactive features.
class WordHighlight {
  /// The Surah number (1-114).
  final int surah;

  /// The Ayah number within the Surah (1-based).
  final int verseNumber;

  /// The 0-based word index within the verse.
  final int wordIndex;

  /// Background color applied to the word glyph.
  final Color? backgroundColor;

  /// Text color applied to the word glyph.
  final Color? textColor;

  /// Creates a constant [WordHighlight] descriptor.
  const WordHighlight({
    required this.surah,
    required this.verseNumber,
    required this.wordIndex,
    this.backgroundColor,
    this.textColor,
  });
}
