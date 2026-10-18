import 'package:flutter/material.dart';

import '../models/quran_page.dart';
import '../utils/font_loader_service.dart';
import '../utils/quran_text_styles.dart';
import 'basmallah_widget.dart';
import 'quran_line.dart';
import 'quran_page/highlight_index.dart';
import 'quran_page/parsed_quran_data.dart';
import 'surah_header_widget.dart';

/// Renders a single page of the Quran, including Surah headers, Basmallah,
/// and line-by-line verse text with responsive layout and Tajweed support.
class QuranSinglePageWidget extends StatefulWidget {
  /// The data model representing the lines and verses of this page.
  final QuranPage page;

  /// The 1-based page number being rendered (1–604).
  final int pageIndex;

  /// Pre-computed index for active word highlights.
  final WordHighlightIndex wordHighlightIndex;

  /// Pre-computed index for active bookmark highlights.
  final BookmarkIndex bookmarkIndex;

  /// Callback fired when a verse on this page is long-pressed.
  final void Function(
    int surahNumber,
    int verseNumber,
    LongPressStartDetails details, {
    double? ayahBottomY,
    double? ayahTopY,
  })?
  onLongPress;

  /// Callback fired when an individual word is tapped.
  final void Function(
    int surahNumber,
    int verseNumber,
    int wordIndex,
    String word,
  )?
  onWordTap;

  /// Optional PageController passed from parent context.
  final PageController? pageController;

  /// Custom builder for Surah headers.
  final Widget Function(BuildContext context, int surahNumber)?
  surahHeaderBuilder;

  /// Custom builder for the Basmallah graphic or text.
  final Widget Function(BuildContext context, int surahNumber)?
  basmallahBuilder;

  /// Custom builder for the header of the page (e.g. Juz / Hizb / Page markers).
  final Widget Function(BuildContext context, int pageIndex)? pageHeaderBuilder;

  /// Custom text style applied to the verses.
  final TextStyle? ayahStyle;

  /// Enables or disables Tajweed color-coded rendering.
  final bool isTajweed;

  /// Indicates if the application is currently rendered in dark mode.
  final bool isDark;

  /// Spatial mapping of words to their specific line boundaries.
  final Map<int, Map<String, int>> lineOffsets;

  /// Forces standard portrait aspect-ratio constraints in landscape orientations.
  final bool forceFitConstraints;

  /// Custom builder displayed when the page font fails to load.
  final Widget Function(int pageIndex, VoidCallback onRetry)? errorBuilder;

  /// Custom widget displayed while the page font is loading.
  final Widget? loadingBuilder;

  const QuranSinglePageWidget({
    super.key,
    required this.page,
    required this.pageIndex,
    required this.wordHighlightIndex,
    required this.bookmarkIndex,
    this.onLongPress,
    this.onWordTap,
    this.pageController,
    this.surahHeaderBuilder,
    this.basmallahBuilder,
    this.pageHeaderBuilder,
    this.ayahStyle,
    required this.isDark,
    this.isTajweed = true,
    required this.lineOffsets,
    required this.forceFitConstraints,
    this.errorBuilder,
    this.loadingBuilder,
  });

  @override
  State<QuranSinglePageWidget> createState() => _QuranSinglePageWidgetState();
}

class _QuranSinglePageWidgetState extends State<QuranSinglePageWidget> {
  static const int _standardLinesPerPage = 15;

  final Map<int, GlobalKey> _lineKeys = {};
  bool _fontReady = false;
  bool _fontError = false;

  @override
  void initState() {
    super.initState();
    _checkFont();
  }

