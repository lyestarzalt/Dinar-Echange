import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:dinar_watch/providers/admob_provider.dart';
import 'package:dinar_watch/utils/logging.dart'; // Ensure you have a logging utility

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  _AdBannerWidgetState createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  AdSize? _adSize;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    _loadAd(adProvider);
  }

  void _loadAd(AdProvider adProvider) async {
    final screenWidth = MediaQuery.of(context).size.width;

    // Use the getPortraitInlineAdaptiveBannerAdSize method since the app is always in portrait mode.
    final AdSize adSize =
        AdSize.getPortraitInlineAdaptiveBannerAdSize(screenWidth.truncate());

    final BannerAd bannerAd = BannerAd(
      adUnitId: adProvider.bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) async {
          AppLogger.logInfo('AdBannerWidget: Ad loaded.');
          //get the actual size of the ad from the platform since the height can vary.
          final AdSize? loadedAdSize =
              await (ad as BannerAd).getPlatformAdSize();
          if (!mounted) return;
          setState(() {
            _bannerAd = ad;
            _isAdLoaded = true;
            _adSize = loadedAdSize;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          AppLogger.logError('AdBannerWidget: Ad failed to load: $error');
          ad.dispose();
        },
      ),
    );

    bannerAd.load();
  }

  @override
  Widget build(BuildContext context) {
    return _isAdLoaded && _adSize != null
        ? Container(
            alignment: Alignment.center,
            width: _adSize!.width.toDouble(),
            height: _adSize!.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          )
        : const SizedBox();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}
