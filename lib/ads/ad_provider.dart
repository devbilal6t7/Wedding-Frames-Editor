import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_units.dart';


class AdProvider{
  static AdProvider? _instance;
  static AdProvider get instance {
    _instance ??= AdProvider._();
    return _instance!;
  }

  AdProvider._();
  InterstitialAd? interstitialAds;
  BannerAd? _bannerAd;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  loadBanner(int screenWidth,int bannerHeight){
    _bannerAd = BannerAd(
      adUnitId: AdUnitIds.bannerAdUnitId,
      size: AdSize(width: screenWidth, height: bannerHeight), // Full screen width, height of 100
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
         _isLoading = true;
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('BannerAd failed to load: $error');
        },
      ),
    )..load();
  }


  Future<void> loadInterstitialAd(BuildContext context) async {
    _isLoading = true;

    await InterstitialAd.load(
      adUnitId: AdUnitIds.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {

            },
          );

          interstitialAds = ad;
          _isLoading = false; // Hide loading indicator

          print('Success to load an interstitial ad');
        },
        onAdFailedToLoad: (err) {
          _isLoading = false; // Hide loading indicator on failure

          print('Failed to load an interstitial ad: ${err.message}');
        },
      ),
    );
  }

  Future<void> loadagain(BuildContext context) async {
    await loadInterstitialAd(context);
  }

  Future<void> showInterstitialAd(BuildContext context, Route<dynamic> nextRoute) async {
    ClickCounter.resetClickCount();
    interstitialAds?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        Navigator.push(context, nextRoute);
        loadagain(context);
      },

    );

    if (interstitialAds != null) {
      await interstitialAds?.show();

    } else {
      Navigator.push(context, nextRoute);
    }
  }

  Future<void> showInterstitialAdReplacement(BuildContext context, Route<dynamic> nextRoute) async {
    ClickCounter.resetClickCount();
    interstitialAds?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        Navigator.pushReplacement(context, nextRoute);
        loadagain(context);
      },
    );

    if (interstitialAds != null) {
      await interstitialAds?.show();

    } else {
      Navigator.pushReplacement(context, nextRoute);
    }
  }
  Future<void> justshowInterstitialAd(BuildContext context, VoidCallback onAdDismissed) async {


    interstitialAds?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        print("Interstitial ad dismissed"); // Debug log
        onAdDismissed();
        loadagain(context);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print("Failed to show interstitial ad: $error"); // Debug log
        ad.dispose();
        onAdDismissed();
      },
    );

    if (interstitialAds != null) {
      print("Showing interstitial ad"); // Debug log
      await interstitialAds?.show();
    } else {
      print("Interstitial ad not loaded, invoking onAdDismissed"); // Debug log
      onAdDismissed();
    }
  }
  Future<void> showInterstitialAdAtPopof(BuildContext context) async {



    ClickCounter.resetClickCount();

    interstitialAds?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {

        Navigator.pop(context, true);
        loadagain(context);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        Navigator.pop(context, true);
        loadagain(context);

      },
    );

    if (interstitialAds != null) {
      await interstitialAds?.show();
    } else {
      Navigator.pop(context, true);
    }
  }
  Widget getBannerAdWidget() {
    if (isLoading && _bannerAd != null) {
      return Container(
        alignment: Alignment.center,
        height: _bannerAd!.size.height.toDouble(),
        width: _bannerAd!.size.width.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    } else {
      return Container();
    }
  }



}

class ClickCounter {
  static int _clickCount = 0;

  static int get clickCount => _clickCount;

  static void incrementClick() {
    _clickCount++;
  }

  static void resetClickCount() {
    _clickCount = 1;
  }
}
