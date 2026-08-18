import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/services/AnalyticsService.dart';

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
  late String selectedPlanId = yearlyProId;

  Set<String> purchasedProductIds = {};
  Set<String> loadingPurchases = {};

  late InAppPurchase _inAppPurchase;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  @override
  void initState() {
    super.initState();
    AnalyticsService().paywallViewed('pro_modal');
    _inAppPurchase = InAppPurchase.instance;
    _purchaseSubscription = _inAppPurchase.purchaseStream.listen(
      _listenToPurchaseUpdated,
      onError: (error) {
        // Trate erros aqui, se necessário
      },
    );

    _fetchProductDetails();
    _restorePurchases();
    updateProStatus();
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
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
        if (purchaseDetails.status == PurchaseStatus.purchased) {
          AnalyticsService().purchaseCompleted(purchaseDetails.productID);
        } else {
          AnalyticsService().purchaseRestored();
        }
        _deliverProduct(purchaseDetails);
        isPurchaseUpdated = true;
        if (purchaseDetails.productID == yearlyProId) {
          saveIsPremiumyearly();
        }
        if (purchaseDetails.productID == monthlyProId) {
          saveIsPremiummonthly();
        }
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        AnalyticsService().purchaseFailed(purchaseDetails.productID);
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
    AnalyticsService().purchaseStarted(productId);
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

  bool get _isPro => isYearlyPro || isMonthlyPro;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final viewPadding = MediaQueryData.fromView(View.of(context)).viewPadding;

    return Scaffold(
      backgroundColor: AppColors.background1,
      body: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 8,
                right: 8,
                top: viewPadding.top + 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      CupertinoIcons.xmark,
                      color: AppColors.label,
                      size: 26,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.label,
                      size: 26,
                    ),
                    onPressed: () => _showMenuOptions(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/onboarding/hero_pro.png',
                      height: 170,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.star_rounded,
                        color: AppColors.button,
                        size: 72,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l.unlockPremium,
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
                      l.proDescription,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.label.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          _buildFeatureRow(
                            icon: Icons.file_download_outlined,
                            title: l.exportToExcelOrPdf,
                          ),
                          const SizedBox(height: 14),
                          _buildFeatureRow(
                            icon: Icons.cloud_sync_outlined,
                            title: l.cloudBackup,
                          ),
                          const SizedBox(height: 14),
                          _buildFeatureRow(
                            icon: Icons.block_rounded,
                            title: l.adFreeFeature,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildPlanCard(
                      productId: yearlyProId,
                      label: l.planYearly,
                      badge: l.bestValue,
                      price: yearlyProductDetails != null
                          ? formatPrice(yearlyProductDetails!.rawPrice,
                              yearlyProductDetails!.currencySymbol)
                          : null,
                      priceDetail: yearlyProductDetails != null
                          ? '${formatPrice(yearlyProductDetails!.rawPrice / 12, yearlyProductDetails!.currencySymbol)}${l.perMonthShort}'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _buildPlanCard(
                      productId: monthlyProId,
                      label: l.planMonthly,
                      price: monthlyProductDetails != null
                          ? formatPrice(monthlyProductDetails!.rawPrice,
                              monthlyProductDetails!.currencySymbol)
                          : null,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isPro || loadingPurchases.isNotEmpty
                      ? null
                      : () => _buySubscription(selectedPlanId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.button,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _isPro
                        ? CupertinoColors.activeGreen
                        : AppColors.button.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: loadingPurchases.isNotEmpty
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _isPro ? l.subscribed : l.startFreeTrial,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: viewPadding.bottom + 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFooterLink(l.restorePurchases, _restorePurchases),
                  _footerDot(),
                  _buildFooterLink(
                    l.privacyPolicy,
                    () => _launchURL(
                        'https://drive.google.com/file/d/147xkp4cekrxhrBYZnzV-J4PzCSqkix7t/view?usp=sharing'),
                  ),
                  _footerDot(),
                  _buildFooterLink(
                    l.termsOfUse,
                    () => _launchURL(
                        'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'),
                  ),
                ],
              ),
            ),
          ],
      ),
    );
  }

  Widget _footerDot() {
    return Text(
      ' · ',
      style: TextStyle(
        color: AppColors.label.withOpacity(0.4),
        fontSize: 12,
      ),
    );
  }

  Widget _buildFooterLink(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.label.withOpacity(0.6),
          fontSize: 12,
          fontWeight: FontWeight.w500,
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

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.button.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.button,
            size: 20,
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
      ],
    );
  }

  Widget _buildPlanCard({
    required String productId,
    required String label,
    String? price,
    String? priceDetail,
    String? badge,
  }) {
    final bool isSelected = selectedPlanId == productId;

    return GestureDetector(
      onTap: () => setState(() => selectedPlanId = productId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.button.withOpacity(0.12)
              : AppColors.card.withOpacity(0.3),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppColors.button
                : AppColors.label.withOpacity(0.12),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? AppColors.button
                  : AppColors.label.withOpacity(0.35),
              size: 26,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.label,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1A33C),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    AppLocalizations.of(context)!.freeTrial3Days,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.label.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (price == null)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.labelPlaceholder,
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.label,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (priceDetail != null)
                    Text(
                      priceDetail,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.label.withOpacity(0.6),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
