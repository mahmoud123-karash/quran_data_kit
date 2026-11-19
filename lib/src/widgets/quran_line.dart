import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:quran_data_kit/quran_data_kit.dart';

import 'quran_page/highlight_index.dart';
import 'quran_page/parsed_quran_data.dart';

/// Renders a single line of Quranic text with responsive font scaling,
/// word-by-word tap recognizers, highlight overlays, and ornate Ayah medallions.
class QuranLine extends StatefulWidget {
  final List<ParsedAyahData> parsedAyahs;
  final int pageNumber;
  final WordHighlightIndex wordHighlightIndex;
  final BookmarkIndex bookmarkIndex;
  final BoxFit boxFit;
  final void Function(
    int surahNumber,
    int verseNumber,
    LongPressStartDetails details,
  )?
  onLongPress;
  final void Function(
    int surahNumber,
    int verseNumber,
    int wordIndex,
    String word,
  )?
  onWordTap;
  final TextStyle? ayahStyle;
  final bool isTajweed;
  final bool isDark;

  /// Optional custom builder for Ayah number medallions.
  final Widget Function(BuildContext context, int surahNumber, int ayahNumber)?
  ayahNumberBuilder;

  /// Color applied to the Ayah number medallion symbol.
  final Color? ayahSymbolColor;

  /// Custom color applied to the Ayah number medallion in light mode.
  final Color? ayahSymbolLightColor;

  /// Custom color applied to the Ayah number medallion in dark mode.
  final Color? ayahSymbolDarkColor;

  /// Optional vertical offset to fine-tune Ayah number medallion positioning.
  final double? ayahSymbolVerticalOffset;

  /// Optional padding around the Ayah number medallion (left and right spacing).
  final EdgeInsetsGeometry? ayahSymbolPadding;

  const QuranLine({
    super.key,
    required this.parsedAyahs,
    required this.pageNumber,
    this.wordHighlightIndex = WordHighlightIndex.empty,
    this.bookmarkIndex = BookmarkIndex.empty,
    this.boxFit = BoxFit.fill,
    this.onLongPress,
    this.onWordTap,
    this.ayahStyle,
    this.isTajweed = true,
    this.isDark = false,
    this.ayahNumberBuilder,
    this.ayahSymbolColor,
    this.ayahSymbolLightColor,
    this.ayahSymbolDarkColor,
    this.ayahSymbolVerticalOffset,
    this.ayahSymbolPadding,
  });

  /// Default Ayah number medallion symbol color in light mode (matching banner).
  static const Color defaultLightAyahSymbolColor =
      SurahHeaderWidget.defaultLightBannerColor;

  /// Default Ayah number medallion symbol color in dark mode (matching banner).
  static const Color defaultDarkAyahSymbolColor =
      SurahHeaderWidget.defaultDarkBannerColor;

  /// Default horizontal padding around the Ayah number medallion symbol.
  static const EdgeInsetsGeometry defaultAyahSymbolPadding =
      EdgeInsets.symmetric(horizontal: 2.0);

  @override
  State<QuranLine> createState() => _QuranLineState();
}

class _QuranLineState extends State<QuranLine> {
  List<List<TapGestureRecognizer?>> _recognizers = [];
  bool _recognizersReady = false;
  Timer? _debounceTimer;

  late TextStyle _mainTextStyle;
  late TextStyle _numberTextStyle;
  late StrutStyle _strutStyle;

  @override
  void initState() {
    super.initState();
    _buildRecognizersAsync();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _buildStyles();
  }

