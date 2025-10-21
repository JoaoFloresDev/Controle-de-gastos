import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdViewModel extends ChangeNotifier {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  bool get isAdLoaded => _isAdLoaded;
  BannerAd? get bannerAd => _bannerAd;

  BannerAdViewModel() {
    _loadBannerAd();
  }

  String _getBannerAdUnitId() {
    if (Platform.isAndroid) {
      return 'ca-app-pub-8858389345934911/3074198669';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-8858389345934911/4314469007';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _getBannerAdUnitId(),
      size: AdSize.fullBanner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _isAdLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Ad failed to load: $error');
          ad.dispose();
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}