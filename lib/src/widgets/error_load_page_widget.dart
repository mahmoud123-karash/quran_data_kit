import 'package:material_ui/material_ui.dart';

class ErrorLoadPageWidget extends StatelessWidget {
  const ErrorLoadPageWidget({
    super.key,
    required this.pageIndex,
    required this.isDark,
    required this.onError,
  });
  final int pageIndex;
  final bool isDark;
  final VoidCallback onError;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline_rounded, size: 42, color: color),

          const SizedBox(height: 16),

          Text(
            'تعذر تحميل خط الصفحة (page: $pageIndex)',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),

          const SizedBox(height: 16),

          TextButton.icon(
            onPressed: onError,
            style: TextButton.styleFrom(foregroundColor: color),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
