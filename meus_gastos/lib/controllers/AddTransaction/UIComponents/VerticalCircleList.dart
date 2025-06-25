import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'package:meus_gastos/services/TranslateService.dart';

class VerticalCircleList extends StatefulWidget {
  final Function(int) onItemSelected;
  final int defaultdIndexCategory;

  const VerticalCircleList({
    super.key,
    required this.onItemSelected,
    required this.defaultdIndexCategory,
  });

  @override
  VerticalCircleListState createState() => VerticalCircleListState();
}

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> loadCategories() async {
    categorieList = await CategoryService().getAllPositiveCategories();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isMacOS ? _macBuild() : _mobileBuild();
  }

  Widget _buildGridItem(BuildContext context, int index) {
    final category = categorieList[index];
    final bool isAddCategory = category.id == 'AddCategory';
    final bool isSelected = selectedIndex == index;

    return GestureDetector(
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
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        decoration: BoxDecoration(
          color: isAddCategory
              ? Colors.transparent
              : isSelected
                  ? AppColors.buttonSelected.withOpacity(0.15)
                  : AppColors.card.withOpacity(0.05),
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
                      width: 2,
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
                    color: AppColors.button.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 32,
              height: 24,
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
            const SizedBox(height: 2),
            SizedBox(
              height: 36,
              child: Center(
                child: Text(
                  Translateservice.getTranslatedCategoryUsingModel(context, category),
                  style: TextStyle(
                    fontSize: 10.5,
                    color: isSelected
                        ? AppColors.label
                        : AppColors.label.withOpacity(0.75),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
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
            padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 70), // Adiciona padding no final
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
