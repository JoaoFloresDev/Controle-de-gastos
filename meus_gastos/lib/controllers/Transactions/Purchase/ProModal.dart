import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';

class ProModal extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onSubscriptionPurchased;

  const ProModal({
    Key? key,
    required this.isLoading,
    required this.onSubscriptionPurchased,
  }) : super(key: key);

  @override
  _ProModalState createState() => _ProModalState();
}

class _ProModalState extends State<ProModal> {
  ProductDetails? yearlyProductDetails;
  ProductDetails? monthlyProductDetails;

  final String yearlyProId = 'yearly.pro';
  final String monthlyProId = 'monthly.pro';

  // Conjunto para armazenar os IDs dos produtos comprados
  Set<String> purchasedProductIds = {};

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

    // Chamar restorePurchases ao iniciar para verificar compras existentes
    _restorePurchases();
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    bool isPurchaseUpdated = false;

    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        _deliverProduct(purchaseDetails);
        isPurchaseUpdated = true;
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        // Trate erros de compra aqui, se necessário
      }
      if (purchaseDetails.pendingCompletePurchase) {
        InAppPurchase.instance.completePurchase(purchaseDetails);
      }
    }

    if (isPurchaseUpdated) {
      widget.onSubscriptionPurchased(); // Notifica o widget pai
    }
  }

  void _deliverProduct(PurchaseDetails purchase) {
    setState(() {
      purchasedProductIds.add(purchase.productID); // Adiciona o produto comprado ao conjunto
    });
    // Não é necessário chamar onSubscriptionPurchased aqui novamente
  }

  Future<void> _fetchProductDetails() async {
    final bool available = await InAppPurchase.instance.isAvailable();
    if (!available) return;

    final ProductDetailsResponse response = await InAppPurchase.instance
        .queryProductDetails({yearlyProId, monthlyProId});
    if (response.error != null || response.productDetails.isEmpty) return;

    setState(() {
      yearlyProductDetails = response.productDetails
          .firstWhere((product) => product.id == yearlyProId);
      monthlyProductDetails = response.productDetails
          .firstWhere((product) => product.id == monthlyProId);
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
    final bool available = await InAppPurchase.instance.isAvailable();
    if (!available) return;

    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails({productId});
    if (response.error == null && response.productDetails.isNotEmpty) {
      final productDetails = response.productDetails.first;
      final purchaseParam = PurchaseParam(productDetails: productDetails);
      InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
    }
  }

  Future<void> _restorePurchases() async {
    await InAppPurchase.instance.restorePurchases();
    // As compras restauradas serão entregues via _listenToPurchaseUpdated
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 630,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.modalBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 5),
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
              const Text(
                "Versão Premium",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.label,
                ),
              ),
              const Text(
                "Desfrute de todos os recursos exclusivos:",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.labelSecondary,
                ),
              ),
              const SizedBox(height: 30),
              _buildFeatureRow(
                icon: Icons.file_present_rounded,
                label: "Exportação para excel ou pdf",
              ),
              _buildFeatureRow(
                icon: Icons.block,
                label: "Remoção completa de anúncios",
              ),
              const SizedBox(height: 40),
              Column(
                children: [
                  _buildSubscriptionButton(
                    label: "Assinatura mensal",
                    price: monthlyProductDetails != null
                        ? formatPrice(monthlyProductDetails!.rawPrice,
                            monthlyProductDetails!.currencySymbol)
                        : 'Indisponível',
                    onPressed: () =>
                        _buySubscription(monthlyProductDetails?.id ?? ''),
                    productId: monthlyProductDetails?.id ?? '',
                  ),
                  const SizedBox(height: 22),
                  _buildSubscriptionButton(
                    label: "Assinatura anual",
                    price: yearlyProductDetails != null
                        ? formatPrice(yearlyProductDetails!.rawPrice,
                            yearlyProductDetails!.currencySymbol)
                        : 'Indisponível',
                    onPressed: () =>
                        _buySubscription(yearlyProductDetails?.id ?? ''),
                    productId: yearlyProductDetails?.id ?? '',
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: _restorePurchases,
                    child: const Text(
                      "Restaurar Compras",
                      style: TextStyle(
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

  Widget _buildSubscriptionButton({
    required String label,
    required String price,
    required VoidCallback onPressed,
    required String productId,
  }) {
    // Verifica se o produto foi comprado
    bool isPurchased = purchasedProductIds.contains(productId);

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed:
            isPurchased ? null : onPressed, // Desabilita o botão se comprado
        style: ElevatedButton.styleFrom(
          backgroundColor: isPurchased
              ? Colors.green
              : AppColors.button, // Muda a cor do botão se comprado
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          isPurchased ? "Comprado" : "$label - $price",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow({required IconData icon, required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
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
