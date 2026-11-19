import 'package:material_ui/material_ui.dart';
import 'package:quran_data_kit/quran_data_kit.dart';

import 'quran_page/highlight_index.dart';
import 'quran_page/quran_repository.dart';

/// Renders the Holy Quran in either a standard single-page view or an automatic
/// dual-page side-by-side view on wide screens (tablets, foldables, and desktops).
///
/// Features include:
/// - Smooth page swiping with synchronized single/two-page navigation.
/// - Bidirectional font preloading for neighboring pages.
/// - Tajweed color-coded text rendering with scalable QCF glyphs.
/// - Interactive word-tap and verse-longpress callbacks.
/// - Bookmark and recitation word highlighting with fast memoized indexing.
/// - Customizable Surah headers, Basmallah, and page headers.
class QuranPageView extends StatefulWidget {
  /// Default screen width threshold in logical pixels above which dual-page layout is activated.
  static const double defaultTwoPageBreakpoint = 750.0;

  /// Controls the active page index for single-page reading (0-based, where 0 = Page 1).
  final PageController pageController;

  /// Callback fired when the user navigates to a new page (receives 1-based page number).
  final void Function(int pageNumber)? onPageChanged;

  /// Verses to be highlighted (e.g. bookmarks or reading markers). Defaults to empty list.
  final List<HighlightVerse> highlights;

  /// Specific words to be highlighted (e.g. during audio recitation). Defaults to empty list.
  final List<WordHighlight> wordHighlights;

  /// Callback invoked when a specific word is tapped.
  final void Function(
    int surahNumber,
    int verseNumber,
    int wordIndex,
    String word,
  )?
  onWordTap;

  /// Callback invoked when a verse is long-pressed.
  final void Function(
    int surahNumber,
    int verseNumber,
    LongPressStartDetails details, {
    double? ayahBottomY,
    double? ayahTopY,
  })?
  onLongPress;

  /// Optional bar displayed above the Quran page content within the reader area.
  final Widget? topBar;

  /// Optional bar displayed below the Quran page content within the reader area.
  final Widget? bottomBar;

  /// Total number of pages in the Quran edition (defaults to 604).
  final int quranPagesCount;

  /// Custom builder for Surah header graphics or text.
  final Widget Function(BuildContext context, int surahNumber)?
  surahHeaderBuilder;

  /// Custom builder for the Basmallah graphic or text.
  final Widget Function(BuildContext context, int surahNumber)?
  basmallahBuilder;

  /// Custom builder for the page header (e.g. displaying Juz name or page number).
  final Widget Function(BuildContext context, int pageIndex)? pageHeaderBuilder;

  /// Custom builder for the page footer (e.g. displaying page number or Juz name).
  final Widget Function(BuildContext context, int pageIndex)? pageFooterBuilder;

  /// Custom builder for Ayah number medallions.
  final Widget Function(BuildContext context, int surahNumber, int ayahNumber)?
  ayahNumberBuilder;

  /// General color applied to the Surah header banner and text.
  final Color? surahHeaderColor;

  /// Custom color applied to the Surah header banner in light mode.
  final Color? surahHeaderLightColor;

  /// Custom color applied to the Surah header banner in dark mode.
  final Color? surahHeaderDarkColor;

  /// Custom color applied to the Surah title text inside the banner.
  final Color? surahHeaderTextColor;

  /// Bottom padding placed after the Surah header before the Basmallah.
  final double? surahHeaderBottomPadding;

  /// Color applied to the Basmallah text.
  final Color? basmallahColor;

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

  /// Indicates whether dark mode styling is enabled.
  final bool isDarkMode;

  /// Custom text style applied to the Quranic text.
  final TextStyle? ayahStyle;

  /// Background color of the reader viewport. Defaults to [Colors.transparent].
  final Color? pageBackgroundColor;

  /// Enables or disables Tajweed color-coded rendering. Defaults to `true`.
  final bool isTajweed;

