import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wedding_frames_editor/screens/home_screen.dart';

import '../../../consts/app_colors.dart';
import '../../../main.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage(context);
  }

  Future<void> _loadSelectedLanguage(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('selectedLanguage');
    if (languageCode != null) {
      setState(() {
        _selectedLanguage = languageCode;
      });
      MyApp.setLocale(context, Locale(languageCode));
    }
  }

  Future<void> _saveSelectedLanguage(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', languageCode);
    setState(() {
      _selectedLanguage = languageCode;
    });
  }

  void _navigateToHomeScreen() {
    if (_selectedLanguage != null) {
      MyApp.setLocale(context, Locale(_selectedLanguage!));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a language'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selected Language',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              _selectedLanguage != null
                  ? _buildSelectedLanguageTile(_selectedLanguage!)
                  : Container(
                decoration: BoxDecoration(
                  color: WeddingColors.mainColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: WeddingColors.mainColor),
                ),
                child: const ListTile(
                  title: Text(
                    'Please Select Language',
                    style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600,color: Colors.white,
                    ),
                  ),
                  // trailing: Icon(Icons.check_circle, color: AppColors().white),
                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.flag,
                      size: 24,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'All Languages',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 10),
                  children: [
                    _buildLanguageTile('Arabic', 'ar'),
                    _buildLanguageTile('Chinese', 'zh'),
                    _buildLanguageTile('English (US)', 'en'),
                    _buildLanguageTile('Hindi', 'hi'),
                    _buildLanguageTile('Spanish', 'es'),
                    _buildLanguageTile('Urdu', 'ur'),
                  ],
                ),
              ),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _navigateToHomeScreen,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor:WeddingColors.mainColor,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 70),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedLanguageTile(String languageCode) {
    String languageName = _getLanguageName(languageCode);
    return Container(
      decoration: BoxDecoration(
        color: WeddingColors.mainColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WeddingColors.mainColor),
      ),
      child: ListTile(

        title: Text(
          languageName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: Colors.white),
        ),
        trailing: const Icon(Icons.check_circle, color: Colors.white),
        leading: const CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(
            Icons.flag,
           size: 24,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageTile(String languageName, String languageCode) {
    bool isSelected = _selectedLanguage == languageCode;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ?WeddingColors.mainColor : Colors.grey.shade300,
        ),
      ),
      child: ListTile(
        title: Text(
          languageName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        leading: CircleAvatar(
          backgroundColor: isSelected
              ? WeddingColors.mainColor
              : WeddingColors.mainColor.withOpacity(0.7),
          child: const Icon(
           Icons.flag,
           size: 24,
            color: Colors.white,
          ),
        ),
        trailing: Icon(
          isSelected
              ? Icons.radio_button_checked
              : Icons.radio_button_unchecked,
          color: isSelected ? WeddingColors.mainColor : Colors.grey.shade600,
        ),
        onTap: () {
          _saveSelectedLanguage(languageCode);
        },
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English (US)';
      case 'es':
        return 'Spanish';
      case 'hi':
        return 'Hindi';
      case 'ur':
        return 'Urdu';
      case 'zh':
        return 'Chinese';
      case 'ar':
        return 'Arabic';
      default:
        return 'English';
    }
  }

}
