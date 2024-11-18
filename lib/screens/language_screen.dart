import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wedding_frames_editor/ads/ad_units.dart';
import 'package:wedding_frames_editor/screens/home_screen.dart';

import '../../../consts/app_colors.dart';
import '../../../main.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedLanguage = 'en'; // Default to English (US)
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage(context);
    _loadBannerAd();
    _loadInterstitialAd();
  }

  Future<void> _loadSelectedLanguage(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('selectedLanguage');
    setState(() {
      _selectedLanguage = languageCode ?? 'en'; // Default to English (US)
    });
    MyApp.setLocale(context, Locale(_selectedLanguage));
  }

  Future<void> _saveSelectedLanguage(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', languageCode);
    setState(() {
      _selectedLanguage = languageCode;
    });
  }

  Future<void> _loadBannerAd() async {
    _bannerAd = BannerAd(
      adUnitId: AdUnitIds.bannerAdUnitId, // Replace with your AdMob Banner Ad Unit ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          setState(() {
            _isBannerAdLoaded = false;
          });
        },
      ),
    )..load();
  }

  Future<void> _loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: AdUnitIds.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  void _showInterstitialAd(VoidCallback onAdDismissed) {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitialAd(); // Load the next interstitial ad
          onAdDismissed();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          onAdDismissed();
        },
      );
      _interstitialAd!.show();
    } else {
      onAdDismissed();
    }
  }

  void _navigateToHomeScreen() {
    if (_selectedLanguage.isNotEmpty) {
      _showInterstitialAd(() {
        MyApp.setLocale(context, Locale(_selectedLanguage));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a language'),
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
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              _selectedLanguage.isNotEmpty
                  ? _buildSelectedLanguageTile(_selectedLanguage)
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
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
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
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
              if (_isBannerAdLoaded)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  alignment: Alignment.center,
                  child: AdWidget(ad: _bannerAd!),
                  height: _bannerAd!.size.height.toDouble(),
                  width: _bannerAd!.size.width.toDouble(),
                ),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _navigateToHomeScreen,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: WeddingColors.mainColor,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 70),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
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
          color: isSelected ? WeddingColors.mainColor : Colors.grey.shade300,
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
