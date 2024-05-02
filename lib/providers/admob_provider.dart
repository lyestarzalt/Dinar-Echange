import 'dart:async';

import 'package:dinar_echange/utils/logging.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io' show Platform;

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

  final String bannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  final String interstitialAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

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

//
  void loadInterstitialAd() {
if (_isInterstitialAdLoaded || _interstitialAd != null) {
      AppLogger.logInfo(
          'Attempted to load ad again but one is already loaded or loading.');
      return; 
    }



    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          AppLogger.logInfo('InterstitialAd loaded.');
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (LoadAdError error) {
          AppLogger.logError('InterstitialAd failed to load: $error');
          _isInterstitialAdLoaded = false;
          notifyListeners();
        },
      ),
    );
  }

  void ensureAdIsReadyToShow({
    required VoidCallback onReadyToShow,
    VoidCallback? onFailToShow,
  }) {
    AppLogger.logDebug('message');
    if (_isInterstitialAdLoaded && _interstitialAd != null) {
      _showInterstitialAd(
        onAdClosed: onReadyToShow,
        onAdFailedToShow: onFailToShow,
      );
    } else {
   
      loadInterstitialAd();
      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_isInterstitialAdLoaded && _interstitialAd != null) {
          timer.cancel();
          _showInterstitialAd(
            onAdClosed: onReadyToShow,
            onAdFailedToShow: onFailToShow,
          );
        }
      });
    }
  }

  void prepareAndShowInterstitialAd({
    required VoidCallback onAdClosed,
    VoidCallback? onAdFailedToShow,
  }) {
    AppLogger.logInfo(
        'Preparing to show ad. Ad loaded: $_isInterstitialAdLoaded');
    if (_isInterstitialAdLoaded && _interstitialAd != null) {
      AppLogger.logInfo('Ad is loaded, showing now...');
      _showInterstitialAd(
          onAdClosed: onAdClosed, onAdFailedToShow: onAdFailedToShow);
    } else {
      AppLogger.logInfo('Ad not loaded, loading now...');
      loadInterstitialAd();
    }
  }

void _showInterstitialAd({
    required VoidCallback onAdClosed,
    VoidCallback? onAdFailedToShow,
  }) {
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        AppLogger.logInfo('Ad dismissed full screen content.');
        onAdClosed();
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialAdLoaded = false;
        loadInterstitialAd(); 
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        AppLogger.logError('Ad failed to show full screen content: $error');
        onAdFailedToShow?.call();
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialAdLoaded = false;
        loadInterstitialAd(); // Manage loading logic based on your strategy
      },
    );

    _interstitialAd!.show();
    _isInterstitialAdLoaded =
        false; // Update state to reflect that the ad is being shown
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
