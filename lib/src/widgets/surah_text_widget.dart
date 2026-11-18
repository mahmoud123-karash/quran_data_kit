import 'package:material_ui/material_ui.dart';
import 'package:quran_data_kit/quran_data_kit.dart';

class SurahTextWidget extends StatelessWidget {
  const SurahTextWidget({
    super.key,
    required this.surahNumber,
    this.fontSize = 30,
    this.color,
  });
  final int surahNumber;
  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: '$surahNumber',
        style: QuranTextStyles.surahHeaderStyle(
          fontSize: fontSize,
          color: color,
        ),
      ),
    );
  }
}
