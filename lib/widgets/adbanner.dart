import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:dinar_watch/providers/admob_provider.dart'; // Adjust the import based on your actual file structure

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({Key? key}) : super(key: key);

  @override
  _AdBannerWidgetState createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This ensures we have a context with MediaQuery available
    _initBannerAd();
  }

  void _initBannerAd() async {
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    final screenWidth = MediaQuery.of(context).size.width;

    // Get adaptive banner size
    final AdSize? adSize = await AdSize.getAnchoredAdaptiveBannerAdSize(
      Orientation.portrait,
      screenWidth.truncate(),
    );

    if (adSize == null) {
      print("Unable to get adaptive banner size");
      return;
    }

    final BannerAd bannerAd = BannerAd(
      adUnitId: adProvider.bannerAdUnitId, // Use your ad unit ID
      size: adSize,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint('Ad failed to load: $error');
          ad.dispose();
        },
      ),
    );

    bannerAd.load();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: _isAdLoaded ? AdWidget(ad: _bannerAd!) : SizedBox(),
      width: _bannerAd?.size.width.toDouble(),
      height: _bannerAd?.size.height.toDouble(),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}
