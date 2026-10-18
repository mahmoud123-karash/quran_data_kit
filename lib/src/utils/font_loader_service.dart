import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

enum FontStorageMode { permanentDisk, memoryOnly }

class QdkFontLoader {
  QdkFontLoader._();

  static final Map<int, Future<void>> _loadingTasks = {};
  static final Set<int> _loadedPages = {};

  static FontStorageMode _currentMode = FontStorageMode.permanentDisk;

  static const int totalPages = 604;

  static Directory? _fontDirCache;
  static int _generation = 0;

  /// Callback triggered whenever a page font is written/saved to disk.
  static void Function(int pageNumber)? onPageFontSaved;

  /// Returns the base family name for the given Quran page.
  static String getBaseFontFamily(int pageNumber) {
    return 'QCF4${pageNumber.toString().padLeft(3, '0')}_COLOR-Regular';
  }

  /// Returns the light tajweed variant for the specified page.
  static String getTajweedLightFamily(int pageNumber) {
    return getBaseFontFamily(pageNumber);
  }

  /// Returns the dark tajweed variant for the specified page.
  static String getTajweedDarkFamily(int pageNumber) {
    return '${getBaseFontFamily(pageNumber)}-d';
  }

  /// Returns the light no-tajweed variant for the specified page.
  static String getNoTajweedLightFamily(int pageNumber) {
    return '${getBaseFontFamily(pageNumber)}-n';
  }

  /// Returns the dark no-tajweed variant for the specified page.
  static String getNoTajweedDarkFamily(int pageNumber) {
    return '${getBaseFontFamily(pageNumber)}-nd';
  }

  /// Returns the red-highlight variant for the specified page.
  static String getRedFamily(int pageNumber) {
    return '${getBaseFontFamily(pageNumber)}-nr';
  }

  /// Loads the configured font set during startup while reporting progress.
  ///
  /// If all pages already exist in the persistent font directory, the loader reuses
  /// them instead of re-extracting and writing them again. Otherwise, it loads the
  /// entire set sequentially so the UI can observe a meaningful progress callback.
  static Future<void> setupFontsAtStartup({
    required Function(double progress) onProgress,
    FontStorageMode mode = FontStorageMode.permanentDisk,
  }) async {
    _currentMode = mode;

    Directory? fontDir;

    if (_currentMode == FontStorageMode.permanentDisk) {
      fontDir = await _getFontDirectory();
    }

    int existingFontsCount = 0;

    if (fontDir != null) {
      const probeBatch = 64;

      for (int start = 1; start <= totalPages; start += probeBatch) {
        final end = (start + probeBatch - 1).clamp(1, totalPages);

        final checks = <Future<bool>>[];

        for (int page = start; page <= end; page++) {
          final file = File('${fontDir.path}/${getBaseFontFamily(page)}.ttf');

          checks.add(() async {
            if (!await file.exists()) {
              return false;
            }
            return await file.length() > 1000;
          }());
        }

        final results = await Future.wait(checks);

        existingFontsCount += results.where((e) => e).length;
      }
    }

    if (existingFontsCount == totalPages) {
      const batchSize = 25;

      for (int start = 1; start <= totalPages; start += batchSize) {
        final end = (start + batchSize - 1).clamp(1, totalPages);

        final tasks = <Future<void>>[];

        for (int page = start; page <= end; page++) {
          tasks.add(ensureFontLoaded(page));
        }

        await Future.wait(tasks);

        onProgress(end / totalPages);
      }
    } else {
      for (int page = 1; page <= totalPages; page++) {
        await ensureFontLoaded(page);
        onProgress(page / totalPages);
      }
    }
  }

  /// Returns the directory used for cached font files.
  static Future<Directory> _getFontDirectory() async {
    final cached = _fontDirCache;

    if (cached != null) {
      return cached;
    }

    final appDir = await getApplicationDocumentsDirectory();

    final fontDir = Directory('${appDir.path}/qcf_fonts');

    if (!await fontDir.exists()) {
      await fontDir.create(recursive: true);
    }

    _fontDirCache = fontDir;

    return fontDir;
  }

