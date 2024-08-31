import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/designSystem/exportDS.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/TranslateService.dart';

class HorizontalCircleList extends StatefulWidget {
  final Function(int) onItemSelected;

  const HorizontalCircleList({
    Key? key,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  HorizontalCircleListState createState() => HorizontalCircleListState();
}

class HorizontalCircleListState extends State<HorizontalCircleList> {
  int selectedIndex = 0;
  int lastSelectedIndex = 0;
  List<CategoryModel> categorieList = [];

  // MARK: - InitState
  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  // MARK: - Load Categories
  Future<void> loadCategories() async {
    categorieList = await CategoryService().getAllCategories();
    setState(() {
      categorieList = categorieList;
    });
  }

  // MARK: - Build Method
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categorieList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (categorieList[index].id != 'AddCategory') {
                setState(() {
                  lastSelectedIndex = selectedIndex;
                  selectedIndex = index;
                });
              }
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
                    color: categorieList[index].id == 'AddCategory'
                        ? Colors.blue.withOpacity(0.3)
                        : selectedIndex == index
                            ? AppColors.buttonSelected
                            : AppColors.buttonBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    categorieList[index].icon,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Translateservice.getTranslatedCategoryUsingModel(
                      context, categorieList[index]),
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.label,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
