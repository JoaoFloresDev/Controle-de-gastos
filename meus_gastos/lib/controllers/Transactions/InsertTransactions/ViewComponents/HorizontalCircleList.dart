import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/TranslateService.dart';

class HorizontalCircleList extends StatefulWidget {
  final Function(int) onItemSelected;
  final int defaultdIndexCategory;
  const HorizontalCircleList({
    super.key,
    required this.onItemSelected,
    required this.defaultdIndexCategory,
  });

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
    selectedIndex = widget.defaultdIndexCategory;
    lastSelectedIndex = selectedIndex;
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
      height: 90,
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
                        ? Colors.transparent
                        : selectedIndex == index
                            ? AppColors.buttonSelected
                            : AppColors.buttonDeselected,
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
                    color: Colors.white,
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
