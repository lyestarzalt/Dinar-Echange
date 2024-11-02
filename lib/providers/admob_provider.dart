import 'dart:async';

import 'package:dinar_echange/utils/logging.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class AdProvider with ChangeNotifier {
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isBannerAdLoaded = false;
  bool _isInterstitialAdLoaded = false;
  double? _screenWidth;
  double get screenWidth => _screenWidth ?? 0.0;

  bool get isBannerAdLoaded => _isBannerAdLoaded;
  bool get isInterstitialAdLoaded => _isInterstitialAdLoaded;
  BannerAd? get bannerAd => _bannerAd;
  bool _isAdLoaded = false;

  // Constructor
  AdProvider() {
    loadInterstitialAd();
  }

  final String bannerAdUnitId = kReleaseMode
      ? 'ca-app-pub-7264503053372654/2483013282' // Production ad unit ID
      : Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111' // Test ad unit ID for Android
          : 'ca-app-pub-3940256099942544/2934735716'; // Test ad unit ID for iOS

  final String interstitialAdUnitId = kReleaseMode
      ? 'ca-app-pub-7264503053372654/8856849944' // Production ad unit ID
      : Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712' // Test ad unit ID for Android
          : 'ca-app-pub-3940256099942544/4411468910'; // Test ad unit ID for iOS

  Future<void> loadInlineAdaptiveBannerAd(BuildContext context,
      {int maxHeight = 0}) async {
    final screenWidth = MediaQuery.of(context).size.width;

    final AdSize adSize = maxHeight > 0
        ? AdSize.getInlineAdaptiveBannerAdSize(
            screenWidth.truncate(), maxHeight)
        : AdSize.getPortraitInlineAdaptiveBannerAdSize(screenWidth.truncate());

    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _isBannerAdLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
          _isBannerAdLoaded = false;
          notifyListeners();
        },
      ),
    )..load();
  }

  void updateScreenWidth(double newWidth) {
    _screenWidth = newWidth;
    notifyListeners();
  }

  void loadInterstitialAd() {
    InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _isInterstitialAdLoaded = true;
            setInterstitialAdCallbacks(ad);
            AppLogger.logInfo('Interstitial ad loaded.');
            notifyListeners();
          },
          onAdFailedToLoad: (LoadAdError error) {
            AppLogger.logError('Interstitial ad failed to load: $error');
            _isInterstitialAdLoaded = false;
            notifyListeners();
          },
        ));
  }

  void setInterstitialAdCallbacks(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (InterstitialAd ad) {
      AppLogger.logInfo('Ad showed full screen content.');
    }, onAdImpression: (InterstitialAd ad) {
      AppLogger.logInfo('Ad impression recorded.');
    }, onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
      AppLogger.logError('Ad failed to show full screen content: $error');
      ad.dispose();
      _interstitialAd = null;
      _isInterstitialAdLoaded = false;
      notifyListeners();
    }, onAdDismissedFullScreenContent: (InterstitialAd ad) {
      AppLogger.logInfo('Ad dismissed full screen content.');
      ad.dispose();
      _interstitialAd = null;
      _isInterstitialAdLoaded = false;
      loadInterstitialAd(); // Reload ad for future use
      notifyListeners();
    }, onAdClicked: (InterstitialAd ad) {
      AppLogger.logInfo('Ad clicked.');
    });
  }

  void onAdDismissed(VoidCallback callback) {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialAdLoaded = false;
        loadInterstitialAd();
        notifyListeners();
        callback();
      }, onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialAdLoaded = false;
        loadInterstitialAd();
        notifyListeners();
        callback(); // Even if the ad fails, proceed with navigation
      });
    }
  }

  void showInterstitialAd() {
    if (_isInterstitialAdLoaded && _interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      AppLogger.logInfo('Interstitial ad not ready to be shown.');
      loadInterstitialAd(); // Ensure an ad is being loaded
    }
  }

  void disposeAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdLoaded = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }
}
