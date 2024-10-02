import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class ProModal extends StatelessWidget {
  final bool isLoading;
  final ProductDetails? productDetails; // Detalhes do produto da assinatura
  final VoidCallback onBuySubscription;

  const ProModal({
    Key? key,
    required this.isLoading,
    required this.productDetails,
    required this.onBuySubscription,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 1.4,
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Icon(
            Icons.star_rounded,
            color: Colors.amber,
            size: 100,
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
            label: "Exportação ilimitada dos dados",
          ),
          _buildFeatureRow(
            icon: Icons.block,
            label: "Remoção completa de anúncios",
          ),
          const SizedBox(height: 40),
          // Exibir o botão com preço da assinatura anual
          isLoading
              ? const CircularProgressIndicator(
                  color: AppColors.label,
                )
              : ElevatedButton(
                  onPressed: onBuySubscription,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.button, // Cor de fundo azul
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Assinatura anual - ${productDetails?.price ?? 'Indisponível'}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Texto branco
                    ),
                  ),
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

  Widget _buildFeatureRow({required IconData icon, required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Alinhando o conteúdo ao centro
        children: [
          Icon(
            icon,
            color: AppColors.button,
            size: 30,
          ),
          const SizedBox(width: 8), // Espaçamento menor entre ícone e texto
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
