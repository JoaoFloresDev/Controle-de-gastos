import 'dart:io';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:flutter/services.dart';


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
  List<CategoryModel> categorieList = [];
  late ScrollController _scrollController;
  bool _showLeftGradient = false;
  bool _showRightGradient = true;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_updateGradients);
    loadCategories();
    selectedIndex = widget.defaultdIndexCategory;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateGradients);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> loadCategories() async {
    categorieList = widget.categories;
    // print(categorieList.removeLast().name);
    setState(() {});
  }

  // MARK: - Build Method
  void _updateGradients() {
    setState(() {
      _showLeftGradient = _scrollController.offset > 10;
      _showRightGradient = _scrollController.offset <
          _scrollController.position.maxScrollExtent - 10;
    });
  }

  void _scrollToSelected(int index) {
    if (categorieList.isEmpty) return;
    final double itemWidth = 70.0;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double targetScroll =
        (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

    _scrollController.animateTo(
      targetScroll.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return SizedBox(
        height: 110,
        child: Center(
          child: CupertinoActivityIndicator(
            color: AppColors.label,
          ),
        ),
      );
    }

    return Container(
      height: 110,
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
            itemCount: categorieList.length,
            itemBuilder: (context, index) {
              final isSelected = selectedIndex == index;
              final category = categorieList[index];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                  _scrollToSelected(index);
                  HapticFeedback.lightImpact();
                  widget.onItemSelected(index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                  width: 70,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        width: isSelected ? 56 : 50,
                        height: isSelected ? 56 : 50,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? category.color.withOpacity(0.15)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? category.color
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: AnimatedScale(
                          scale: isSelected ? 1.0 : 0.85,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          child: Icon(
                            category.icon,
                            color: isSelected
                                ? category.color
                                : Colors.white.withOpacity(0.6),
                            size: isSelected ? 26 : 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        TranslateService.getTranslatedCategoryUsingModel(
                            context, category),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected
                              ? category.color
                              : Colors.white.withOpacity(0.6),
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      if (isSelected)
                        const SizedBox(height: 4),
                      if (isSelected)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: category.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
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