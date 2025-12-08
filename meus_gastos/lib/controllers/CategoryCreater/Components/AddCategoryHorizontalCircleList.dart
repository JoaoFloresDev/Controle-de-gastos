import 'package:flutter/services.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';


class AddCategoryHorizontalCircleList extends StatefulWidget {
  final Function(int) onItemSelected;
  final Color? selectedColor;

  const AddCategoryHorizontalCircleList({
    super.key,
    required this.onItemSelected,
    this.selectedColor,
  });

  @override
  _AddCategoryHorizontalCircleListState createState() =>
      _AddCategoryHorizontalCircleListState();
}

final List<IconData> accountIcons = [
  Icons.directions_car, // Transporte
  Icons.home, // Moradia
  Icons.electrical_services, // Utilidades
  Icons.healing, // Saúde
  Icons.shopping_cart, // Compras
  Icons.local_dining, // Restaurantes
  Icons.movie, // Entretenimento
  Icons.school, // Educação
  Icons.fitness_center, // Atividades físicas
  Icons.local_bar, // Bebidas / Lazer
  Icons.pets, // Pets
  Icons.flight, // Viagens
  Icons.credit_card, // Finanças / Cartão
  Icons.monetization_on, // Investimentos
  Icons.savings, // Poupança
  Icons.attach_money, // Outras despesas financeiras
  Icons.account_balance_wallet, // Gestão de contas
  Icons.card_travel, // Transporte de longa distância
  Icons.local_florist, // Hobbies / Presentes
  Icons.fastfood, // Lanches rápidos
  Icons.free_breakfast, // Café / Desjejum
  Icons.bike_scooter, // Mobilidade alternativa
  Icons.wifi, // Internet / Telecomunicações
  Icons.phone_android, // Telefonia
  Icons.build, // Manutenção / Reparos
  Icons.local_offer, // Promoções / Ofertas
  Icons.pie_chart, // Distribuição de gastos (Categoria Geral)
  Icons.restaurant, // Alimentação
  Icons.local_grocery_store, // Supermercado
];

class _AddCategoryHorizontalCircleListState
    extends State<AddCategoryHorizontalCircleList> {
  int selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _showLeftGradient = false;
  bool _showRightGradient = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateGradients);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateGradients);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateGradients() {
    setState(() {
      _showLeftGradient = _scrollController.offset > 10;
      _showRightGradient = _scrollController.offset < 
          _scrollController.position.maxScrollExtent - 10;
    });
  }

  void _scrollToSelected(int index) {
    // Calcula a posição para centralizar o item selecionado
    final double itemWidth = 66.0; // 50 (largura) + 16 (margin horizontal total)
    final double screenWidth = MediaQuery.of(context).size.width;
    final double targetScroll = (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
    
    _scrollController.animateTo(
      targetScroll.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Usa a cor selecionada ou a cor padrão
    final iconColor = widget.selectedColor ?? AppColors.buttonSelected;
    
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: accountIcons.length,
            itemBuilder: (context, index) {
              final isSelected = selectedIndex == index;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                  widget.onItemSelected(index);
                  _scrollToSelected(index);
                  HapticFeedback.lightImpact();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        width: isSelected ? 56 : 50,
                        height: isSelected ? 56 : 50,
                        decoration: BoxDecoration(
                          color: isSelected 
                                ? const Color.fromARGB(20, 0, 123, 255) // USA A COR SELECIONADA NA BORDA
                                : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected 
                                ? AppColors.button // USA A COR SELECIONADA NA BORDA
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: AnimatedScale(
                          scale: isSelected ? 1.0 : 0.85,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          child: Icon(
                            accountIcons[index],
                            color: isSelected 
                                ? iconColor // USA A COR SELECIONADA NO ÍCONE
                                : Colors.white.withOpacity(0.6),
                            size: isSelected ? 26 : 24,
                          ),
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.button, // USA A COR SELECIONADA NO INDICADOR
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Gradiente Esquerdo
          if (_showLeftGradient)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Container(
                  width: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.card.withOpacity(0.3),
                        AppColors.card.withOpacity(0.0),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          
          // Gradiente Direito
          if (_showRightGradient)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Container(
                  width: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        AppColors.card.withOpacity(0.3),
                        AppColors.card.withOpacity(0.0),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}