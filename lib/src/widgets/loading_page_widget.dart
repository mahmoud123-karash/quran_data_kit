import 'package:material_ui/material_ui.dart';

class LoadingPageWidget extends StatelessWidget {
  const LoadingPageWidget({
    super.key,
    required this.pageIndex,
    required this.isDark,
  });
  final int pageIndex;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(height: 16),

          Text(
            'جاري تحميل الصفحة $pageIndex...',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
