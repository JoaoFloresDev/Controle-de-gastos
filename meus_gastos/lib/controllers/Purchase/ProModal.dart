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
                    // Header compacto
                    Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.button,
                                AppColors.button.withOpacity(0.7),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.button.withOpacity(0.3),
                                blurRadius: 16,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.star_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.premiumVersion,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.label,
                            letterSpacing: -0.8,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.enjoyExclusiveFeatures,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.label.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCompactFeatureIcon(
                          icon: Icons.file_download_outlined,
                          title: AppLocalizations.of(context)!.exportFeature,
                        ),
                        _buildCompactFeatureIcon(
                          icon: Icons.block_outlined,
                          title: AppLocalizations.of(context)!.adFreeFeature,
                        ),
                        _buildCompactFeatureIcon(
                          icon: Icons.cloud_sync_outlined,
                          title: AppLocalizations.of(context)!.backupFeature,
                        ),
                      ],
                    ),
                    // Planos
                    Column(
                      children: [
                        _buildCompactSubscriptionCard(
                          label: AppLocalizations.of(context)!.yearlySubscription,
                          price: yearlyProductDetails != null
                              ? formatPrice(yearlyProductDetails!.rawPrice,
                                  yearlyProductDetails!.currencySymbol)
                              : AppLocalizations.of(context)!.loading,
                          pricePerMonth: yearlyProductDetails != null
                              ? formatPrice(yearlyProductDetails!.rawPrice / 12,
                                  yearlyProductDetails!.currencySymbol)
                              : '',
                          onPressed: () =>
                              _buySubscription(yearlyProductDetails?.id ?? ''),
                          productId: yearlyProductDetails?.id ?? '',
                          isPopular: true,
                        ),
                        const SizedBox(height: 12),
                        _buildCompactSubscriptionCard(
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
                          color: AppColors.label.withOpacity(0.6),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
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

  Widget _buildCompactFeatureIcon({
    required IconData icon,
    required String title,
  }) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.button.withOpacity(0.2),
                AppColors.button.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: AppColors.button,
            size: 26,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.label,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactSubscriptionCard({
    required String label,
    required String price,
    required VoidCallback onPressed,
    required String productId,
    required bool isPopular,
    String? pricePerMonth,
  }) {
    bool isPurchased = (productId == yearlyProId && isYearlyPro) ||
        (productId == monthlyProId && isMonthlyPro);

    bool isLoading = isLoadingPrice || loadingPurchases.contains(productId);

    return GestureDetector(
      onTap: isPurchased ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isPopular
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.button.withOpacity(0.15),
                    AppColors.button.withOpacity(0.05),
                  ],
                )
              : null,
          color: isPopular ? null : AppColors.card.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPopular
                ? AppColors.button.withOpacity(0.5)
                : AppColors.label.withOpacity(0.1),
            width: isPopular ? 2 : 1,
          ),
          boxShadow: isPopular
              ? [
                  BoxShadow(
                    color: AppColors.button.withOpacity(0.2),
                    blurRadius: 16,
                    spreadRadius: 0,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, isPopular ? 20 : 14, 16, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isPopular)
                      Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.button,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              AppLocalizations.of(context)!.popularBadge,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color:  AppColors.label,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          price,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.label,
                            letterSpacing: -0.5,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isPurchased
                        ? [
                            CupertinoColors.activeGreen,
                            CupertinoColors.activeGreen,
                          ]
                        : [
                            AppColors.button,
                            AppColors.button.withOpacity(0.8),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: (isPurchased
                              ? CupertinoColors.activeGreen
                              : AppColors.button)
                          .withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isPurchased)
                              const Padding(
                                padding: EdgeInsets.only(right: 6),
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            Text(
                              isPurchased
                                  ? AppLocalizations.of(context)!.subscribed
                                  : AppLocalizations.of(context)!.subscribe,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void voidFunc() {}
}
