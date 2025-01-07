import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:onepref/onepref.dart';

class ProModalAndroid extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onSubscriptionPurchased;

  const ProModalAndroid({
    super.key,
    required this.isLoading,
    required this.onSubscriptionPurchased,
  });

  @override
  _ProModalAndroidState createState() => _ProModalAndroidState();
}

class _ProModalAndroidState extends State<ProModalAndroid> {
  String formatPrice(double price, String currencySymbol) {
    final format = NumberFormat.currency(
      locale: currencySymbol == 'R\$' ? 'pt_BR' : Intl.defaultLocale,
      symbol: currencySymbol,
    );
    return format.format(price);
  }

  late final List<ProductDetails> _products = <ProductDetails>[];

  IApEngine iApEngine = IApEngine();

  List<ProductId> storeProductIds = <ProductId>[
    ProductId(id: "id_remove_ads_month", isConsumable: true),
    ProductId(id: "id_remove_ads_year", isConsumable: true)
  ];
  Set<String> loadingPurchases = {};

  late bool isYearlyPro;
  late bool isMonthlyPro;
  bool isLoadingPrice = true;

  final String YearlyProKey = "yearly.pro";
  final String monthlyProKey = 'monthly.pro';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateProStatus();
    print("Chegou aqui");

    iApEngine.inAppPurchase.purchaseStream.listen((list) {
      listenPurchases(list);
    });
    print("Chegou aqui");
    getProducts();
    print(_products.length);
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

  void getProducts() async {
    await iApEngine.getIsAvailable().then((value) async {
      if (value) {
        await iApEngine.queryProducts(storeProductIds).then((response) {
          setState(() {
            _products.addAll(response.productDetails);
            isLoadingPrice = false;
          });
        });
      }
    });
  }

  Future<void> listenPurchases(List<PurchaseDetails> list) async {
    for (final purchase in list) {
      if ((purchase.status == PurchaseStatus.restored) ||
          (purchase.status == PurchaseStatus.purchased)) {
        // Identificar produto comprado
        if (storeProductIds[0].id == purchase.productID) {
          await restore_purchases(purchase); // Atualizar estado
          widget.onSubscriptionPurchased(); // Ação pós-compra
        } else if (storeProductIds[1].id == purchase.productID) {
          await restore_purchases(purchase); // Atualizar estado
          widget.onSubscriptionPurchased(); // Ação pós-compra
        }

        // Completar a compra se pendente
        if (purchase.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchase);
        }
      }
    }
  }

  Future<void> restore_purchases(PurchaseDetails purchaseDetails) async {
    final prefs = await SharedPreferences.getInstance();
    if (storeProductIds[0].id == purchaseDetails.productID) {
      await prefs.setBool(monthlyProKey, true);
      setState(() {
        isMonthlyPro = true;
      });
    } else if (storeProductIds[1].id == purchaseDetails.productID) {
      await prefs.setBool(YearlyProKey, true);
      setState(() {
        isYearlyPro = true;
      });
    }

    // Atualizar UI após restauração
    updateProStatus();
  }

  Future<void> _restorePurchases() async {
    final purchases = await InAppPurchase.instance.restorePurchases();
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
                    price: _products.isNotEmpty
                        ? formatPrice(
                            _products[0].rawPrice, _products[0].currencySymbol)
                        : AppLocalizations.of(context)!.loading,
                    onPressed: () => {
                      _buySubscription(_products[0].id ?? ''),
                      // iApEngine.handlePurchase(_products[0], storeProductIds)
                    },
                    productId: _products.isNotEmpty ? _products[0].id : '',
                  ),
                  const SizedBox(height: 22),
                  _buildSubscriptionButton(
                    label: AppLocalizations.of(context)!.yearlySubscription,
                    price: _products.isNotEmpty
                        ? formatPrice(
                            _products[1].rawPrice, _products[1].currencySymbol)
                        : AppLocalizations.of(context)!.loading,
                    onPressed: () => {
                      _buySubscription(_products[1].id ?? ''),
                      // iApEngine.handlePurchase(_products[1], storeProductIds)
                    },
                    productId: _products.isNotEmpty ? _products[1].id : '',
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
          Positioned(
            right: 10,
            child: IconButton(
              icon: const Icon(
                CupertinoIcons.question_circle,
                color: AppColors.label,
                size: 28,
              ),
              onPressed: () {
                // Ação a ser realizada ao clicar no botão de ajuda
                // _showMenuOptions(context);
              },
            ),
          ),
        ],
      ),
    );
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
    } else {}
    setState(() {
      loadingPurchases.remove(productId);
    });
  }

  Widget _buildSubscriptionButton({
    required String label,
    required String price,
    required VoidCallback onPressed,
    required String productId,
  }) {
    bool isPurchased = (productId == storeProductIds[1].id && isYearlyPro) ||
        (productId == storeProductIds[0].id && isMonthlyPro);

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
