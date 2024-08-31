import 'dart:io';
import 'package:meus_gastos/designSystem/ImplDS.dart';
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
      String testBannerAdUnitId = 'ca-app-pub-8858389345934911/3074198669';

      return testBannerAdUnitId; // Ad Unit ID do Android
    } else if (Platform.isIOS) {
      return 'ca-app-pub-8858389345934911/9257029729'; // Ad Unit ID do iOS
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  @override
  void initState() {
    super.initState();

    _bannerAd = BannerAd(
      adUnitId: getBannerAdUnitId(),
      size: AdSize.fullBanner,
      request: const AdRequest(),
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
    return Center(
      child: _isAdLoaded
          ? SizedBox(
              width: _bannerAd.size.width.toDouble(),
              height: _bannerAd.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd),
            )
          : LoadingContainer(),
    );
  }
}

class LoadingContainer extends StatefulWidget {
  @override
  _LoadingContainerState createState() => _LoadingContainerState();
}

class _LoadingContainerState extends State<LoadingContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.label.withOpacity(0.1),
                  AppColors.label.withOpacity(0.3),
                  AppColors.label.withOpacity(0.1),
                ],
                stops: [
                  _animation.value,
                  _animation.value + 0.5,
                  _animation.value + 1.0
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            width: double.infinity,
            height: 50,
          );
        },
      ),
    );
  }
}
