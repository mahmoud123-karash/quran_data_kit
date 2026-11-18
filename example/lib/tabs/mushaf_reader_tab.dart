import 'package:material_ui/material_ui.dart';
import 'package:quran_data_kit/quran_data_kit.dart';

class MushafReaderTab extends StatefulWidget {
  final PageController pageController;
  final bool isDark;

  const MushafReaderTab({
    super.key,
    required this.pageController,
    required this.isDark,
  });

  @override
  State<MushafReaderTab> createState() => _MushafReaderTabState();
}

class _MushafReaderTabState extends State<MushafReaderTab> {
  int _currentPage = 1;
  bool _isTajweed = true;

  void _showMessage(
    String text, {
    Duration duration = const Duration(seconds: 2),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(text),
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showJumpToPageDialog() async {
    final controller = TextEditingController(text: '$_currentPage');
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Jump to Page'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Page Number (1–604)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final page = int.tryParse(controller.text.trim());
                if (page != null && page >= 1 && page <= 604) {
                  Navigator.pop(ctx, page);
                }
              },
              child: const Text('Go'),
            ),
          ],
        );
      },
    );

    if (result != null && mounted) {
      widget.pageController.jumpToPage(result - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hizbLabel = getCurrentHizbTextForPage(_currentPage, isArabic: false);

    return Column(
      children: [
        _ReaderHeaderBar(
          currentPage: _currentPage,
          hizbLabel: hizbLabel,
          isTajweed: _isTajweed,
          onTajweedChanged: (val) => setState(() => _isTajweed = val),
          onJumpToPagePressed: _showJumpToPageDialog,
        ),
        Expanded(
          child: QuranPageView(
            pageController: widget.pageController,
            isTajweed: _isTajweed,
            isDarkMode: widget.isDark,
            onPageChanged: (newPage) {
              setState(() => _currentPage = newPage);
            },
            onLongPress: (surah, verse, details, {ayahBottomY, ayahTopY}) {
              _showMessage(
                'Surah ${getSurahName(surah)} (${getSurahNameArabic(surah)}) • Ayah $verse',
              );
            },
            onWordTap: (surah, verse, wordIdx, word) {
              _showMessage(
                'Word #$wordIdx: $word (Ayah $surah:$verse)',
                duration: const Duration(milliseconds: 1200),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Status and controls bar positioned atop the Mushaf reader.
class _ReaderHeaderBar extends StatelessWidget {
  final int currentPage;
  final String hizbLabel;
  final bool isTajweed;
  final ValueChanged<bool> onTajweedChanged;
  final VoidCallback onJumpToPagePressed;

  const _ReaderHeaderBar({
    required this.currentPage,
    required this.hizbLabel,
    required this.isTajweed,
    required this.onTajweedChanged,
    required this.onJumpToPagePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: InkWell(
                onTap: onJumpToPagePressed,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Page $currentPage / 604 ($hizbLabel)',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down_rounded, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              const Text('Tajweed:'),
              const SizedBox(width: 6),
              Switch(value: isTajweed, onChanged: onTajweedChanged),
            ],
          ),
        ],
      ),
    );
  }
}