  /// Ensures a Quran page font is fully loaded and registered.
  ///
  /// If the page is already loaded or a task is already in progress, the existing
  /// future is reused to avoid duplicate registration work.
  static Future<void> ensureFontLoaded(int pageNumber) {
    if (pageNumber < 1 || pageNumber > totalPages) {
      return Future.error(RangeError('Invalid Quran page: $pageNumber'));
    }

    if (_loadedPages.contains(pageNumber)) {
      return Future.value();
    }

    final existingTask = _loadingTasks[pageNumber];

    if (existingTask != null) {
      return existingTask;
    }

    final task = _loadFontInternal(pageNumber);

    _loadingTasks[pageNumber] = task;

    task
        .then((_) {
          _loadedPages.add(pageNumber);
        })
        .catchError((_) {
          // Avoid unhandled zone errors on this derived chain;
          // callers who await or catch on `task` directly will receive the error.
        })
        .whenComplete(() {
          _loadingTasks.remove(pageNumber);
        });

    return task;
  }

  /// Returns true when the requested Quran page font has already been registered.
  static bool isFontLoaded(int pageNumber) {
    return _loadedPages.contains(pageNumber);
  }

  /// Prefetches the current page and nearby pages for a smoother reading experience.
  ///
  /// The generation token guards against stale preloading calls when the user moves
  /// to another page while asynchronous loads are still running.
  static Future<void> preloadPages(int currentPage, {int radius = 5}) async {
    try {
      if (currentPage < 1) {
        currentPage = 1;
      }

      if (currentPage > totalPages) {
        currentPage = totalPages;
      }

      final myGeneration = ++_generation;

      try {
        await ensureFontLoaded(currentPage);
      } catch (_) {
        // If current page cannot load (e.g. offline), stop speculative prefetch gracefully
        return;
      }

      if (myGeneration != _generation) {
        return;
      }

      final neighbors = <int>[];

      for (int i = 1; i <= radius; i++) {
        final next = currentPage + i;
        final previous = currentPage - i;

        if (next <= totalPages) {
          neighbors.add(next);
        }

        if (previous >= 1) {
          neighbors.add(previous);
        }
      }

      for (final page in neighbors) {
        if (myGeneration != _generation) {
          return;
        }

        if (_loadedPages.contains(page) || _loadingTasks.containsKey(page)) {
          continue;
        }

        await Future<void>.delayed(Duration.zero);

        if (myGeneration != _generation) {
          return;
        }

        try {
          await ensureFontLoaded(page);
        } catch (_) {
          // Ignore prefetch failures silently
        }
      }
    } catch (_) {
      // Ignore background prefetch exceptions completely
    }
  }

  /// Loads and registers every generated variant for a single Quran page.
  static Future<void> _loadFontInternal(int pageNumber) async {
    final fontName = getBaseFontFamily(pageNumber);

    Uint8List fontBytes;

    if (_currentMode == FontStorageMode.permanentDisk) {
      final fontDir = await _getFontDirectory();
      final fontPath = '${fontDir.path}/$fontName.ttf';
      final file = File(fontPath);

      if (await file.exists() && await file.length() > 1000) {
        fontBytes = await file.readAsBytes();
      } else {
        final gzipBytes = await _loadCompressedFont(fontName);
        fontBytes = await _decompressInIsolate(gzipBytes);
        final tempFile = File('${file.path}.part');
        await tempFile.parent.create(recursive: true);
        await tempFile.writeAsBytes(fontBytes, flush: true);
        if (await file.exists()) {
          try {
            await file.delete();
          } catch (_) {}
        }
        await tempFile.rename(file.path);
        onPageFontSaved?.call(pageNumber);
      }
    } else {
      final gzipBytes = await _loadCompressedFont(fontName);
      fontBytes = await _decompressInIsolate(gzipBytes);
    }

    await _registerFont(fontBytes, getTajweedLightFamily(pageNumber));

    final darkBytes = _modifyCpalBaseColor(
      Uint8List.fromList(fontBytes),
      const Color(0xFFFFFFFF),
    );
    await _registerFont(darkBytes, getTajweedDarkFamily(pageNumber));

    final noTajweedLightBytes = _modifyCpalAllColors(
      Uint8List.fromList(fontBytes),
      const Color(0xFF000000),
    );
    await _registerFont(
      noTajweedLightBytes,
      getNoTajweedLightFamily(pageNumber),
    );

    final noTajweedDarkBytes = _modifyCpalAllColors(
      Uint8List.fromList(fontBytes),
      const Color(0xFFFFFFFF),
    );
    await _registerFont(noTajweedDarkBytes, getNoTajweedDarkFamily(pageNumber));

    final redBytes = _modifyCpalAllColors(
      Uint8List.fromList(fontBytes),
      const Color(0xFFFF0000),
    );
    await _registerFont(redBytes, getRedFamily(pageNumber));
  }

