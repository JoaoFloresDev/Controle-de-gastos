import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class ProModal extends StatefulWidget {
  @override
  _ProModalState createState() => _ProModalState();
}

class _ProModalState extends State<ProModal> {
  final String yearlyProId = 'yearly.pro'; // Seu ID de produto para assinatura
  bool _available = true;
  bool _isLoading = false;
  bool _isPro = false;

  @override
  void initState() {
    super.initState();
    InAppPurchase.instance.purchaseStream.listen((purchases) {
      _handlePurchaseUpdates(purchases);
    });
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (var purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        // Aqui você pode verificar a compra e ativar o PRO
        setState(() {
          _isPro = true;
        });
        // Confirma a compra (necessário para não repetir a transação)
        InAppPurchase.instance.completePurchase(purchase);
      } else if (purchase.status == PurchaseStatus.error) {
        // Tratamento de erros
        print('Erro na compra: ${purchase.error}');
      }
    }
  }

  Future<void> _buySubscription() async {
    setState(() {
      _isLoading = true;
    });

    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails({yearlyProId});
    if (response.error != null || response.notFoundIDs.isNotEmpty) {
      setState(() {
        _available = false;
        _isLoading = false;
      });
      return;
    }

    final ProductDetails productDetails = response.productDetails.first;
    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);

    InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _showProModal(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height / 1.5,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Upgrade to PRO",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Enjoy exclusive features with PRO.",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                CupertinoButton.filled(
                  onPressed: _isLoading
                      ? null
                      : () {
                          _buySubscription();
                        },
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Upgrade Now"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showProModal(context),
          child: const Text("Show Pro Modal"),
        ),
      ),
    );
  }
}
