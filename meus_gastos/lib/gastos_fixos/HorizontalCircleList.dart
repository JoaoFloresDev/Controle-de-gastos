import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/TranslateService.dart';

class HorizontalCircleList extends StatefulWidget {
  final Function(int) onItemSelected;
  final List<CategoryModel> icons_list_recorrent;
  const HorizontalCircleList({
    Key? key,
    required this.onItemSelected,
    required this.icons_list_recorrent,
  }) : super(key: key);

  @override
  HorizontalCircleListState createState() => HorizontalCircleListState();
}

class HorizontalCircleListState extends State<HorizontalCircleList> {
  int selectedIndex = 0;
  int lastSelectedIndex = 0;

  

  // MARK: - Build Method
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.icons_list_recorrent.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
              lastSelectedIndex = selectedIndex;
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
                  child: Icon(
                    widget.icons_list_recorrent[index].icon,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Translateservice.getTranslatedCategoryUsingModel(
                      context, widget.icons_list_recorrent[index]),
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