  @override
  void didUpdateWidget(covariant QuranLine oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.parsedAyahs != widget.parsedAyahs ||
        oldWidget.onWordTap != widget.onWordTap) {
      _buildRecognizersAsync();
    }
    if (oldWidget.isDark != widget.isDark ||
        oldWidget.isTajweed != widget.isTajweed ||
        oldWidget.ayahStyle != widget.ayahStyle ||
        oldWidget.ayahNumberBuilder != widget.ayahNumberBuilder ||
        oldWidget.ayahSymbolColor != widget.ayahSymbolColor ||
        oldWidget.ayahSymbolLightColor != widget.ayahSymbolLightColor ||
        oldWidget.ayahSymbolDarkColor != widget.ayahSymbolDarkColor ||
        oldWidget.ayahSymbolVerticalOffset != widget.ayahSymbolVerticalOffset ||
        oldWidget.ayahSymbolPadding != widget.ayahSymbolPadding) {
      _buildStyles();
    }
  }

  void _buildRecognizersAsync() {
    if (widget.onWordTap == null) {
      _recognizersReady = false;
      return;
    }

    _recognizersReady = false;
    _disposeRecognizers();

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 150), () {
      if (!mounted) return;

      _recognizers =
          widget.parsedAyahs.map((ayahData) {
            return ayahData.words.map<TapGestureRecognizer?>((wordData) {
              if (wordData.isSpace ||
                  wordData.isSymbol ||
                  wordData.wordIndex == null ||
                  wordData.logicalWord == null) {
                return null;
              }
              final surah = ayahData.surahNumber;
              final ayah = ayahData.ayahNumber;
              final wordIndex = wordData.wordIndex!;
              final logicalWord = wordData.logicalWord!;

              return TapGestureRecognizer()
                ..onTap =
                    () => widget.onWordTap?.call(
                      surah,
                      ayah,
                      wordIndex,
                      logicalWord,
                    );
            }).toList();
          }).toList();

      if (mounted) {
        setState(() {
          _recognizersReady = true;
        });
      }
    });
  }

  void _disposeRecognizers() {
    for (final ayahRecognizers in _recognizers) {
      for (final r in ayahRecognizers) {
        r?.dispose();
      }
    }
    _recognizers.clear();
  }

  void _buildStyles() {
    final defaultStyle =
        widget.ayahStyle ??
        QuranTextStyles.qcfStyle(
          height: 1.45,
          pageNumber: widget.pageNumber,
          isTajweed: widget.isTajweed,
          isDark: widget.isDark,
        );

    _mainTextStyle = defaultStyle.copyWith(height: null, color: null);
    _numberTextStyle = _mainTextStyle.copyWith(
      fontSize: _mainTextStyle.fontSize,
      fontFamily: QuranTextStyles.getQcfFontFamily(
        pageNumber: widget.pageNumber,
        isTajweed: widget.isTajweed,
        isDark: widget.isDark,
      ),
    );
    _strutStyle = StrutStyle.fromTextStyle(
      _mainTextStyle,
      forceStrutHeight: true,
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _disposeRecognizers();
    super.dispose();
  }

  InlineSpan _buildAyahSymbol(BuildContext context, ParsedAyahData ayahData) {
    final EdgeInsetsGeometry effectivePadding =
        widget.ayahSymbolPadding ?? QuranLine.defaultAyahSymbolPadding;

    if (widget.ayahNumberBuilder != null) {
      Widget customWidget = widget.ayahNumberBuilder!(
        context,
        ayahData.surahNumber,
        ayahData.ayahNumber,
      );
      if (widget.ayahSymbolVerticalOffset != null &&
          widget.ayahSymbolVerticalOffset != 0) {
        customWidget = Transform.translate(
          offset: Offset(0, widget.ayahSymbolVerticalOffset!),
          child: customWidget,
        );
      }
      customWidget = Padding(padding: effectivePadding, child: customWidget);
      return WidgetSpan(
        alignment: PlaceholderAlignment.baseline,
        baseline: TextBaseline.alphabetic,
        child: customWidget,
      );
    }

    final Color effectiveSymbolColor =
        widget.ayahSymbolColor ??
        (widget.isDark
            ? (widget.ayahSymbolDarkColor ??
                QuranLine.defaultDarkAyahSymbolColor)
            : (widget.ayahSymbolLightColor ??
                QuranLine.defaultLightAyahSymbolColor));

    Widget symbolChild = ColorFiltered(
      colorFilter: ColorFilter.mode(effectiveSymbolColor, BlendMode.srcIn),
      child: Text(
        ayahData.glyph!,
        style: _numberTextStyle,
        strutStyle: _strutStyle,
        textDirection: TextDirection.rtl,
      ),
    );

    if (widget.ayahSymbolVerticalOffset != null &&
        widget.ayahSymbolVerticalOffset != 0) {
      symbolChild = Transform.translate(
        offset: Offset(0, widget.ayahSymbolVerticalOffset!),
        child: symbolChild,
      );
    }

    symbolChild = Padding(padding: effectivePadding, child: symbolChild);

    return WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: symbolChild,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.parsedAyahs.isEmpty) return const SizedBox.shrink();

    final textWidget = RichText(
      textDirection: TextDirection.rtl,
      strutStyle: _strutStyle,
      text: TextSpan(
        style: _mainTextStyle,
        children: List.generate(widget.parsedAyahs.length, (ayahIdx) {
          final ayahData = widget.parsedAyahs[ayahIdx];

          final bookmark = widget.bookmarkIndex.lookup(
            ayahData.surahNumber,
            ayahData.ayahNumber,
          );
          final isAyahHighlighted = bookmark != null;
          final highlightColor = bookmark?.color ?? Colors.transparent;
          final wordSpans = <InlineSpan>[];

          for (int wIdx = 0; wIdx < ayahData.words.length; wIdx++) {
            final wordData = ayahData.words[wIdx];
            var charStyle = _mainTextStyle;

            if (!wordData.isSpace && wordData.wordIndex != null) {
              final wordHighlight = widget.wordHighlightIndex.lookup(
                ayahData.surahNumber,
                ayahData.ayahNumber,
                wordData.wordIndex!,
              );

              if (wordHighlight != null) {
                if (wordHighlight.textColor != null) {
                  charStyle = charStyle.copyWith(
                    color: wordHighlight.textColor!,
                  );
                }
                if (!wordData.isSymbol &&
                    wordHighlight.backgroundColor != null) {
                  charStyle = charStyle.copyWith(
                    backgroundColor: wordHighlight.backgroundColor,
                  );
                }
              }
            }

            wordSpans.add(
              TextSpan(
                text: wordData.text,
                style: charStyle,
                recognizer:
                    _recognizersReady ? _recognizers[ayahIdx][wIdx] : null,
              ),
            );
          }

          if (ayahData.glyph != null) {
            wordSpans.add(_buildAyahSymbol(context, ayahData));
          }

          return WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: Builder(
              builder: (innerCtx) {
                return GestureDetector(
                  onLongPressStart: (details) {
                    final box = innerCtx.findRenderObject() as RenderBox?;
                    final double bottomY =
                        box != null
                            ? box.localToGlobal(Offset(0, box.size.height)).dy
                            : details.globalPosition.dy;
                    widget.onLongPress?.call(
                      ayahData.surahNumber,
                      ayahData.ayahNumber,
                      LongPressStartDetails(
                        globalPosition: Offset(
                          details.globalPosition.dx,
                          bottomY,
                        ),
                        localPosition: details.localPosition,
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
                      color:
                          isAyahHighlighted
                              ? highlightColor.withValues(alpha: 0.4)
                              : null,
                    ),
                    child: Text.rich(
                      TextSpan(style: _mainTextStyle, children: wordSpans),
                      textDirection: TextDirection.rtl,
                      strutStyle: _strutStyle,
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );

    return FittedBox(fit: widget.boxFit, child: textWidget);
  }
}
