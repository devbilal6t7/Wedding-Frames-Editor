import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wedding_frames_editor/providers/frame_category_provider.dart';
import 'package:wedding_frames_editor/providers/frames_provider.dart';
import 'package:wedding_frames_editor/screens/splash_screen.dart';
import 'package:wedding_frames_editor/widgets/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(testDeviceIds: ["DBD68B98D3BBF0EADB4DD7A5B4C2195A"]),
  );

  // MobileAds.instance.initialize();
  // WidgetsFlutterBinding.ensureInitialized();
  // MobileAds.instance.initialize();
  // MobileAds.instance.updateRequestConfiguration(
  //   RequestConfiguration(
  //     testDeviceIds: ['DBD68B98D3BBF0EADB4DD7A5B4C2195A'],
  //   ),
  // );
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

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('selectedLanguage');
    if (languageCode != null) {
      setState(() {
        _locale = Locale(languageCode);
      });
    }
  }

  void setLocale(Locale locale) async {
    setState(() {
      _locale = locale;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', locale.languageCode);
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
          Locale('en'),
          Locale('ar'),
          Locale('zh'),
          Locale('es'),
          Locale('hi'),
          Locale('ur'),
        ],
        home: const SplashScreen(),
      ),
    );
  }
}
