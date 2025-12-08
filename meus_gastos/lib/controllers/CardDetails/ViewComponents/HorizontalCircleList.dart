import 'dart:io';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/TranslateService.dart';

class HorizontalCircleList extends StatefulWidget {
  final Function(int) onItemSelected;
  final int defaultdIndexCategory;
  final List<CategoryModel> categories;
  const HorizontalCircleList(
      {super.key,
      required this.onItemSelected,
      required this.defaultdIndexCategory,
      required this.categories});

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
    _scrollController = ScrollController();
    loadCategories();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // MARK: - Load Categories
  Future<void> loadCategories() async {
    categorieList = widget.categories;
    // print(categorieList.removeLast().name);
    setState(() {});
  }

  // MARK: - Build Method
  @override
  Widget build(BuildContext context) {
    return Platform.isMacOS
        ? Macbuild()
        : SizedBox(
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
                                  : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          categorieList[index].icon,
                          color: categorieList[index].color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 80,
                        child: Text(
                          TranslateService.getTranslatedCategoryUsingModel(
                              context, categorieList[index]),
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
  }

  Widget Macbuild() {
    return SizedBox(
      height: 90,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.label),
            onPressed: () {
              // Volta 100 pixels para a esquerda
              _scrollController.animateTo(
                _scrollController.offset - 100,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
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
                                  : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          categorieList[index].icon,
                          color: categorieList[index].color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 80,
                        child: Text(
                          TranslateService.getTranslatedCategoryUsingModel(
                              context, categorieList[index]),
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: AppColors.label),
            onPressed: () {
              // Avança 100 pixels para a direita
              _scrollController.animateTo(
                _scrollController.offset + 100,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        ],
      ),
    );
  }

  late ScrollController _scrollController;
}
