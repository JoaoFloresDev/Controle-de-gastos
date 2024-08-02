import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'package:meus_gastos/models/CategoryModel.dart';

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

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    categorieList = await CategoryService().getAllCategories();
    print(CategoryService().printAllCategories());
    setState(() {
      categorieList = categorieList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100, // Ajuste a altura para acomodar o círculo e o texto
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
              mainAxisSize: MainAxisSize
                  .min, // Para evitar preencher todo o espaço vertical
              children: [
                Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: categorieList[index].id == 'AddCategory'
                        ? (Colors.blue.withOpacity(0.3))
                        : (selectedIndex == index
                            ? Colors.grey.withOpacity(0.3)
                            : Colors.black.withOpacity(0.1)),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    categorieList[index].icon,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  categorieList[index].name,
                  style: TextStyle(
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
