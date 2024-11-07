import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wedding_frames_editor/screens/home_screen.dart';

import '../consts/app_colors.dart';
import '../main.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LanguageSelectionScreenState();
  }
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  Future<void> _loadSelectedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('selectedLanguage');
    if (languageCode != null) {
      setState(() {
        _selectedLanguage = languageCode;
      });
      // Set the locale to the saved language
      MyApp.setLocale(context, Locale(languageCode));
    }
  }

  Future<void> _saveSelectedLanguage(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', languageCode);
    setState(() {
      _selectedLanguage = languageCode;
    });
    // Immediately set the locale for the app
    MyApp.setLocale(context, Locale(languageCode));
  }

  void _onContinuePressed() {
    if (_selectedLanguage != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a language')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: WeddingColors.mainColor,
        title: const Text(
          'Select Language',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              'Select Language',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: WeddingColors.mainColor),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildLanguageButton('Arabic', 'ar'),
                  _buildLanguageButton('Chinese', 'zh'),
                  _buildLanguageButton('English', 'en'),
                  _buildLanguageButton('Hindi', 'hi'),
                  _buildLanguageButton('Spanish', 'es'),
                  _buildLanguageButton('Urdu', 'ur'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectedLanguage == null ? null : _onContinuePressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: WeddingColors.mainColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageButton(String languageName, String languageCode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          _saveSelectedLanguage(languageCode);
        },
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: _selectedLanguage == languageCode ? WeddingColors.mainColor.withOpacity(0.1) : Colors.white,
            border: Border.all(color: WeddingColors.mainColor, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              languageName,
              style: TextStyle(
                fontSize: 18,
                color: WeddingColors.mainColor,
                fontWeight: _selectedLanguage == languageCode ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
