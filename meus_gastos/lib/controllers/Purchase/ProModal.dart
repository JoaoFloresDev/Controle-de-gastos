import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';

class ProModal extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onSubscriptionPurchased;

  const ProModal({
    super.key,
    required this.isLoading,
    required this.onSubscriptionPurchased,
  });

  @override
  _ProModalState createState() => _ProModalState();
}

class _ProModalState extends State<ProModal> {
  ProductDetails? yearlyProductDetails;
  ProductDetails? monthlyProductDetails;

  final String yearlyProId = 'yearly.pro';
  final String monthlyProId = 'monthly.pro';

  bool isYearlyPro = false;
  bool isMonthlyPro = false;
  bool isLoadingPrice = true;

  Set<String> purchasedProductIds = {};
  Set<String> loadingPurchases = {};

  late InAppPurchase _inAppPurchase;
  late Stream<List<PurchaseDetails>> _subscription;

  @override
  void initState() {
    super.initState();
    _inAppPurchase = InAppPurchase.instance;
    _subscription = _inAppPurchase.purchaseStream;
    _subscription.listen(_listenToPurchaseUpdated, onDone: () {
      _subscription.drain();
    }, onError: (error) {
      // Trate erros aqui, se necessário
    });

    _fetchProductDetails();
    _restorePurchases();
    updateProStatus();
  }

