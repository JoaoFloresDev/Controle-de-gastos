import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdconstruct extends StatefulWidget {
  @override
  _BannerAdExampleState createState() => _BannerAdExampleState();
}

class _BannerAdExampleState extends State<BannerAdconstruct> {
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;

  String getBannerAdUnitId() {
    if (Platform.isAndroid) {
      String testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
      String deverdade = 'ca-app-pub-3940256099942544/6300978111';

      return testBannerAdUnitId; // Ad Unit ID do Android
    } else if (Platform.isIOS) {
      return 'ca-app-pub-9935935099347118/3146376502'; // Ad Unit ID do iOS
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  @override
  void initState() {
    super.initState();

    _bannerAd = BannerAd(
      adUnitId: getBannerAdUnitId(),
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('Ad failed to load: $error');
          ad.dispose();
        },
      ),
    );

    _bannerAd.load();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: _isAdLoaded
            ? Container(
                width: _bannerAd.size.width.toDouble(),
                height: _bannerAd.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd),
              )
            : Container(
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
              width: double.maxFinite,
              height: 50,
              child: Text('Ad is loading...', style: TextStyle(color: Colors.grey, fontSize: 20),)),
      ),
    );
  }
}
