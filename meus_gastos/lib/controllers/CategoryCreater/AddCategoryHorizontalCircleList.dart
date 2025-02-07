import 'dart:math';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddCategoryHorizontalCircleList extends StatefulWidget {
  final Function(int) onItemSelected;

  const AddCategoryHorizontalCircleList({
    super.key,
    required this.onItemSelected,
  });

  @override
  _AddCategoryHorizontalCircleListState createState() =>
      _AddCategoryHorizontalCircleListState();
}

final List<IconData> accountIcons = [
  Icons.restaurant, // Alimentação
  Icons.local_grocery_store, // Supermercado
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
  // Ícones adicionais:
  Icons.local_florist, // Hobbies / Presentes
  Icons.fastfood, // Lanches rápidos
  Icons.free_breakfast, // Café / Desjejum
  Icons.bike_scooter, // Mobilidade alternativa
  Icons.wifi, // Internet / Telecomunicações
  Icons.phone_android, // Telefonia
  Icons.build, // Manutenção / Reparos
  Icons.local_offer, // Promoções / Ofertas
  Icons.pie_chart, // Distribuição de gastos (Categoria Geral)
];

class _AddCategoryHorizontalCircleListState
    extends State<AddCategoryHorizontalCircleList> {
  int selectedIndex = 0;


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: accountIcons.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
              widget.onItemSelected(index);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: selectedIndex == index
                        ? AppColors.buttonSelected
                        : AppColors.buttonDeselected,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(accountIcons[index]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
