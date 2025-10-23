import 'package:meus_gastos/controllers/CategoryCreater/uiComponents/PickColor.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/controllers/CategoryCreater/uiComponents/AddCategoryHorizontalCircleList.dart';

class Categorycreater extends StatefulWidget {
  final VoidCallback onCategoryAdded;

  const Categorycreater({super.key, required this.onCategoryAdded});

  @override
  State<Categorycreater> createState() => _CategorycreaterState();
}

class _CategorycreaterState extends State<Categorycreater> {
  // MARK: Variables
  late TextEditingController categoriaController;
  late Color _currentColor =
      Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  List<CategoryModel> categories = [];
  int selectedIndex = 0;

  void loadCategories() async {
    categories = await CategoryService().getAllCategoriesAvaliable();
    setState(() {});
  }

  void adicionar() async {
    int frequency = 2;
    CategoryModel? categoryHighFrequency =
        await CategoryService().getCategoryWithHighestFrequency();
    if (categoryHighFrequency != null && categoryHighFrequency.id.isNotEmpty) {
      frequency = categoryHighFrequency.frequency + 1;
    }
    CategoryModel category = CategoryModel(
        id: const Uuid().v4(),
        color: _currentColor,
        icon: accountIcons[selectedIndex],
        name: categoriaController.text,
        frequency: frequency);

    await CategoryService().addCategory(category);
    widget.onCategoryAdded();
    loadCategories();
    setState(() {});
  }

  void changeColor(Color newColor) {
    setState(() {
      _currentColor = newColor;
    });
  }

  // MARK: - Lifecycle Methods
  @override
  void initState() {
    super.initState();
    categoriaController = TextEditingController();
    loadCategories();
  }

  @override
  void dispose() {
    categoriaController.dispose();
    super.dispose();
  }

  void _hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(0),
        decoration: const BoxDecoration(
          color: AppColors.background1,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomHeader(
              title: AppLocalizations.of(context)!.createCategory,
              onCancelPressed: () {
                Navigator.pop(context);
              },
            ),
            GestureDetector(
              onTap: _hideKeyboard,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      AddCategoryHorizontalCircleList(
                        onItemSelected: (index) {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _nameCategoryInput(),
                      const SizedBox(height: 32),
                      _inputCategoryColor(),
                      const SizedBox(height: 32),
                      _addButton(),
                      const SizedBox(height: 40),
                      _categoriesManegerList(),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

//MARK: Widgets

  Widget _inputCategoryColor() {
    return Row(
      children: [
        Text(
          "${AppLocalizations.of(context)!.chooseColor} ",
          style: const TextStyle(color: AppColors.label, fontSize: 20),
        ),
        const SizedBox(width: 15),
        GestureDetector(
          onTap: () => PickColor().pickColor(context, changeColor, _currentColor),
          child: Container(
            decoration: BoxDecoration(
              color: _currentColor,
              border: Border.all(
                color: AppColors.button,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            height: 30,
            width: 30,
          ),
        ),
      ],
    );
  }

  Widget _categoriesManegerList() {
    return Stack(
      children: [
        SizedBox(
            height: MediaQuery.of(context).size.height - 550,
            child: _listCategories()),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.background1,
                  AppColors.background1.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppColors.background1,
                  AppColors.background1.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _addButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: CupertinoButton(
          color: AppColors.button,
          onPressed: () {
            if (categoriaController.text.isNotEmpty) {
              adicionar();
              FocusScope.of(context).unfocus();
              // Navigator.pop(context);
            }
          },
          child: Text(
            AppLocalizations.of(context)!.addCategory,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.label),
          ),
        ),
      ),
    );
  }

  Widget _nameCategoryInput() {
    return CupertinoTextField(
      style: const TextStyle(
        color: Color.fromARGB(255, 252, 252, 254),
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ),
      placeholder: AppLocalizations.of(context)!.category,
      placeholderStyle:
          const TextStyle(color: Color.fromARGB(144, 255, 255, 255)),
      controller: categoriaController,
      inputFormatters: [
        LengthLimitingTextInputFormatter(15),
      ],
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget _listCategories() {
    if (categories.isEmpty) {
      return Center(
          child: Text("No categories found",
              style: TextStyle(color: Colors.white)));
    }
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: categories.length - 1,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final category = categories[index];
        return Container(
          margin: EdgeInsets.only(
              left: 16,
              right: 16,
              top: index == 0 ? 30 : 8,
              bottom: index == categories.length - 2 ? 40 : 8),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Icon(category.icon, color: category.color, size: 30),
            title: Text(
                TranslateService.getTranslatedCategoryUsingModel(
                    context, category),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () async {
                FocusScope.of(context).unfocus();

                await CategoryService().deleteCategory(category.id);

                loadCategories();

                widget.onCategoryAdded();
              },
            ),
          ),
        );
      },
    );
  }

  // Widget buildColorPicker() {
  //   return Container(
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       padding: const EdgeInsets.all(8),
  //       child: ColorPicker(
  //           pickerColor: _currentColor,
  //           onColorChanged: (Color color) {
  //             setState(() {
  //               _currentColor = color;
  //             });
  //           },
  //           showLabel: false,
  //           pickerAreaHeightPercent: 0.6,
  //           displayThumbColor: false,
  //           enableAlpha: false,
  //           paletteType: PaletteType.hsv,
  //           pickerAreaBorderRadius:
  //               const BorderRadius.all(Radius.circular(20))));
  // }
}
