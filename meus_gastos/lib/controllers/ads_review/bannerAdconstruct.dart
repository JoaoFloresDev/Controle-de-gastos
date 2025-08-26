import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:meus_gastos/controllers/ads_review/ProManeger.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';

class BannerAdconstruct extends StatefulWidget {
  const BannerAdconstruct({super.key});

  @override
  _BannerAdconstructState createState() => _BannerAdconstructState();
}

class _BannerAdconstructState extends State<BannerAdconstruct> {
  //MARK: variables
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isPro = false;

  String getBannerAdUnitId() {
    if (Platform.isAndroid) {
      return 'ca-app-pub-8858389345934911/3074198669'; // Ad Unit ID do Android
    } else if (Platform.isIOS) {
      return 'ca-app-pub-8858389345934911/4314469007';
      // return 'ca-app-pub-3940256099942544/2934735716'; // de teste
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _checkUserProStatus();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: getBannerAdUnitId(),
      size: AdSize.fullBanner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          print("$_isAdLoaded");
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

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _checkUserProStatus() async {
    _isPro = await ProManeger().checkUserProStatus();
    setState(() {});
      return Container(
        height: 60,
        width: double.infinity,
        alignment: Alignment.center,
        child: Stack(
          children: [
            if (!_isAdLoaded)
              const Center(
                child: LoadingContainer(),
              ),
            if (_isAdLoaded)
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 60, 
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),
          ],
        ),
      );
    }else{
      return const SizedBox();
      }
  const LoadingContainer({super.key});

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
