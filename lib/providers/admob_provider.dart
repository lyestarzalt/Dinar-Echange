import 'package:flutter/foundation.dart';
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
      ? 'ca-app-pub-3940256099942544/6300978111' // Test Banner Ad ID for Android
      : 'ca-app-pub-3940256099942544/2934735716'; // Test Banner Ad ID for iOS

  final String interstitialAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712' // Test Interstitial Ad ID for Android
      : 'ca-app-pub-3940256099942544/4411468910'; // Test Interstitial Ad ID for iOS

  AdProvider();

  void updateScreenWidth(double newWidth) {
    _screenWidth = newWidth;
    notifyListeners();
  }

  Future<void> loadBannerAd(BuildContext context) async {
    final AdSize? adSize = await AdSize.getAnchoredAdaptiveBannerAdSize(
      Orientation.portrait,
      MediaQuery.of(context).size.width.truncate(),
    );

    if (adSize == null) {
      debugPrint('Unable to get adaptive banner ad size');
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-3940256099942544/2934735716',
      size: adSize,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _isBannerAdLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          debugPrint('InterstitialAd loaded.');
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          notifyListeners();
          _setInterstitialAdCallbacks(ad);
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  void showInterstitialAd({
    required VoidCallback onAdClosed,
    VoidCallback? onAdFailedToShow,
  }) {
    if (_isInterstitialAdLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          debugPrint('Ad dismissed fullscreen content.');
          ad.dispose();
          loadInterstitialAd(); // Optionally preload the next ad
          onAdClosed(); // Execute the callback after the ad is closed
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          debugPrint('Ad failed to show fullscreen content: $error');
          ad.dispose();
          loadInterstitialAd(); // Optionally preload the next ad
          if (onAdFailedToShow != null) {
            onAdFailedToShow(); // Execute the callback if the ad fails to show
          }
        },
      );

      _interstitialAd!.show();
      _isInterstitialAdLoaded = false; // Reset the loaded flag
    } else {
      debugPrint('Interstitial ad was not ready to be shown.');
      // Directly execute the onAdClosed callback if the ad is not ready
      // This ensures the user flow continues smoothly even without the ad
      onAdClosed();
    }
  }

  void _setInterstitialAdCallbacks(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (Ad ad) =>
          debugPrint('Ad show fullscreen content.'),
      onAdDismissedFullScreenContent: (Ad ad) {
        debugPrint('Ad dismissed fullscreen content.');
        ad.dispose();
        // Optionally load a new ad
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (Ad ad, AdError error) {
        debugPrint('Ad failed to show fullscreen content: $error');
        ad.dispose();
      },
    );
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
