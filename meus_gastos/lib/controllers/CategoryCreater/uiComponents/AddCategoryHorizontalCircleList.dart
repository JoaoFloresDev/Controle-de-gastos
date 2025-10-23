import 'package:meus_gastos/designSystem/ImplDS.dart';

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
  Icons.directions_car, 
  Icons.home, 
  Icons.electrical_services, 
  Icons.healing, 
  Icons.shopping_cart, 
  Icons.local_dining, 
  Icons.movie, 
  Icons.school, 
  Icons.fitness_center, 
  Icons.local_bar, 
  Icons.pets, 
  Icons.flight, 
  Icons.credit_card, 
  Icons.monetization_on, 
  Icons.savings, 
  Icons.attach_money, 
  Icons.account_balance_wallet, 
  Icons.card_travel, 
  Icons.local_florist, 
  Icons.fastfood, 
  Icons.free_breakfast, 
  Icons.bike_scooter, 
  Icons.wifi, 
  Icons.phone_android, 
  Icons.build, 
  Icons.local_offer, 
  Icons.pie_chart, 
  Icons.restaurant, 
  Icons.local_grocery_store, 
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
