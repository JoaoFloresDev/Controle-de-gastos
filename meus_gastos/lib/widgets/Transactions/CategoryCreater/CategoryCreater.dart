import 'package:uuid/uuid.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class Categorycreater extends StatefulWidget {
  final VoidCallback onCategoryAdded;

  Categorycreater({super.key, required this.onCategoryAdded});

  @override
  State<Categorycreater> createState() => _CategorycreaterState();
}

class _CategorycreaterState extends State<Categorycreater> {
  late TextEditingController categoriaController;
  late Color _currentColor = Colors.black;
  final List<IconData> accountIcons = [
    Icons.account_balance,
    Icons.account_balance_wallet,
    Icons.account_box,
    Icons.account_circle,
    Icons.add_shopping_cart,
    Icons.attach_money,
    Icons.bar_chart,
    Icons.calculate,
    Icons.calendar_today,
    Icons.card_giftcard,
    Icons.card_membership,
    Icons.card_travel,
    Icons.check,
    Icons.check_box,
    Icons.check_circle,
    Icons.credit_card,
    Icons.dashboard,
    Icons.date_range,
    Icons.description,
    Icons.euro_symbol,
    Icons.monetization_on,
    Icons.money,
    Icons.payment,
    Icons.pie_chart,
    Icons.receipt,
    Icons.savings,
    Icons.show_chart,
    Icons.wallet,
  ];

  int selectedIndex = 0;

  // MARK: - Lifecycle Methods
  @override
  void initState() {
    super.initState();
    categoriaController = TextEditingController();
  }

  @override
  void dispose() {
    categoriaController.dispose();
    super.dispose();
  }

  // MARK: - Helper Methods
  void _hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _pickColor(BuildContext context) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              color: Colors.black54,
              child: GestureDetector(
                onTap: () {},
                child: CupertinoAlertDialog(
                  title: Text(
                    'Escolha a cor',
                    style: TextStyle(fontSize: 20),
                  ),
                  content: Container(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        buildColorPicker(),
                        TextButton(
                          child: Text(
                            'Selecionar',
                            style: const TextStyle(
                                color: Color.fromARGB(255, 0, 93, 168),
                                fontSize: 20),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget buildColorPicker() {
    return ColorPicker(
      pickerColor: _currentColor,
      onColorChanged: (Color color) {
        setState(() {
          _currentColor = color;
        });
      },
      showLabel: false,
      pickerAreaHeightPercent: 0.8,
      displayThumbColor: false,
      enableAlpha: false,
      paletteType: PaletteType.hsv,
    );
  }

  // MARK: - Add Category
  void adicionar() async {
    int frequency = 1;
    CategoryModel? categoryHighFrequency =
        await CardService.getCategoryWithHighestFrequency();
    if (categoryHighFrequency != null && categoryHighFrequency.id.isNotEmpty) {
      frequency = categoryHighFrequency.frequency + 1;
    }

    CategoryModel category = CategoryModel(
        id: Uuid().v4(),
        color: _currentColor,
        icon: accountIcons[selectedIndex],
        name: categoriaController.text,
        frequency: frequency);

    await CategoryService().addCategory(category);
    widget.onCategoryAdded(); // Notifica a view mãe
  }

  // MARK: - Build Method
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, // Remove o fundo branco
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            width: double.maxFinite,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Criar categoria',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _hideKeyboard,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                child: Column(
                  children: [
                    AddCategoryHorizontalCircleList(
                      onItemSelected: (index) {
                        selectedIndex = index;
                      },
                    ),
                    CupertinoTextField(
                      style: const TextStyle(
                        color: CupertinoColors.systemGrey5,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: CupertinoColors.systemGrey5,
                          ),
                        ),
                      ),
                      placeholder: "Categoria",
                      placeholderStyle: TextStyle(
                        color: const Color.fromARGB(144, 255, 255, 255)
                      ),
                      controller: categoriaController,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Text(
                          "Escolha a cor: ",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        const SizedBox(width: 15),
                        GestureDetector(
                          onTap: () => _pickColor(context),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _currentColor,
                              border: Border.all(
                                color: CupertinoColors.systemBlue,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            height: 30,
                            width: 30,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: CupertinoButton(
                        color: CupertinoColors.systemBlue,
                        onPressed: () {
                          if (categoriaController.text.isNotEmpty) {
                            adicionar();
                            Navigator.pop(context);
                          }
                        },
                        child: const Text(
                          "Adicionar Categoria",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class AddCategoryHorizontalCircleList extends StatefulWidget {
  final Function(int) onItemSelected;

  const AddCategoryHorizontalCircleList({
    Key? key,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  _AddCategoryHorizontalCircleListState createState() =>
      _AddCategoryHorizontalCircleListState();
}

class _AddCategoryHorizontalCircleListState
    extends State<AddCategoryHorizontalCircleList> {
  int selectedIndex = 0;
  int lastSelectedIndex = 0;

  final List<IconData> accountIcons = [
    Icons.account_balance,
    Icons.account_balance_wallet,
    Icons.account_box,
    Icons.account_circle,
    Icons.add_shopping_cart,
    Icons.attach_money,
    Icons.bar_chart,
    Icons.calculate,
    Icons.calendar_today,
    Icons.card_giftcard,
    Icons.card_membership,
    Icons.card_travel,
    Icons.check,
    Icons.check_box,
    Icons.check_circle,
    Icons.credit_card,
    Icons.dashboard,
    Icons.date_range,
    Icons.description,
    Icons.euro_symbol,
    Icons.monetization_on,
    Icons.money,
    Icons.payment,
    Icons.pie_chart,
    Icons.receipt,
    Icons.savings,
    Icons.show_chart,
    Icons.wallet,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: accountIcons.length,
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
                        ? Colors.grey.withOpacity(0.3)
                        : Colors.black.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(accountIcons[index]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
