import 'package:meus_gastos/controllers/ads_review/BannerAdConstruct.dart';
import 'package:meus_gastos/controllers/ads_review/BannerAdViewModel.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/services/ProManeger.dart';
import 'package:provider/provider.dart';

class BannerAdFactory {
  Widget build() {
    return Consumer<ProManeger>(
        builder: (context, proViewModel, child) => MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => BannerAdViewModel()),
              ],
              child: const BannerAdConstruct(),
            ));
  }
}
