import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';

class Buyscreen extends StatefulWidget{
  @override
  State<Buyscreen> createState() => _Buyscreen();
}

class _Buyscreen extends State<Buyscreen>{
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
              // widget.isLoading || _isLoading
              //     ? const CircularProgressIndicator(
              //         color: AppColors.label,
              //       )
              //     : 
                  Column(
                      children: [
                        _buildSubscriptionButton(
                          label: "Assinatura mensal",
                          price: 'Indisponível',
                          onPressed: () => {},
                        ),
                        const SizedBox(height: 22),
                        _buildSubscriptionButton(
                          label: "Assinatura anual",
                          price: 'Indisponível',
                          onPressed: () => {},
                        ),
                        const SizedBox(height: 15),
                        TextButton(
                          onPressed: () => {},
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