  /// Registers a font blob under the provided family name for Flutter text rendering.
  static Future<void> _registerFont(Uint8List fontBytes, String family) async {
    final loader = FontLoader(family);
    final byteData = ByteData.view(
      fontBytes.buffer,
      fontBytes.offsetInBytes,
      fontBytes.lengthInBytes,
    );
    loader.addFont(Future<ByteData>.value(byteData));
    await loader.load();
  }

  /// Base URLs where QCF Tajweed fonts are hosted with fallbacks.
  static List<String> fontCdnMirrors = [
    'https://raw.githubusercontent.com/mahmoud123-karash/quran_fonts/main/assets/fonts/qcf_tajweed',
    'https://mahmoud123-karash.github.io/quran_fonts/assets/fonts/qcf_tajweed',
    'https://raw.githubusercontent.com/hussein12347/qcf_quran_plus/main/assets/fonts/qcf_tajweed',
  ];

  static String fontCdnBaseUrl = fontCdnMirrors.first;

  /// Sets a primary custom hosted CDN base URL for fonts.
  static void setHostedCdnUrl(String url) {
    final cleanUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    fontCdnBaseUrl = cleanUrl;
    if (!fontCdnMirrors.contains(cleanUrl)) {
      fontCdnMirrors.insert(0, cleanUrl);
    }
  }

  /// Checks if a specific page font exists and is downloaded on disk.
  static Future<bool> isPageFontOnDisk(int pageNumber) async {
    try {
      final fontDir = await _getFontDirectory();
      final fontName = getBaseFontFamily(pageNumber);
      final file = File('${fontDir.path}/$fontName.ttf');
      return await file.exists() && await file.length() > 1000;
    } catch (_) {
      return false;
    }
  }

  /// Checks if all 604 Quran page fonts have been downloaded to disk.
  static Future<bool> isAllFontsDownloaded() async {
    final count = await getDownloadedPagesCount();
    return count >= totalPages;
  }

  /// Returns the number of Quran page fonts currently stored on disk.
  static Future<int> getDownloadedPagesCount() async {
    try {
      final fontDir = await _getFontDirectory();
      if (!await fontDir.exists()) return 0;
      int count = 0;
      for (int i = 1; i <= totalPages; i++) {
        final file = File('${fontDir.path}/${getBaseFontFamily(i)}.ttf');
        if (file.existsSync() && file.lengthSync() > 1000) {
          count++;
        }
      }
      return count;
    } catch (_) {
      return 0;
    }
  }

  /// Downloads all remaining Quran page fonts concurrently with progress reporting.
  static Future<void> downloadAllFonts({
    required Function(
      int downloaded,
      int total,
      double progress,
      int bytesDownloaded,
    ) onProgress,
    required Function() onComplete,
    required Function(dynamic error) onError,
    bool Function()? isCancelled,
    int concurrency = 4,
  }) async {
    HttpClient? sharedClient;
    try {
      final fontDir = await _getFontDirectory();
      final List<int> pagesToDownload = [];
      int downloadedCount = 0;
      int totalBytesDownloaded = 0;

      for (int i = 1; i <= totalPages; i++) {
        final file = File('${fontDir.path}/${getBaseFontFamily(i)}.ttf');
        if (file.existsSync() && file.lengthSync() > 1000) {
          downloadedCount++;
        } else {
          pagesToDownload.add(i);
        }
      }

      totalBytesDownloaded = downloadedCount * 128000;
      onProgress(
        downloadedCount,
        totalPages,
        downloadedCount / totalPages,
        totalBytesDownloaded,
      );

      if (pagesToDownload.isEmpty) {
        onComplete();
        return;
      }

      sharedClient = HttpClient();
      sharedClient.connectionTimeout = const Duration(seconds: 15);
      sharedClient.maxConnectionsPerHost = 10;

      int queueIndex = 0;
      final List<int> failedPages = [];

      Future<void> worker() async {
        while (true) {
          if (isCancelled?.call() == true) return;
          int page;
          {
            if (queueIndex >= pagesToDownload.length) return;
            page = pagesToDownload[queueIndex++];
          }

          final fontName = getBaseFontFamily(page);
          final fontPath = '${fontDir.path}/$fontName.ttf';
          final file = File(fontPath);

          if (!await file.exists() || await file.length() <= 1000) {
            try {
              final gzipBytes = await _downloadFontBytes(
                fontName,
                sharedClient: sharedClient,
              );
              totalBytesDownloaded += gzipBytes.length;
              final extracted = await _decompressInIsolate(gzipBytes);
              final tempFile = File('${file.path}.part');
              await tempFile.parent.create(recursive: true);
              await tempFile.writeAsBytes(extracted, flush: true);
              if (await file.exists()) {
                try {
                  await file.delete();
                } catch (_) {}
              }
              await tempFile.rename(file.path);
            } catch (e) {
              failedPages.add(page);
              continue;
            }
          }

          downloadedCount++;
          onPageFontSaved?.call(page);
          onProgress(
            downloadedCount,
            totalPages,
            downloadedCount / totalPages,
            totalBytesDownloaded,
          );
        }
      }

      final workers = List.generate(concurrency, (_) => worker());
      await Future.wait(workers);

      if (isCancelled?.call() == true) return;

      // Retry any transiently failed pages once more
      if (failedPages.isNotEmpty) {
        for (final page in failedPages) {
          if (isCancelled?.call() == true) return;
          final fontName = getBaseFontFamily(page);
          final fontPath = '${fontDir.path}/$fontName.ttf';
          final file = File(fontPath);
          try {
            final gzipBytes = await _downloadFontBytes(
              fontName,
              sharedClient: sharedClient,
              maxRetries: 4,
            );
            totalBytesDownloaded += gzipBytes.length;
            final extracted = await _decompressInIsolate(gzipBytes);
            final tempFile = File('${file.path}.part');
            await tempFile.parent.create(recursive: true);
            await tempFile.writeAsBytes(extracted, flush: true);
            if (await file.exists()) {
              try {
                await file.delete();
              } catch (_) {}
            }
            await tempFile.rename(file.path);
            downloadedCount++;
            onPageFontSaved?.call(page);
            onProgress(
              downloadedCount,
              totalPages,
              downloadedCount / totalPages,
              totalBytesDownloaded,
            );
          } catch (e) {
            onError(e);
            return;
          }
        }
      }

      onComplete();
    } catch (e) {
      onError(e);
    } finally {
      sharedClient?.close();
    }
  }