  /// Toggles automatic side-by-side dual-page layout on screens wider than [twoPageBreakpoint]. Defaults to `true`.
  final bool enableTwoPageLayout;

  /// Screen width threshold (in logical pixels) for dual-page layout. Defaults to [defaultTwoPageBreakpoint].
  final double twoPageBreakpoint;

  /// Optional custom builder displayed when a page font fails to load.
  final Widget Function(int? pageIndex, VoidCallback? onRetry)? errorBuilder;

  /// Optional custom widget displayed while a page font is downloading or loading.
  final Widget? loadingBuilder;

  const QuranPageView({
    super.key,
    required this.pageController,
    this.onPageChanged,
    this.highlights = const [],
    this.wordHighlights = const [],
    this.onWordTap,
    this.onLongPress,
    this.quranPagesCount = 604,
    this.topBar,
    this.bottomBar,
    this.surahHeaderBuilder,
    this.basmallahBuilder,
    this.pageHeaderBuilder,
    this.pageFooterBuilder,
    this.ayahNumberBuilder,
    this.surahHeaderColor,
    this.surahHeaderLightColor,
    this.surahHeaderDarkColor,
    this.surahHeaderTextColor,
    this.surahHeaderBottomPadding,
    this.basmallahColor,
    this.ayahSymbolColor,
    this.ayahSymbolLightColor,
    this.ayahSymbolDarkColor,
    this.ayahSymbolVerticalOffset,
    this.ayahSymbolPadding,
    this.ayahStyle,
    this.pageBackgroundColor,
    this.isTajweed = true,
    required this.isDarkMode,
    this.enableTwoPageLayout = true,
    this.twoPageBreakpoint = defaultTwoPageBreakpoint,
    this.errorBuilder,
    this.loadingBuilder,
  });

  @override
  State<QuranPageView> createState() => _QuranPageViewState();
}

class _QuranPageViewState extends State<QuranPageView> {
  bool _dataReady = false;

  final MemoizedWordHighlightIndex _wordHighlightIndexer =
      MemoizedWordHighlightIndex();
  final MemoizedBookmarkIndex _bookmarkIndexer = MemoizedBookmarkIndex();

  late WordHighlightIndex _wordHighlightIndex;
  late BookmarkIndex _bookmarkIndex;

  late PageController _twoPageController;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();

    _dataReady = QuranRepository.instance.isReady;

    final int initialPage = widget.pageController.initialPage;
    _twoPageController = PageController(initialPage: initialPage ~/ 2);

    widget.pageController.addListener(_syncExternalToInternal);
    _twoPageController.addListener(_syncInternalToExternal);

    _wordHighlightIndex = _wordHighlightIndexer.refresh(widget.wordHighlights);
    _bookmarkIndex = _bookmarkIndexer.refresh(widget.highlights);

