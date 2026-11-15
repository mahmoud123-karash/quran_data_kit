import 'package:flutter/material.dart';
import 'package:quran_data_kit/quran_data_kit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QuranDataKitExampleApp());
}

class QuranDataKitExampleApp extends StatefulWidget {
  const QuranDataKitExampleApp({super.key});

  @override
  State<QuranDataKitExampleApp> createState() => _QuranDataKitExampleAppState();
}

class _QuranDataKitExampleAppState extends State<QuranDataKitExampleApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quran Data Kit Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF81C784),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: ExampleHomeScreen(
        onToggleTheme: _toggleTheme,
        themeMode: _themeMode,
      ),
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    final screens = [
      MushafReaderTab(isDark: widget.themeMode == ThemeMode.dark),
      QuranMetadataTab(isDark: widget.themeMode == ThemeMode.dark),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran Data Kit'),
        actions: [
          IconButton(
            icon: Icon(
              widget.themeMode == ThemeMode.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
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

/// Demonstrates [QuranPageView] with horizontal page swiping.
class MushafReaderTab extends StatefulWidget {
  final bool isDark;

  const MushafReaderTab({super.key, required this.isDark});

  @override
  State<MushafReaderTab> createState() => _MushafReaderTabState();
}

class _MushafReaderTabState extends State<MushafReaderTab> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 1;
  bool _isTajweed = true;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hizbLabel = getCurrentHizbTextForPage(_currentPage, isArabic: false);

    return Column(
      children: [
        // Top status header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Page: $_currentPage / 604 ($hizbLabel)',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  const Text('Tajweed:'),
                  Switch(
                    value: _isTajweed,
                    onChanged: (val) => setState(() => _isTajweed = val),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Mushaf View
        Expanded(
          child: QuranPageView(
            pageController: _pageController,
            isTajweed: _isTajweed,
            isDarkMode: widget.isDark,
            onPageChanged: (newPage) {
              setState(() => _currentPage = newPage);
            },
            onLongPress: (surah, verse, details, {ayahBottomY, ayahTopY}) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Surah ${getSurahName(surah)} (${getSurahNameArabic(surah)}) - Ayah $verse',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            onWordTap: (surah, verse, wordIdx, word) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Word #$wordIdx: $word (Ayah $surah:$verse)'),
                  duration: const Duration(milliseconds: 1200),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Demonstrates Quran metadata, search, and random verse generator.
class QuranMetadataTab extends StatefulWidget {
  final bool isDark;

  const QuranMetadataTab({super.key, required this.isDark});

  @override
  State<QuranMetadataTab> createState() => _QuranMetadataTabState();
}

class _QuranMetadataTabState extends State<QuranMetadataTab> {
  final TextEditingController _searchController = TextEditingController(
    text: 'نور',
  );
  Map<String, dynamic>? _searchResults;
  RandomVerse? _randomVerse;

  @override
  void initState() {
    super.initState();
    _performSearch();
    _generateRandomVerse();
  }

  void _generateRandomVerse() {
    setState(() {
      _randomVerse = RandomVerse();
    });
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      setState(() {
        _searchResults = searchWords(query);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Random Verse Card
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '🎲 Random Verse of the Day',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded),
                      onPressed: _generateRandomVerse,
                      tooltip: 'Get another verse',
                    ),
                  ],
                ),
                const Divider(),
                if (_randomVerse != null) ...[
                  Text(
                    'Surah ${getSurahName(_randomVerse!.surahNumber)} : ${_randomVerse!.verseNumber}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _randomVerse!.verse,
                    textAlign: TextAlign.right,
                    style: QuranTextStyles.hafsStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _randomVerse!.translation,
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Search Input
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: 'Search Quranic Words (Arabic)',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.arrow_forward_rounded),
              onPressed: _performSearch,
            ),
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (_) => _performSearch(),
        ),
        const SizedBox(height: 12),

        // Search Results
        if (_searchResults != null) ...[
          Text(
            'Found ${_searchResults!['occurences']} matches:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...((_searchResults!['result'] as List).take(10).map((item) {
            final int surah = item['sora'] as int;
            final int ayah = item['aya_no'] as int;
            final String text = item['text'] as String;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(text, textAlign: TextAlign.right),
                subtitle: Text(
                  'Surah ${getSurahName(surah)} (${getSurahNameArabic(surah)}) - Ayah $ayah (Page ${getPageNumber(surah, ayah)})',
                ),
              ),
            );
          })),
        ],
      ],
    );
  }
}