  /// Helper to fetch font bytes over HTTP from CDN with retries and mirror fallback.
  static Future<Uint8List> _downloadFontBytes(
    String fontName, {
    HttpClient? sharedClient,
    int maxRetries = 3,
  }) async {
    final client = sharedClient ?? HttpClient();
    if (sharedClient == null) {
      client.connectionTimeout = const Duration(seconds: 15);
    }

    try {
      Exception? lastException;

      for (int attempt = 0; attempt < maxRetries; attempt++) {
        final mirror = fontCdnMirrors[attempt % fontCdnMirrors.length];
        try {
          final uri = Uri.parse('$mirror/$fontName.ttf.gz');
          final request = await client.getUrl(uri);
          final response = await request.close();

          if (response.statusCode == 200) {
            final builder = BytesBuilder(copy: false);
            await for (final chunk in response) {
              builder.add(chunk);
            }
            return builder.takeBytes();
          } else {
            lastException = HttpException(
              'HTTP ${response.statusCode} from $mirror for $fontName',
            );
          }
        } catch (e) {
          lastException = Exception(e.toString());
        }

        if (attempt < maxRetries - 1) {
          await Future.delayed(Duration(milliseconds: 300 * (attempt + 1)));
        }
      }

      throw lastException ??
          HttpException(
            'Failed to download $fontName after $maxRetries attempts',
          );
    } finally {
      if (sharedClient == null) {
        client.close();
      }
    }
  }

  /// Loads a compressed font asset from disk or downloads it from the CDN.
  static Future<Uint8List> _loadCompressedFont(String fontName) async {
    // 1. Try local GZip if it exists
    final fontDir = await _getFontDirectory();
    final localGz = File('${fontDir.path}/$fontName.ttf.gz');
    if (await localGz.exists() && await localGz.length() > 500) {
      return await localGz.readAsBytes();
    }

    // 2. Fetch from CDN
    return await _downloadFontBytes(fontName);
  }

  /// Safely decompresses GZip bytes in a background isolate without capturing any outer scope.
  static Future<Uint8List> _decompressInIsolate(Uint8List gzipBytes) {
    return Isolate.run(() {
      final decompressed = const GZipDecoder().decodeBytes(gzipBytes);
      return Uint8List.fromList(decompressed);
    });
  }