  Future<void> updateProStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isYearlyPro = prefs.getBool('yearly.pro') ?? false;
      isMonthlyPro = prefs.getBool('monthly.pro') ?? false;
    });
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    bool isPurchaseUpdated = false;

    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        _deliverProduct(purchaseDetails);
        isPurchaseUpdated = true;
        if (purchaseDetails.productID == yearlyProId) {
          saveIsPremiumyearly();
        }
        if (purchaseDetails.productID == monthlyProId) {
          saveIsPremiummonthly();
        }
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        // Trate erros de compra aqui, se necessário
      }
      if (purchaseDetails.pendingCompletePurchase) {
        InAppPurchase.instance.completePurchase(purchaseDetails);
      }
    }

    if (isPurchaseUpdated) {
      widget.onSubscriptionPurchased();
    }
    setState(() {
      loadingPurchases.clear();
    });
  }

  Future<void> saveIsPremiummonthly() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('monthly.pro', true);

    setState(() {
      isMonthlyPro = true;
    });
  }

  Future<void> saveIsPremiumyearly() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('yearly.pro', true);
    setState(() {
      isYearlyPro = true;
    });
  }

  void _deliverProduct(PurchaseDetails purchase) {
    setState(() {
      purchasedProductIds.add(purchase.productID);
    });
  }

  Future<void> _fetchProductDetails() async {
    setState(() {
      isLoadingPrice = true;
    });

    final bool available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      setState(() {
        isLoadingPrice = false;
      });
      return;
    }

    final ProductDetailsResponse response = await InAppPurchase.instance
        .queryProductDetails({yearlyProId, monthlyProId});
    if (response.error != null || response.productDetails.isEmpty) {
      setState(() {
        isLoadingPrice = false;
      });
      return;
    }

    setState(() {
      yearlyProductDetails = response.productDetails
          .firstWhere((product) => product.id == yearlyProId);
      monthlyProductDetails = response.productDetails
          .firstWhere((product) => product.id == monthlyProId);
      isLoadingPrice = false;
    });
  }

  String formatPrice(double price, String currencySymbol) {
    final format = NumberFormat.currency(
      locale: currencySymbol == 'R\$' ? 'pt_BR' : Intl.defaultLocale,
      symbol: currencySymbol,
    );
    return format.format(price);
  }

  Future<void> _buySubscription(String productId) async {
    setState(() {
      loadingPurchases.add(productId);
    });

    final bool available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      setState(() {
        loadingPurchases.remove(productId);
      });
      return;
    }

    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails({productId});
    if (response.error == null && response.productDetails.isNotEmpty) {
      final productDetails = response.productDetails.first;
      final purchaseParam = PurchaseParam(productDetails: productDetails);
      InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
    } else {
      setState(() {
        loadingPurchases.remove(productId);
      });
    }
  }

  Future<void> _restorePurchases() async {
    await InAppPurchase.instance.restorePurchases();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background1,
      body: SafeArea(
        child: Column(
          children: [
            // Header com botões
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      CupertinoIcons.xmark,
                      color: AppColors.label,
                      size: 28,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.label,
                      size: 28,
                    ),
                    onPressed: () => _showMenuOptions(context),
                  ),
                ],
              ),
            ),
            // Conteúdo principal
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Título
                    Column(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.premiumVersion,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.label,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.enjoyExclusiveFeatures,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.label.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    // Features compactas
                    Column(
                      children: [
                        _buildCompactFeature(
                          icon: Icons.description_outlined,
                          title: AppLocalizations.of(context)!.exportToExcelOrPdf,
                        ),
                        const SizedBox(height: 12),
                        _buildCompactFeature(
                          icon: Icons.block_outlined,
                          title: AppLocalizations.of(context)!.removeAds,
                        ),
                        const SizedBox(height: 12),
                        _buildCompactFeature(
                          icon: Icons.cloud_outlined,
                          title: AppLocalizations.of(context)!.cloudBackup,
                        ),
                      ],
                    ),
                    // Planos
                    Column(
                      children: [
                        _buildSubscriptionCard(
                          label: AppLocalizations.of(context)!.yearlySubscription,
                          price: yearlyProductDetails != null
                              ? formatPrice(yearlyProductDetails!.rawPrice,
                                  yearlyProductDetails!.currencySymbol)
                              : AppLocalizations.of(context)!.loading,
                          onPressed: () =>
                              _buySubscription(yearlyProductDetails?.id ?? ''),
                          productId: yearlyProductDetails?.id ?? '',
                          isPopular: true,
                          savings: AppLocalizations.of(context)!.save30Percent,
                        ),
                        const SizedBox(height: 12),
                        _buildSubscriptionCard(
                          label: AppLocalizations.of(context)!.monthlySubscription,
                          price: monthlyProductDetails != null
                              ? formatPrice(monthlyProductDetails!.rawPrice,
                                  monthlyProductDetails!.currencySymbol)
                              : AppLocalizations.of(context)!.loading,
                          onPressed: () =>
                              _buySubscription(monthlyProductDetails?.id ?? ''),
                          productId: monthlyProductDetails?.id ?? '',
                          isPopular: false,
                        ),
                      ],
                    ),
                    // Restaurar compras
                    TextButton(
                      onPressed: _restorePurchases,
                      child: Text(
                        AppLocalizations.of(context)!.restorePurchases,
                        style: TextStyle(
                          color: AppColors.label.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMenuOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          actions: <Widget>[
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop();
                _launchURL(
                    'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/');
              },
              child: Text(AppLocalizations.of(context)!.termsOfUse),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop();
                _launchURL(
                    'https://drive.google.com/file/d/147xkp4cekrxhrBYZnzV-J4PzCSqkix7t/view?usp=sharing');
              },
              child: Text(AppLocalizations.of(context)!.privacyPolicy),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        );
      },
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _buildCompactFeature({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.button.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.button,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.label,
            ),
          ),
        ),
        const Icon(
          Icons.check_circle,
          color: CupertinoColors.activeGreen,
          size: 20,
        ),
      ],
    );
  }

  Widget _buildSubscriptionCard({
    required String label,
    required String price,
    required VoidCallback onPressed,
    required String productId,
    required bool isPopular,
    String? savings,
  }) {
    bool isPurchased = (productId == yearlyProId && isYearlyPro) ||
        (productId == monthlyProId && isMonthlyPro);

    bool isLoading = isLoadingPrice || loadingPurchases.contains(productId);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.label.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.label,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.label.withOpacity(0.6),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 38,
              child: ElevatedButton(
                onPressed: isPurchased ? null : onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPurchased
                      ? CupertinoColors.activeGreen
                      : AppColors.button,
                  disabledBackgroundColor: CupertinoColors.activeGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        isPurchased
                            ? AppLocalizations.of(context)!.subscribed
                            : AppLocalizations.of(context)!.subscribe,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void voidFunc() {}
}
