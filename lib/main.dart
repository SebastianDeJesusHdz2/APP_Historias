import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'models/story.dart';
// Registra tus adapters si usas Hive TypeAdapters personalizados

// Provider: ¡aquí puedes expandirlo para sincronizar con Hive!
class StoryProvider with ChangeNotifier {
  final List<Story> _stories = [];

  List<Story> get stories => _stories;

  void addStory(Story story) {
    _stories.add(story);
    notifyListeners();
    // Aquí podrías persistir en Hive
  }

  void refresh() {
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa Hive para almacenamiento local (solo si usas Hive)
  final documents = await getApplicationDocumentsDirectory();
  Hive.init(documents.path);

  // Registra adapters si los tienes (por ejemplo, Hive.registerAdapter(StoryAdapter());)
  // Hive.registerAdapter(StoryAdapter());

  runApp(
    ChangeNotifierProvider(
      create: (_) => StoryProvider(),
      child: MainThemeSwitcher(),
    ),
  );
}

class MainThemeSwitcher extends StatefulWidget {
  @override
  State<MainThemeSwitcher> createState() => _MainThemeSwitcherState();
}

class _MainThemeSwitcherState extends State<MainThemeSwitcher> {
  bool _isDark = false;

  void _toggleTheme(bool value) {
    setState(() {
      _isDark = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define tu paleta ideal aquí
    const Color azulPrincipal = Color(0xFF2874A6);
    const Color verdeAccent = Color(0xFF43C59E);
    const Color coral = Color(0xFFFF6F61);
    const Color bgClaro = Color(0xFFEDF2F7);
    const Color bgOscuro = Color(0xFF202A38);

    return MaterialApp(
      title: 'AppHistorias',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: azulPrincipal,
          secondary: verdeAccent,
          surface: Colors.white,
          background: bgClaro,
          error: coral,
        ),
        scaffoldBackgroundColor: bgClaro,
        appBarTheme: AppBarTheme(
            backgroundColor: bgClaro,
            foregroundColor: azulPrincipal,
            elevation: 1
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: azulPrincipal,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: coral,
            foregroundColor: Colors.white,
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: azulPrincipal,
          secondary: verdeAccent,
          surface: Color(0xFF252C39),
          background: bgOscuro,
          error: coral,
        ),
        scaffoldBackgroundColor: bgOscuro,
        appBarTheme: AppBarTheme(
            backgroundColor: bgOscuro,
            foregroundColor: azulPrincipal,
            elevation: 1
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: azulPrincipal,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: coral,
            foregroundColor: Colors.white,
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(
        onThemeToggle: _toggleTheme,
        isDark: _isDark,
      ),
      routes: {
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}