  /// Replaces dark base palette entries with the provided color while preserving the
  /// rest of the font data intact.
  static Uint8List _modifyCpalBaseColor(
    Uint8List fontBytes,
    Color newBaseColor,
  ) {
    if (fontBytes.length < 12) return fontBytes;

    final bd = ByteData.view(
      fontBytes.buffer,
      fontBytes.offsetInBytes,
      fontBytes.lengthInBytes,
    );
    final numTables = bd.getUint16(4);
    int? cpalOffset;
    int? cpalLength;
    const cpalTag = 0x4350414C;

    for (int i = 0; i < numTables; i++) {
      final recordOffset = 12 + i * 16;
      if (recordOffset + 16 > fontBytes.length) break;
      final tag = bd.getUint32(recordOffset);
      if (tag == cpalTag) {
        cpalOffset = bd.getUint32(recordOffset + 8);
        cpalLength = bd.getUint32(recordOffset + 12);
        break;
      }
    }

    if (cpalOffset == null || cpalLength == null) return fontBytes;
    if (cpalOffset + cpalLength > fontBytes.length) return fontBytes;
    if (cpalOffset + 12 > fontBytes.length) return fontBytes;

    final numColorRecords = bd.getUint16(cpalOffset + 6);
    final colorRecordsArrayOffset = bd.getUint32(cpalOffset + 8);
    final absoluteOffset = cpalOffset + colorRecordsArrayOffset;

    final newR = (newBaseColor.r * 255).round();
    final newG = (newBaseColor.g * 255).round();
    final newB = (newBaseColor.b * 255).round();
    final newA = (newBaseColor.a * 255).round();

    for (int i = 0; i < numColorRecords; i++) {
      final colorOffset = absoluteOffset + i * 4;
      if (colorOffset + 4 > fontBytes.length) break;

      final b = fontBytes[colorOffset];
      final g = fontBytes[colorOffset + 1];
      final r = fontBytes[colorOffset + 2];
      final a = fontBytes[colorOffset + 3];

      if (r <= 30 && g <= 30 && b <= 30 && a >= 200) {
        fontBytes[colorOffset] = newB;
        fontBytes[colorOffset + 1] = newG;
        fontBytes[colorOffset + 2] = newR;
        fontBytes[colorOffset + 3] = newA;
      }
    }

    return fontBytes;
  }

  /// Recolors all palette entries in the font to the provided color.
  static Uint8List _modifyCpalAllColors(Uint8List fontBytes, Color color) {
    if (fontBytes.length < 12) return fontBytes;

    final bd = ByteData.view(
      fontBytes.buffer,
      fontBytes.offsetInBytes,
      fontBytes.lengthInBytes,
    );
    final numTables = bd.getUint16(4);
    int? cpalOffset;
    int? cpalLength;
    const cpalTag = 0x4350414C;

    for (int i = 0; i < numTables; i++) {
      final recordOffset = 12 + i * 16;
      if (recordOffset + 16 > fontBytes.length) break;
      final tag = bd.getUint32(recordOffset);
      if (tag == cpalTag) {
        cpalOffset = bd.getUint32(recordOffset + 8);
        cpalLength = bd.getUint32(recordOffset + 12);
        break;
      }
    }

    if (cpalOffset == null || cpalLength == null) return fontBytes;
    if (cpalOffset + cpalLength > fontBytes.length) return fontBytes;
    if (cpalOffset + 12 > fontBytes.length) return fontBytes;

    final numColorRecords = bd.getUint16(cpalOffset + 6);
    final colorRecordsArrayOffset = bd.getUint32(cpalOffset + 8);
    final absoluteOffset = cpalOffset + colorRecordsArrayOffset;

    final newR = (color.r * 255).round();
    final newG = (color.g * 255).round();
    final newB = (color.b * 255).round();
    final newA = (color.a * 255).round();

    for (int i = 0; i < numColorRecords; i++) {
      final colorOffset = absoluteOffset + i * 4;
      if (colorOffset + 4 > fontBytes.length) break;

      fontBytes[colorOffset] = newB;
      fontBytes[colorOffset + 1] = newG;
      fontBytes[colorOffset + 2] = newR;
      fontBytes[colorOffset + 3] = newA;
    }

    return fontBytes;
  }

  /// Clears the in-memory and on-disk cache for all loaded fonts.
  static Future<void> clearCache() async {
    _generation++;

    if (_currentMode == FontStorageMode.permanentDisk) {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final fontDir = Directory('${appDir.path}/qcf_fonts');

        if (await fontDir.exists()) {
          await fontDir.delete(recursive: true);
        }
      } catch (_) {}
    }

    _fontDirCache = null;
    _loadedPages.clear();
    _loadingTasks.clear();
  }
}
