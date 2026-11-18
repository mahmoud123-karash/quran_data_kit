import 'package:material_ui/material_ui.dart';
import '../tabs/mushaf_reader_tab.dart';
import '../tabs/quran_metadata_tab.dart';

class ExampleHomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  const ExampleHomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
  });

  @override
  State<ExampleHomeScreen> createState() => _ExampleHomeScreenState();
}

class _ExampleHomeScreenState extends State<ExampleHomeScreen> {
  int _selectedIndex = 0;
  final PageController _mushafPageController = PageController(initialPage: 0);

  @override
  void dispose() {
    _mushafPageController.dispose();
    super.dispose();
  }

  void _navigateToMushafPage(int pageNumber) {
    setState(() => _selectedIndex = 0);
    final int pageIndex = (pageNumber - 1).clamp(0, 603);
    if (_mushafPageController.hasClients) {
      _mushafPageController.jumpToPage(pageIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.themeMode == ThemeMode.dark;

    final screens = [
      MushafReaderTab(pageController: _mushafPageController, isDark: isDark),
      QuranMetadataTab(isDark: isDark, onNavigateToPage: _navigateToMushafPage),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran Data Kit'),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            tooltip: 'Toggle Theme',
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_rounded),
            label: 'Mushaf Reader',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_rounded),
            label: 'Metadata & Search',
          ),
        ],
      ),
    );
  }
}
