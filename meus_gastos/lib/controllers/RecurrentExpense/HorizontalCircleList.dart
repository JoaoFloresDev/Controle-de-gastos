// DELETAR

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
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
  List<CategoryModel> categories = [];
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    categories = widget.icons_list_recorrent;
    print(categories.length);
    categories.removeWhere((cat) => cat.id == "AddCategory");
    print(categories.length);
    selectedIndex = widget.defaultIndexCategory;
    lastSelectedIndex = selectedIndex;
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isMacOS) {
      return SizedBox(
        height: 100,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: AppColors.label),
              onPressed: () {
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
                itemCount: categories.length,
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
                            categories[index].icon,
                            color: categories[index].color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 80,
                          child: Text(
                            TranslateService.getTranslatedCategoryUsingModel(
                                context, categories[index]),
                            style: const TextStyle(
                                fontSize: 9, color: Colors.white),
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
    } else {
      return SizedBox(
        height: 100,
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
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
                      categories[index].icon,
                      color: categories[index].color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 80,
                    child: Text(
                      TranslateService.getTranslatedCategoryUsingModel(
                          context, categories[index]),
                      style:
                          const TextStyle(fontSize: 12, color: AppColors.label),
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
  }
}
