import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:meus_gastos/controllers/ads_review/BannerAdViewModel.dart';
import 'package:meus_gastos/services/ProManeger.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:provider/provider.dart';

class BannerAdConstruct extends StatelessWidget {
  const BannerAdConstruct({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<BannerAdViewModel, ProManeger>(
      builder: (context, adViewModel, proManager, child) {
        // Se o usuário é Pro, não mostra anúncio
        print(proManager.isPro);
        if (proManager.isPro) {
          return const SizedBox();
        }

        return Container(
          height: 60,
          width: double.infinity,
          alignment: Alignment.center,
          child: Stack(
            children: [
              if (!adViewModel.isAdLoaded) Center(child: LoadingContainer()),
              if (adViewModel.isAdLoaded && adViewModel.bannerAd != null)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 60,
                    child: AdWidget(ad: adViewModel.bannerAd!),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class LoadingContainer extends StatefulWidget {
  LoadingContainer({super.key});

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
