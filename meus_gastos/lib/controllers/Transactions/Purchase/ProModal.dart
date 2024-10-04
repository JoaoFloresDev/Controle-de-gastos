import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

class ProModal extends StatefulWidget {
  final bool isLoading;

  const ProModal({
    Key? key,
    required this.isLoading
  }) : super(key: key);

  @override
  _ProModalState createState() => _ProModalState();
}

class _ProModalState extends State<ProModal> {
  bool _isLoading = false;

  ProductDetails? yearlyProductDetails;
  ProductDetails? monthlyProductDetails;

  final String yearlyProId = 'yearly.pro'; // Seu ID de produto para assinatura anual
  final String monthlyProId = 'monthly.pro'; // Seu ID de produto para assinatura mensal

  @override
  void initState() {
    super.initState();
    InAppPurchase.instance.purchaseStream.listen((purchases) {
      _handlePurchaseUpdates(purchases);
    });

    // Verifica e processa compras pendentes
    _verifyPastPurchases();

    // Carrega os detalhes dos produtos
    _fetchProductDetails();
  }

  Future<void> _verifyPastPurchases() async {
    // Inicia o processo de restauração de compras
    InAppPurchase.instance.restorePurchases();
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (var purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          InAppPurchase.instance.completePurchase(purchase);
          break;
        case PurchaseStatus.error:
          print('Erro na compra: ${purchase.error}');
          InAppPurchase.instance.completePurchase(purchase);
          break;
        default:
          break;
      }
    }
    setState(() {
      _isLoading = true;
    });
  }

  Future<void> _fetchProductDetails() async {
    setState(() {
      _isLoading = true;
    });

    final bool available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Recupera os detalhes dos produtos mensal e anual
    final ProductDetailsResponse response = await InAppPurchase.instance.queryProductDetails({yearlyProId, monthlyProId});

    if (response.error != null || response.productDetails.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      yearlyProductDetails = response.productDetails.firstWhere((product) => product.id == yearlyProId);
      monthlyProductDetails = response.productDetails.firstWhere((product) => product.id == monthlyProId);
      _isLoading = false;
    });
  }

  // Função para formatar preço
  String formatPrice(double price, String currencySymbol) {
    final format = NumberFormat.currency(
      locale: currencySymbol == 'R\$' ? 'pt_BR' : Intl.defaultLocale,
      symbol: currencySymbol,
    );
    return format.format(price);
  }

  // Função para realizar a compra de uma assinatura
  Future<void> _buySubscription(String productId) async {
    setState(() {
      _isLoading = true;
    });

    final paymentWrapper = SKPaymentQueueWrapper();
    final transactions = await paymentWrapper.transactions();
    for (var transaction in transactions) {
      await paymentWrapper.finishTransaction(transaction);
    }

    final bool available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final ProductDetailsResponse response = await InAppPurchase.instance.queryProductDetails({productId});

    if (response.error == null && response.productDetails.isNotEmpty) {
      final productDetails = response.productDetails.first;
      final purchaseParam = PurchaseParam(productDetails: productDetails);
      InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Função para restaurar compras anteriores
  Future<void> _restorePurchases() async {
    setState(() {
      _isLoading = true;
    });

    await InAppPurchase.instance.restorePurchases();

    setState(() {
      _isLoading = false;
    });
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
              widget.isLoading || _isLoading
                  ? const CircularProgressIndicator(
                      color: AppColors.label,
                    )
                  : Column(
                      children: [
                        _buildSubscriptionButton(
                          label: "Assinatura mensal",
                          price: monthlyProductDetails != null
                              ? formatPrice(
                                  monthlyProductDetails!.rawPrice,
                                  monthlyProductDetails!.currencySymbol,
                                )
                              : 'Indisponível',
                          onPressed: () => _buySubscription(monthlyProductDetails?.id ?? ''),
                        ),
                        const SizedBox(height: 22),
                        _buildSubscriptionButton(
                          label: "Assinatura anual",
                          price: yearlyProductDetails != null
                              ? formatPrice(
                                  yearlyProductDetails!.rawPrice,
                                  yearlyProductDetails!.currencySymbol,
                                )
                              : 'Indisponível',
                          onPressed: () => _buySubscription(yearlyProductDetails?.id ?? ''),
                        ),
                        const SizedBox(height: 15),
                        TextButton(
                          onPressed: _restorePurchases,
                          child: const Text(
                            "Restaurar Compras",
                            style: TextStyle(
                              color: AppColors.label,
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
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
              onPressed: () {
                Navigator.of(context).pop();
              },
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
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.button,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          "$label - $price",
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
