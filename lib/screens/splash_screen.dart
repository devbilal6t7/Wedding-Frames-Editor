import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:wedding_frames_editor/screens/home_screen.dart';
import 'package:wedding_frames_editor/screens/language_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLanguageSelected = false;

  @override
  void initState() {
    super.initState();
    _checkLanguageSelection();
  }

  Future<void> _checkLanguageSelection() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('selectedLanguage');
    setState(() {
      _isLanguageSelected = languageCode != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Container(
        color: Colors.black,
        width: screenWidth,
        height: screenHeight,
        child: AnimatedSplashScreen(
          backgroundColor: Colors.black,
          splashIconSize: screenHeight,
          pageTransitionType: PageTransitionType.bottomToTop,
          duration: 3000,
          splash: Image.asset(
            'assets/images/splash.png',
            fit: BoxFit.cover,
            height: screenWidth,
            width: screenWidth,
          ),
          nextScreen: _isLanguageSelected
              ? const HomeScreen()
              : const LanguageSelectionScreen(),
        ),
      ),
    );
  }
}
