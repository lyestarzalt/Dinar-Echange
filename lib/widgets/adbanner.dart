import 'package:dinar_watch/providers/admob_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:provider/provider.dart';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  _AdBannerWidgetState createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _initBannerAd();
  }

  void _initBannerAd() {
    // Assuming AdProvider is accessible via Provider and it has been initialized properly.
    final adProvider = Provider.of<AdProvider>(context, listen: false);

    // You might want to adjust the ad size here or fetch it from the provider
    BannerAd(
      adUnitId: adProvider.bannerAdUnitId, // Your Ad Unit ID
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _bannerAd = ad as BannerAd?;
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint('Ad failed to load: $error');
          ad.dispose();
        },
      ),
    ).load();
  }

  @override
  Widget build(BuildContext context) {
    return _isAdLoaded ? AdWidget(ad: _bannerAd!) : SizedBox();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}
