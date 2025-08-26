import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:meus_gastos/controllers/ads_review/ProManeger.dart';

class InterstitialAdManager {
  InterstitialAd? _interstitialAd;

  ProManeger proMenager = ProManeger();

  /// Carrega um anúncio intersticial.
  void loadAd() {
    InterstitialAd.load(
      adUnitId:
          'ca-app-pub-8858389345934911/7708699743', // Substitua pelo seu ID de anúncio ou use o de teste.
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          debugPrint('Anúncio intersticial carregado com sucesso.');
        },
        onAdFailedToLoad: (error) {
          debugPrint(
              'Falha ao carregar anúncio intersticial: ${error.message}');
        },
      ),
    );
  }

  Future<void> showVideoAd(BuildContext context) async {
    bool isPro = await proMenager.checkUserProStatus();
    if (!isPro) {
      if (_interstitialAd != null) {
        _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (ad) {
            debugPrint('Anúncio intersticial exibido.');
          },
          onAdDismissedFullScreenContent: (ad) {
            debugPrint('Anúncio intersticial fechado.');
            ad.dispose();
            loadAd();
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            debugPrint('Falha ao exibir anúncio intersticial: $error');
            ad.dispose();
          },
        );

        _interstitialAd!.show();
        _interstitialAd =
            null; // Limpa o anúncio atual para evitar reutilização.
      } else {
        debugPrint('Anúncio intersticial ainda não está pronto.');
        _showFallbackMessage(context);
      }
    }
  }

  /// Exibe uma mensagem de fallback se o anúncio não estiver pronto.
  void _showFallbackMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('O anúncio ainda não está pronto.')),
    );
  }

  /// Libera os recursos associados ao anúncio intersticial.
  void dispose() {
    _interstitialAd?.dispose();
  }
}
