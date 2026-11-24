import 'package:material_ui/material_ui.dart';
import 'screens/example_home_screen.dart';

const Color primayColor = Color(0xFF7C4A1E);

const Color lightBackgroundColor = Color(0xFFFAF5E8);

const Color darkBackgroundColor = Color(0xFF141311);

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
          seedColor: primayColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: lightBackgroundColor,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primayColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: darkBackgroundColor,
      ),
      themeMode: _themeMode,
      home: ExampleHomeScreen(
        onToggleTheme: _toggleTheme,
        themeMode: _themeMode,
      ),
    );
  }
}
