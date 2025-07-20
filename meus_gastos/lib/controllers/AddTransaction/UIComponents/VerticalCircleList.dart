import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'package:meus_gastos/services/TranslateService.dart';

//mark - VerticalCircleList Widget
class VerticalCircleList extends StatefulWidget {
  final Function(int) onItemSelected;
  final int defaultdIndexCategory;
  final Function(List<CategoryModel>) onCategoriesLoaded;

  const VerticalCircleList({
    super.key,
    required this.onItemSelected,
    required this.defaultdIndexCategory,
    required this.onCategoriesLoaded,
  });

  @override
  VerticalCircleListState createState() => VerticalCircleListState();
}

//mark - VerticalCircleList State
class VerticalCircleListState extends State<VerticalCircleList> {
  int selectedIndex = 0;
  List<CategoryModel> categorieList = [];
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.defaultdIndexCategory;
    _scrollController = ScrollController();
    loadCategories();
  }

  Future<void> loadCategories() async {
    // Await the categories from the service
    categorieList = await CategoryService().getAllPositiveCategories();
    
    // Update the UI
    setState(() {});
    
    // Send the loaded list back to the parent widget via the callback
    widget.onCategoriesLoaded(categorieList);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isMacOS ? _macBuild() : _mobileBuild();
  }

  Widget _buildGridItem(BuildContext context, int index) {
    final category = categorieList[index];
    final bool isAddCategory = category.id == 'AddCategory';
    final bool isSelected = selectedIndex == index;

    return SizedBox(
      height: 55,
      child: GestureDetector(
        onTap: () {
          if (!isAddCategory) {
            setState(() {
              selectedIndex = index;
            });
          }
          widget.onItemSelected(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
          decoration: BoxDecoration(
            color: isAddCategory
                ? Colors.transparent
                : isSelected
                    ? AppColors.buttonSelected.withOpacity(0.15)
                    : CupertinoColors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: isAddCategory
                ? Border.all(
                    color: AppColors.label.withOpacity(0.3),
                    width: 1.5,
                    strokeAlign: BorderSide.strokeAlignInside,
                  )
                : isSelected
                    ? Border.all(
                        color: AppColors.button.withOpacity(0.8),
                        width: 2.5,
                        strokeAlign: BorderSide.strokeAlignInside,
                      )
                    : Border.all(
                        color: AppColors.label.withOpacity(0.12),
                        width: 1.5,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.button.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 32,
                height: 20,
                child: Icon(
                  category.icon,
                  color: isAddCategory
                      ? AppColors.label.withOpacity(0.6)
                      : isSelected
                          ? category.color
                          : category.color.withOpacity(0.8),
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 33,
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double fontSize =
                          (constraints.maxWidth * 0.12).clamp(8.0, 13.0);

                      return Text(
                        Translateservice.getTranslatedCategoryUsingModel(
                            context, category),
                        style: TextStyle(
                          fontSize: fontSize,
                          color: isSelected
                              ? AppColors.label
                              : AppColors.label.withOpacity(0.75),
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          height: 1.15,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mobileBuild() {
    return Container(
      color: AppColors.background1,
      child: Stack(
        children: [
          GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(
                top: 12, left: 16, right: 16, bottom: 70),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.4,
            ),
            itemCount: categorieList.length,
            itemBuilder: _buildGridItem,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 40,
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.background1,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _macBuild() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavigationButton(
                icon: Icons.keyboard_arrow_up_rounded,
                onPressed: _scrollUp,
              ),
              _buildNavigationButton(
                icon: Icons.keyboard_arrow_down_rounded,
                onPressed: _scrollDown,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.9,
            ),
            itemCount: categorieList.length,
            itemBuilder: _buildGridItem,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.label.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: AppColors.label.withOpacity(0.7),
          size: 24,
        ),
        onPressed: onPressed,
        splashRadius: 20,
      ),
    );
  }

  void _scrollUp() {
    _scrollController.animateTo(
      _scrollController.offset - 120,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.offset + 120,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}