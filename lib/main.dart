import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wedding_frames_editor/providers/frame_category_provider.dart';
import 'package:wedding_frames_editor/providers/frames_provider.dart';
import 'package:wedding_frames_editor/screens/home_screen.dart';
import 'package:wedding_frames_editor/screens/language_screen.dart';
import 'package:wedding_frames_editor/widgets/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  bool _isLanguageSelected = false;

  @override
  void initState() {
    super.initState();
    _checkLanguageSelection();
  }

  Future<void> _checkLanguageSelection() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('selectedLanguage');
    if (languageCode != null) {
      setState(() {
        _locale = Locale(languageCode);
        _isLanguageSelected = true;
      });
    }
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => FramesProvider()),

      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: _locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ar'),  Locale('zh'), Locale('en'), Locale('es'), Locale('hi'), Locale('ur')
        ],
        home: _isLanguageSelected ? const HomeScreen() : const LanguageSelectionScreen(),
      ),
    );
  }
}