    if (_dataReady) {
      _preloadFonts(initialPage);
    } else {
      QuranRepository.instance.ensureLoaded(widget.quranPagesCount).then((_) {
        if (!mounted) return;
        setState(() => _dataReady = true);
        _preloadFonts(initialPage);
      });
    }
  }

  @override
  void didUpdateWidget(covariant QuranPageView oldWidget) {
    super.didUpdateWidget(oldWidget);

    _wordHighlightIndex = _wordHighlightIndexer.refresh(widget.wordHighlights);
    _bookmarkIndex = _bookmarkIndexer.refresh(widget.highlights);

    if (oldWidget.pageController != widget.pageController) {
      oldWidget.pageController.removeListener(_syncExternalToInternal);
      widget.pageController.addListener(_syncExternalToInternal);
    }

    if (oldWidget.enableTwoPageLayout != widget.enableTwoPageLayout) {
      final int currentPage =
          widget.pageController.hasClients
              ? widget.pageController.page?.round() ??
                  widget.pageController.initialPage
              : widget.pageController.initialPage;

      if (widget.enableTwoPageLayout && _twoPageController.hasClients) {
        final int targetPair = currentPage ~/ 2;
        if (_twoPageController.page?.round() != targetPair) {
          _twoPageController.jumpToPage(targetPair);
        }
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.pageController.removeListener(_syncExternalToInternal);
    _twoPageController.removeListener(_syncInternalToExternal);
    _twoPageController.dispose();
    super.dispose();
  }

  /// Synchronizes the single-page controller's position into the dual-page controller.
  void _syncExternalToInternal() {
    if (_isSyncing ||
        !widget.pageController.hasClients ||
        !_twoPageController.hasClients) {
      return;
    }
    _isSyncing = true;
    final int singlePage =
        widget.pageController.page?.round() ??
        widget.pageController.initialPage;
    final int targetPair = singlePage ~/ 2;
    if (_twoPageController.page?.round() != targetPair) {
      _twoPageController.jumpToPage(targetPair);
    }
    _isSyncing = false;
  }

  /// Synchronizes the dual-page controller's position back into the single-page controller.
  void _syncInternalToExternal() {
    if (_isSyncing ||
        !widget.pageController.hasClients ||
        !_twoPageController.hasClients) {
      return;
    }
    _isSyncing = true;
    final int pairPage =
        _twoPageController.page?.round() ?? _twoPageController.initialPage;
    final int targetSingle = pairPage * 2;
    if (widget.pageController.page?.round() != targetSingle) {
      widget.pageController.jumpToPage(targetSingle);
    }
    _isSyncing = false;
  }

  /// Initiates font prefetching for neighboring pages.
  void _preloadFonts(int pageIndex, {int radius = 3}) {
    QdkFontLoader.preloadPages(
      pageIndex + 1,
      radius: radius,
    ).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_dataReady) {
      return const Center(child: CircularProgressIndicator());
    }

    final ScrollPhysics physics =
        Theme.of(context).platform == TargetPlatform.iOS
            ? const BouncingScrollPhysics()
            : const ClampingScrollPhysics();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWideScreen =
              constraints.maxWidth >= widget.twoPageBreakpoint;
          final bool useTwoPageMode =
              widget.enableTwoPageLayout && isWideScreen;

          return Container(
            color: widget.pageBackgroundColor ?? Colors.transparent,
            child: IndexedStack(
              index: useTwoPageMode ? 0 : 1,
              children: [
                _buildTwoPageLayout(
                  key: const ValueKey('two_page_view'),
                  physics: physics,
                ),
                _buildSinglePageLayout(
                  key: const ValueKey('single_page_view'),
                  physics: physics,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Builds the standard single-page [PageView].
  Widget _buildSinglePageLayout({
    required Key key,
    required ScrollPhysics physics,
  }) {
    final List<QuranPage> pages = QuranRepository.instance.pages;
    final wordOffsets = QuranRepository.instance.wordOffsets;

    return PageView.builder(
      key: key,
      controller: widget.pageController,
      physics: physics,
      itemCount: pages.length,
      onPageChanged: (index) {
        final int pageNum = index + 1;
        widget.onPageChanged?.call(pageNum);
        _preloadFonts(index, radius: 3);
      },
      itemBuilder: (context, index) {
        return Column(
          children: [
            if (widget.topBar != null) widget.topBar!,
            Expanded(
              child: _buildPageItem(
                index: index,
                pages: pages,
                wordOffsets: wordOffsets,
                isTwoPageMode: false,
              ),
            ),
            if (widget.bottomBar != null) widget.bottomBar!,
          ],
        );
      },
    );
  }

  /// Builds the dual-page side-by-side [PageView] for tablets and desktops.
  Widget _buildTwoPageLayout({
    required Key key,
    required ScrollPhysics physics,
  }) {
    final List<QuranPage> pages = QuranRepository.instance.pages;
    final wordOffsets = QuranRepository.instance.wordOffsets;
    final int pairCount = (pages.length / 2).ceil();

    return PageView.builder(
      key: key,
      controller: _twoPageController,
      physics: physics,
      itemCount: pairCount,
      onPageChanged: (index) {
        final int rightPageNum = (index * 2) + 1;
        widget.onPageChanged?.call(rightPageNum);
        _preloadFonts(index * 2, radius: 4);
      },
      itemBuilder: (context, index) {
        final int rightPageIndex = index * 2;
        final int leftPageIndex = index * 2 + 1;

        return Column(
          children: [
            if (widget.topBar != null) widget.topBar!,
            Expanded(
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Expanded(
                    child:
                        rightPageIndex < pages.length
                            ? _buildPageItem(
                              index: rightPageIndex,
                              pages: pages,
                              wordOffsets: wordOffsets,
                              isTwoPageMode: true,
                            )
                            : const SizedBox.shrink(),
                  ),
                  const _TwoPageSpineDivider(),
                  Expanded(
                    child:
                        leftPageIndex < pages.length
                            ? _buildPageItem(
                              index: leftPageIndex,
                              pages: pages,
                              wordOffsets: wordOffsets,
                              isTwoPageMode: true,
                            )
                            : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            if (widget.bottomBar != null) widget.bottomBar!,
          ],
        );
      },
    );
  }

  /// Instantiates a [QuranSinglePageWidget] configured with pre-computed highlight indexes
  /// and responsive constraint options.
  Widget _buildPageItem({
    required int index,
    required List<QuranPage> pages,
    required Map<int, Map<int, Map<String, int>>> wordOffsets,
    required bool isTwoPageMode,
  }) {
    final int pageNum = index + 1;
    final String keyPrefix = isTwoPageMode ? 'two_mode' : 'single_mode';

    return QuranSinglePageWidget(
      key: ValueKey('page_${keyPrefix}_$pageNum'),
      page: pages[index],
      pageIndex: pageNum,
      wordHighlightIndex: _wordHighlightIndex,
      bookmarkIndex: _bookmarkIndex,
      onWordTap: widget.onWordTap,
      onLongPress: widget.onLongPress,
      pageController: widget.pageController,
      surahHeaderBuilder: widget.surahHeaderBuilder,
      surahHeaderColor: widget.surahHeaderColor,
      surahHeaderLightColor: widget.surahHeaderLightColor,
      surahHeaderDarkColor: widget.surahHeaderDarkColor,
      surahHeaderTextColor: widget.surahHeaderTextColor,
      surahHeaderBottomPadding: widget.surahHeaderBottomPadding,
      basmallahBuilder: widget.basmallahBuilder,
      basmallahColor: widget.basmallahColor,
      pageHeaderBuilder: widget.pageHeaderBuilder,
      pageFooterBuilder: widget.pageFooterBuilder,
      ayahNumberBuilder: widget.ayahNumberBuilder,
      ayahSymbolColor: widget.ayahSymbolColor ?? widget.surahHeaderColor,
      ayahSymbolLightColor:
          widget.ayahSymbolLightColor ?? widget.surahHeaderLightColor,
      ayahSymbolDarkColor:
          widget.ayahSymbolDarkColor ?? widget.surahHeaderDarkColor,
      ayahSymbolVerticalOffset: widget.ayahSymbolVerticalOffset,
      ayahSymbolPadding: widget.ayahSymbolPadding,
      ayahStyle: widget.ayahStyle,
      isTajweed: widget.isTajweed,
      isDark: widget.isDarkMode,
      lineOffsets: wordOffsets[index] ?? const {},
      forceFitConstraints: isTwoPageMode,
      errorBuilder: widget.errorBuilder,
      loadingBuilder: widget.loadingBuilder,
    );
  }
}

/// A subtle vertical gradient divider simulating a physical book spine between
/// the right and left pages in dual-page layout.
class _TwoPageSpineDivider extends StatelessWidget {
  const _TwoPageSpineDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.05),
            Colors.black.withValues(alpha: 0.15),
            Colors.black.withValues(alpha: 0.05),
          ],
        ),
      ),
    );
  }
}
