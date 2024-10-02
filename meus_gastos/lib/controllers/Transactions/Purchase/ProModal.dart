import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';

class ProModal extends StatelessWidget {
  final bool isLoading;
  final ProductDetails? yearlyProductDetails;
  final ProductDetails? monthlyProductDetails;
  final VoidCallback onBuyYearlySubscription;
  final VoidCallback onBuyMonthlySubscription;

  const ProModal({
    Key? key,
    required this.isLoading,
    required this.yearlyProductDetails,
    required this.monthlyProductDetails,
    required this.onBuyYearlySubscription,
    required this.onBuyMonthlySubscription,
  }) : super(key: key);

String formatPrice(double price, String currencySymbol) {
  // Verifica se a moeda é BRL, para usar o formato correto
  final format = NumberFormat.currency(
    locale: currencySymbol == 'R\$' ? 'pt_BR' : Intl.defaultLocale,
    symbol: currencySymbol,
  );
  return format.format(price);
}


  @override
  Widget build(BuildContext context) {
    return Container(
      height: 650,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
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
          const SizedBox(height: 20),
          _buildFeatureRow(
            icon: Icons.file_present_rounded,
            label: "Exportação para excel ou pdf",
          ),
          _buildFeatureRow(
            icon: Icons.block,
            label: "Remoção completa de anúncios",
          ),
          const SizedBox(height: 26),
          isLoading
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
                      onPressed: onBuyMonthlySubscription,
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
                      onPressed: onBuyYearlySubscription,
                    ),
                  ],
                ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              "Talvez mais tarde",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
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
        mainAxisAlignment: MainAxisAlignment.start, // Alinhamento à esquerda
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
