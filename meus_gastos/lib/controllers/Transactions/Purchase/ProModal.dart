import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    return Container(
      height: 630,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.modalBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 26),
              const Icon(
                Icons.star_rounded,
                color: Colors.amber,
                size: 80,
              ),
              Text(
                AppLocalizations.of(context)!.premiumVersion,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.label,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                AppLocalizations.of(context)!.enjoyExclusiveFeatures,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.labelSecondary,
                ),
              ),
              const SizedBox(height: 30),
              _buildFeatureRow(
                icon: Icons.file_present_rounded,
                label: AppLocalizations.of(context)!.exportToExcelOrPdf,
              ),
              _buildFeatureRow(
                icon: Icons.block,
                label: AppLocalizations.of(context)!.removeAds,
              ),
              const SizedBox(height: 40),
              Column(
                children: [
                  _buildSubscriptionButton(
                    label: AppLocalizations.of(context)!.monthlySubscription,
                    price: monthlyProductDetails != null
                        ? formatPrice(monthlyProductDetails!.rawPrice,
                            monthlyProductDetails!.currencySymbol)
                        : AppLocalizations.of(context)!.loading,
                    onPressed: () =>
                        _buySubscription(monthlyProductDetails?.id ?? ''),
                    productId: monthlyProductDetails?.id ?? '',
                  ),
                  const SizedBox(height: 22),
                  _buildSubscriptionButton(
                    label: AppLocalizations.of(context)!.yearlySubscription,
                    price: yearlyProductDetails != null
                        ? formatPrice(yearlyProductDetails!.rawPrice,
                            yearlyProductDetails!.currencySymbol)
                        : AppLocalizations.of(context)!.loading,
                    onPressed: () =>
                        _buySubscription(yearlyProductDetails?.id ?? ''),
                    productId: yearlyProductDetails?.id ?? '',
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: _restorePurchases,
                    child: Text(
                      AppLocalizations.of(context)!.restorePurchases,
                      style: const TextStyle(
                        color: AppColors.label,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 0,
            child: IconButton(
              icon: const Icon(
                CupertinoIcons.clear,
                color: AppColors.label,
                size: 28,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
  void _showMenuOptions(BuildContext context) {
  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) {
      return CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              _launchURL('https://www.apple.com/legal/internet-services/itunes/dev/stdeula/');
            },
            child: const Text('Terms of Use'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              _launchURL('https://drive.google.com/file/d/147xkp4cekrxhrBYZnzV-J4PzCSqkix7t/view?usp=sharing');
            },
            child: const Text('Privacy Policy'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
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

  Widget _buildSubscriptionButton({
    required String label,
    required String price,
    required VoidCallback onPressed,
    required String productId,
  }) {
    bool isPurchased = (productId == yearlyProId && isYearlyPro) ||
        (productId == monthlyProId && isMonthlyPro);

    bool isLoading = isLoadingPrice || loadingPurchases.contains(productId);

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isPurchased ? voidFunc : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPurchased
              ? const Color.fromARGB(255, 5, 162, 0)
              : AppColors.button,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                isPurchased ? "$label ✓✓" : "$label - $price",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  void voidFunc() {}

  Widget _buildFeatureRow({required IconData icon, required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 8),
          Icon(
            icon,
            color: AppColors.button,
            size: 30,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.label,
            ),
          ),
        ],
      ),
    );
  }
}
