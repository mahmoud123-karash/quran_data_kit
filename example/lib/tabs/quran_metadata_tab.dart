import 'package:flutter/material.dart';
import 'package:quran_data_kit/quran_data_kit.dart';

/// Demonstrates Quran metadata, search, and random verse generator.
class QuranMetadataTab extends StatefulWidget {
  final bool isDark;
  final ValueChanged<int> onNavigateToPage;

  const QuranMetadataTab({
    super.key,
    required this.isDark,
    required this.onNavigateToPage,
  });

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        if (_randomVerse != null)
          _RandomVerseCard(
            randomVerse: _randomVerse!,
            onRefresh: _generateRandomVerse,
            onReadInMushaf: () {
              final page = getPageNumber(
                _randomVerse!.surahNumber,
                _randomVerse!.verseNumber,
              );
              widget.onNavigateToPage(page);
            },
          ),
        const SizedBox(height: 16),
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
        if (_searchResults != null) ...[
          Text(
            'Found ${_searchResults!['occurences']} matches:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...((_searchResults!['result'] as List).take(15).map((item) {
            final int surah = item['sora'] as int;
            final int ayah = item['aya_no'] as int;
            final String text = item['text'] as String;
            final int page = getPageNumber(surah, ayah);

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(text, textAlign: TextAlign.right),
                subtitle: Text(
                  'Surah ${getSurahName(surah)} (${getSurahNameArabic(surah)}) • Ayah $ayah • Page $page',
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () => widget.onNavigateToPage(page),
              ),
            );
          })),
        ],
      ],
    );
  }
}

/// Displays the Random Verse of the Day card with action to view in the Mushaf.
class _RandomVerseCard extends StatelessWidget {
  final RandomVerse randomVerse;
  final VoidCallback onRefresh;
  final VoidCallback onReadInMushaf;

  const _RandomVerseCard({
    required this.randomVerse,
    required this.onRefresh,
    required this.onReadInMushaf,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: onRefresh,
                  tooltip: 'Get another verse',
                ),
              ],
            ),
            const Divider(),
            Text(
              'Surah ${getSurahName(randomVerse.surahNumber)} : ${randomVerse.verseNumber}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              randomVerse.verse,
              textAlign: TextAlign.right,
              style: QuranTextStyles.hafsStyle(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              randomVerse.translation,
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onReadInMushaf,
                icon: const Icon(Icons.menu_book_rounded, size: 18),
                label: const Text('Read in Mushaf'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
