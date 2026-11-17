import 'package:flutter/material.dart';
import 'package:quran_data_kit/quran_data_kit.dart';

/// Renders an ornamental Medina Mushaf Surah header banner with centered Surah name.
class SurahHeaderWidget extends StatelessWidget {
  /// The 1-based Surah number (1–114).
  final int surahNumber;

  /// General color applied to both banner linework and text.
  /// If provided, overrides [bannerColor] and [textColor].
  final Color? color;

  /// Specific color applied to the banner linework.
  final Color? bannerColor;

  /// Specific color applied to the Surah title text.
  final Color? textColor;

  /// Custom banner linework color in light mode.
  final Color? lightBannerColor;

  /// Custom banner linework color in dark mode.
  final Color? darkBannerColor;

  /// Custom text color in light mode.
  final Color? lightTextColor;

  /// Custom text color in dark mode.
  final Color? darkTextColor;

  /// Indicates whether dark mode styling is enabled.
  final bool isDark;

  /// Optional margin around the banner container.
  final EdgeInsetsGeometry? margin;

  /// Optional internal padding of the banner container.
  final EdgeInsetsGeometry? padding;

  const SurahHeaderWidget({
    super.key,
    required this.surahNumber,
    this.color,
    this.bannerColor,
    this.textColor,
    this.lightBannerColor,
    this.darkBannerColor,
    this.lightTextColor,
    this.darkTextColor,
    this.isDark = false,
    this.margin,
    this.padding,
  });

  /// Default banner linework color in light mode (Amber bronze).
  static const Color defaultLightBannerColor = Color(0xFF814E13);

  /// Default banner linework color in dark mode (Muted warm sand-bronze).
  static const Color defaultDarkBannerColor = Color(0xFFA89680);

  /// Default text color in light mode.
  static const Color defaultLightTextColor = Colors.black;

  /// Default text color in dark mode.
  static const Color defaultDarkTextColor = Colors.white;

  static const String _imagePath = 'assets/surah_banner.png';

  static const AssetImage _asset = AssetImage(
    _imagePath,
    package: 'quran_data_kit',
  );

  /// Precaches the banner image asset into the image cache.
  static Future<void> precache(BuildContext context) {
    return precacheImage(_asset, context);
  }

  Color get _effectiveTextColor =>
      textColor ??
      color ??
      (isDark
          ? (darkTextColor ?? defaultDarkTextColor)
          : (lightTextColor ?? defaultLightTextColor));

  Color? get _effectiveBannerColor =>
      bannerColor ??
      color ??
      (isDark
          ? (darkBannerColor ?? defaultDarkBannerColor)
          : (lightBannerColor ?? defaultLightBannerColor));

  @override
  Widget build(BuildContext context) {
    final double dpr = MediaQuery.of(context).devicePixelRatio;
    final Color effectiveTextColor = _effectiveTextColor;
    final Color? effectiveBannerColor = _effectiveBannerColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth =
            constraints.maxWidth.isInfinite
                ? MediaQuery.of(context).size.width
                : constraints.maxWidth;

        final double headerWidth = availableWidth;
        final double fontSize = headerWidth * 0.08;

        return RepaintBoundary(
          child: Container(
            margin: margin,
            padding: padding,
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
                  filterQuality: FilterQuality.high,
                  color: effectiveBannerColor,
                  colorBlendMode:
                      effectiveBannerColor != null ? BlendMode.srcIn : null,
                ),
                SizedBox(
                  width: headerWidth * 0.66,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: SurahTextWidget(
                      surahNumber: surahNumber,
                      fontSize: fontSize,
                      color: effectiveTextColor,
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
