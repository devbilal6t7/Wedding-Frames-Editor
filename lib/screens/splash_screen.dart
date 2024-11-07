import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:wedding_frames_editor/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return  SafeArea(
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
          nextScreen: const HomeScreen(),
        ),
      ),

    );
  }
}
