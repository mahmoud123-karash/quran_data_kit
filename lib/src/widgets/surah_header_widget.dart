import 'package:flutter/material.dart';
import 'package:quran_data_kit/quran_data_kit.dart';

class SurahHeaderWidget extends StatelessWidget {
  final int surahNumber;
  final Color? color;

  const SurahHeaderWidget({super.key, required this.surahNumber, this.color});

  static const String _imagePath = 'assets/surah_banner.png';

  static const AssetImage _asset = AssetImage(
    _imagePath,
    package: 'quran_data_kit',
  );

  static Future<void> precache(BuildContext context) {
    return precacheImage(_asset, context);
  }

  @override
  Widget build(BuildContext context) {
    final double dpr = MediaQuery.of(context).devicePixelRatio;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth =
            constraints.maxWidth.isInfinite
                ? MediaQuery.of(context).size.width
                : constraints.maxWidth;

        final double headerWidth = availableWidth;
        final double fontSize = headerWidth * 0.085;

        return RepaintBoundary(
          child: Container(
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image(
                  image: ResizeImage(
                    _asset,
                    width: (headerWidth * dpr).round(),
                    allowUpscaling: false,
                  ),
                  width: headerWidth,
                  fit: BoxFit.fill,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.medium,
                ),

                SizedBox(
                  width: headerWidth * 0.65,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: SurahTextWidget(
                      surahNumber: surahNumber,
                      fontSize: fontSize,
                      color:
                          color ?? Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