  @override
  void didUpdateWidget(covariant QuranSinglePageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageIndex != widget.pageIndex) {
      _lineKeys.clear();
      _checkFont();
    }
  }

  void _handleVerseLongPress(
    int surahNumber,
    int verseNumber,
    LongPressStartDetails details,
  ) {
    // Locate the first and last line of this verse on the current page
    final firstLineIdx = widget.page.lines.indexWhere(
      (l) => l.ayahs.any(
        (a) => a.surahNumber == surahNumber && a.ayahNumber == verseNumber,
      ),
    );
    final lastLineIdx = widget.page.lines.lastIndexWhere(
      (l) => l.ayahs.any(
        (a) => a.surahNumber == surahNumber && a.ayahNumber == verseNumber,
      ),
    );

    double? ayahBottomY;
    double? ayahTopY;

    if (lastLineIdx != -1) {
      final key = _lineKeys[lastLineIdx];
      final renderBox = key?.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        ayahBottomY =
            renderBox.localToGlobal(Offset(0, renderBox.size.height)).dy;
      }
    }

    if (firstLineIdx != -1) {
      final key = _lineKeys[firstLineIdx];
      final renderBox = key?.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        ayahTopY = renderBox.localToGlobal(Offset.zero).dy;
      }
    }

    widget.onLongPress?.call(
      surahNumber,
      verseNumber,
      LongPressStartDetails(
        globalPosition: Offset(
          details.globalPosition.dx,
          ayahBottomY ?? details.globalPosition.dy,
        ),
        localPosition: details.localPosition,
      ),
      ayahBottomY: ayahBottomY,
      ayahTopY: ayahTopY,
    );
  }

  void _checkFont() {
    if (QdkFontLoader.isFontLoaded(widget.pageIndex)) {
      _fontReady = true;
      _fontError = false;
      return;
    }

    _fontReady = false;
    _fontError = false;

    QdkFontLoader.ensureFontLoaded(widget.pageIndex)
        .then((_) {
          if (mounted) {
            setState(() {
              _fontReady = true;
              _fontError = false;
            });
          }
        })
        .catchError((_) {
          if (mounted) {
            setState(() {
              _fontError = true;
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    if (!_fontReady) {
      if (_fontError) {
        return _buildErrorState();
      }
      return _buildLoadingState();
    }

    final orientation = MediaQuery.of(context).orientation;

    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final Size availableSize = Size(
            constraints.maxWidth,
            constraints.maxHeight,
          );

          if (widget.pageIndex == 1 || widget.pageIndex == 2) {
            return _buildFirstTwoPages(context, availableSize, orientation);
          } else {
            return _buildStandardPage(context, availableSize, orientation);
          }
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    if (widget.loadingBuilder != null) {
      return widget.loadingBuilder!;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
        const SizedBox(height: 16),

        Text(
          'جاري تحميل الصفحة ${widget.pageIndex}...',
          style: TextStyle(
            fontSize: 13,
            color: widget.isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(widget.pageIndex, () {
        setState(() => _fontError = false);
        _checkFont();
      });
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.info_outline_rounded, size: 42, color: Colors.grey),
        const SizedBox(height: 16),

        Text(
          'تعذر تحميل خط الصفحة (page: ${widget.pageIndex})',
          style: TextStyle(
            fontSize: 13,
            color: widget.isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        TextButton.icon(
          onPressed: () {
            setState(() => _fontError = false);
            _checkFont();
          },
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('إعادة المحاولة'),
        ),
      ],
    );
  }

  Widget _buildSurahHeaderWidget(
    BuildContext context,
    int surahNumber,
    bool shouldFit,
  ) {
    final Widget header =
        widget.surahHeaderBuilder?.call(context, surahNumber) ??
        SurahHeaderWidget(surahNumber: surahNumber);
    return shouldFit ? Expanded(child: Center(child: header)) : header;
  }

  Widget _buildBasmallahWidget(
    BuildContext context,
    int surahNumber,
    bool shouldFit,
  ) {
    final Widget basmallah =
        widget.basmallahBuilder?.call(context, surahNumber) ??
        BasmallahWidget(surahNumber);
    return shouldFit ? Expanded(child: Center(child: basmallah)) : basmallah;
  }

  /// Constructs the layout specifically tailored for the first two pages of the Quran (Al-Fatihah and start of Al-Baqarah).
  Widget _buildFirstTwoPages(
    BuildContext context,
    Size availableSize,
    Orientation orientation,
  ) {
    final bool shouldFit =
        (orientation == Orientation.portrait) || widget.forceFitConstraints;
    final List<Widget> children = [];

    if (widget.pageHeaderBuilder != null) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: widget.pageHeaderBuilder!(context, widget.pageIndex),
        ),
      );
    }

    int flexCount = 0;
    final List<Widget> flexChildren = [];

    if (widget.page.ayahs.isNotEmpty) {
      final int firstSurah = widget.page.ayahs[0].surahNumber;
      flexChildren.add(_buildSurahHeaderWidget(context, firstSurah, shouldFit));
      flexCount++;

      if (widget.pageIndex == 2) {
        flexChildren.add(_buildBasmallahWidget(context, firstSurah, shouldFit));
        flexCount++;
      }
    }

    for (int i = 0; i < widget.page.lines.length; i++) {
      final line = widget.page.lines[i];
      final bool isCentered = line.ayahs.isNotEmpty && line.ayahs.last.centered;
      final BoxFit fit =
          isCentered
              ? BoxFit.scaleDown
              : (shouldFit ? BoxFit.contain : BoxFit.fitWidth);

      final lineKey = _lineKeys.putIfAbsent(i, () => GlobalKey());
      final lineWidget = _buildQuranLine(
        line,
        availableSize,
        fit,
        i,
        shouldFit,
        isCentered: isCentered,
      );

      final wrappedLine = KeyedSubtree(key: lineKey, child: lineWidget);

      flexChildren.add(
        shouldFit
            ? Expanded(child: Center(child: wrappedLine))
            : Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: wrappedLine,
            ),
      );
      flexCount++;
    }

    if (shouldFit) {
      final int emptyFlex = (_standardLinesPerPage - flexCount).clamp(
        0,
        _standardLinesPerPage,
      );
      if (emptyFlex > 0) {
        final int topEmpty = emptyFlex ~/ 2;
        final int bottomEmpty = emptyFlex - topEmpty;
        if (topEmpty > 0) children.add(Spacer(flex: topEmpty));
        children.addAll(flexChildren);
        if (bottomEmpty > 0) children.add(Spacer(flex: bottomEmpty));
      } else {
        children.addAll(flexChildren);
      }
    } else {
      children.addAll(flexChildren);
    }

    return _wrapPageContent(
      children,
      shouldFit: shouldFit,
      horizontalPadding: 8.0,
    );
  }

  /// Constructs the layout for standard Quran pages (Pages 3–604).
  Widget _buildStandardPage(
    BuildContext context,
    Size availableSize,
    Orientation orientation,
  ) {
    final bool shouldFit =
        (orientation == Orientation.portrait) || widget.forceFitConstraints;
    final Set<String> newSurahs = <String>{};
    final List<Widget> children = [];

    if (widget.pageHeaderBuilder != null) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: widget.pageHeaderBuilder!(context, widget.pageIndex),
        ),
      );
    }

    for (int lineIdx = 0; lineIdx < widget.page.lines.length; lineIdx++) {
      final line = widget.page.lines[lineIdx];

      bool isFirstAyahInSurah = false;
      if (line.ayahs.isNotEmpty) {
        if (line.ayahs[0].ayahNumber == 1 &&
            !newSurahs.contains(line.ayahs[0].surahNameAr)) {
          newSurahs.add(line.ayahs[0].surahNameAr);
          isFirstAyahInSurah = true;
        }
      }

      if (isFirstAyahInSurah && line.ayahs.isNotEmpty) {
        final int surahNumber = line.ayahs[0].surahNumber;
        children.add(_buildSurahHeaderWidget(context, surahNumber, shouldFit));

        if (surahNumber != 9) {
          children.add(_buildBasmallahWidget(context, surahNumber, shouldFit));
        }
      }

      final bool isCentered = line.ayahs.isNotEmpty && line.ayahs.last.centered;
      final BoxFit fit =
          isCentered
              ? BoxFit.scaleDown
              : (shouldFit ? BoxFit.contain : BoxFit.fitWidth);

      final lineKey = _lineKeys.putIfAbsent(lineIdx, () => GlobalKey());

      Widget lineWidget = _buildQuranLine(
        line,
        availableSize,
        fit,
        lineIdx,
        shouldFit,
        isCentered: isCentered,
      );

      if (isCentered) {
        lineWidget = Center(
          child: FractionallySizedBox(widthFactor: 0.98, child: lineWidget),
        );
      } else {
        lineWidget = Center(
          child: SizedBox(width: double.infinity, child: lineWidget),
        );
      }

      lineWidget = KeyedSubtree(key: lineKey, child: lineWidget);

      children.add(
        shouldFit
            ? Expanded(child: lineWidget)
            : Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: lineWidget,
            ),
      );
    }

    if (shouldFit) {
      final int flexCount = children.whereType<Expanded>().length;
      if (flexCount > 0 && flexCount < _standardLinesPerPage) {
        children.add(Spacer(flex: _standardLinesPerPage - flexCount));
      }
    }

    return _wrapPageContent(
      children,
      shouldFit: shouldFit,
      horizontalPadding: 4.0,
    );
  }

  Widget _wrapPageContent(
    List<Widget> children, {
    required bool shouldFit,
    required double horizontalPadding,
  }) {
    final pageContent = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 4.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );

    return shouldFit
        ? pageContent
        : Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: pageContent,
          ),
        );
  }

  /// Builds an individual line of Quranic text with responsive font sizing and QCF styling.
  Widget _buildQuranLine(
    Line line,
    Size deviceSize,
    BoxFit boxFit,
    int lineIndex,
    bool shouldFit, {
    bool isCentered = false,
  }) {
    final parsedAyahs = ParsedLineCache.instance.getOrParse(
      widget.pageIndex,
      lineIndex,
      line,
      widget.lineOffsets[lineIndex],
    );

    final baseStyle =
        widget.ayahStyle ??
        QuranTextStyles.qcfStyle(
          height: 1.45,
          pageNumber: widget.pageIndex,
          isTajweed: widget.isTajweed,
          isDark: widget.isDark,
        );

    double fontSize = 45.0;

    // Scale down the font size for centered lines on smaller screens to prevent overflow.
    if (isCentered && deviceSize.width < 600) {
      fontSize = deviceSize.width * 0.055;
    }

    final TextStyle fixedStyle = baseStyle.copyWith(fontSize: fontSize);

    return QuranLine(
      parsedAyahs: parsedAyahs,
      pageNumber: widget.pageIndex,
      wordHighlightIndex: widget.wordHighlightIndex,
      bookmarkIndex: widget.bookmarkIndex,
      onWordTap: widget.onWordTap,
      boxFit: boxFit,
      onLongPress: (surahNumber, verseNumber, details) {
        _handleVerseLongPress(surahNumber, verseNumber, details);
      },
      ayahStyle: fixedStyle,
      isTajweed: widget.isTajweed,
      isDark: widget.isDark,
    );
  }
}
