import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/TranslateService.dart';

class HorizontalCircleList extends StatefulWidget {
  final Function(int) onItemSelected;
  final List<CategoryModel> icons_list_recorrent;
  final int defaultIndexCategory;
  const HorizontalCircleList({
    super.key,
    required this.onItemSelected,
    required this.icons_list_recorrent,
    required this.defaultIndexCategory,
  });

  @override
  HorizontalCircleListState createState() => HorizontalCircleListState();
}

class HorizontalCircleListState extends State<HorizontalCircleList> {
  int selectedIndex = 0;
  int lastSelectedIndex = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedIndex = widget.defaultIndexCategory;
    lastSelectedIndex = selectedIndex;
  }

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
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.icons_list_recorrent[index].icon,
                    color: widget.icons_list_recorrent[index].color,
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
