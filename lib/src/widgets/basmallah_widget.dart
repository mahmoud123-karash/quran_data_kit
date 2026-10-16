import 'package:flutter/material.dart';
import '../utils/quran_text_styles.dart';

class BasmallahWidget extends StatelessWidget {
  const BasmallahWidget(
    this.surahNumber, {
    super.key,
    this.color,
    this.fontSize,
  });
  final int surahNumber;
  final Color? color;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth =
            constraints.maxWidth.isInfinite
                ? MediaQuery.of(context).size.width
                : constraints.maxWidth;

        return RepaintBoundary(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text(
                surahNumber == 97 || surahNumber == 95 ? "齃𧻓𥳐龎" : "齃𧻓𥳐𥉉",
                textAlign: TextAlign.center,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                style: QuranTextStyles.basmallahStyle(
                  fontSize:
                      fontSize ?? (availableWidth * 0.0533).clamp(18.0, 23.0),
                  color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
