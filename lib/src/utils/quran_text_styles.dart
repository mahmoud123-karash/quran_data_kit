import 'package:material_ui/material_ui.dart';

class QuranTextStyles {
  QuranTextStyles._();

  static String getQcfFontFamily({
    required int pageNumber,
    required bool isTajweed,
    required bool isDark,
  }) {
    final pageStr = pageNumber.toString().padLeft(3, '0');
    final base = 'QCF4${pageStr}_COLOR-Regular';

    if (isTajweed) {
      return isDark ? '$base-d' : base;
    }

    return isDark ? '$base-nd' : '$base-n';
  }

  static TextStyle qcfStyle({
    required int pageNumber,
    required bool isTajweed,
    required bool isDark,
    Color? color,
    double fontSize = 23.55,
    double? height,
  }) {
    final Color defaultSolidColor = isDark ? Colors.white : Colors.black;

    return TextStyle(
      fontFamily: getQcfFontFamily(
        pageNumber: pageNumber,
        isTajweed: isTajweed,
        isDark: isDark,
      ),
      color: color ?? defaultSolidColor,
      fontSize: fontSize,
      height: height,
    );
  }

  static TextStyle hafsStyle({
    Color? color,
    double fontSize = 23.55,
    double? height,
  }) {
    return TextStyle(
      fontFamily: 'hafs',
      package: 'quran_data_kit',
      color: color,
      fontSize: fontSize,
      height: height,
    );
  }

  static TextStyle surahHeaderStyle({Color? color, double fontSize = 30}) {
    return TextStyle(
      fontFamily: 'arsura',
      package: 'quran_data_kit',
      color: color ?? Colors.black,
      fontSize: fontSize,
    );
  }

  static TextStyle basmallahStyle({Color? color, double fontSize = 30}) {
    return TextStyle(
      fontFamily: 'QCF4_BSML',
      package: 'quran_data_kit',
      color: color ?? Colors.black,
      fontSize: fontSize,
    );
  }
}
