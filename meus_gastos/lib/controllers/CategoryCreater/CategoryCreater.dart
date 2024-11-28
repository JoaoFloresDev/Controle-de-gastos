import 'package:uuid/uuid.dart';
import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Categorycreater extends StatefulWidget {
  final VoidCallback onCategoryAdded;

  const Categorycreater({super.key, required this.onCategoryAdded});

  @override
  State<Categorycreater> createState() => _CategorycreaterState();
}

class _CategorycreaterState extends State<Categorycreater> {
  late TextEditingController categoriaController;
  late Color _currentColor = Colors.lightGreen;
  int selectedIndex = 0;

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
            color: Colors.transparent, // Fundo transparente ao redor do diálogo
            child: GestureDetector(
              onTap: () {},
              child: CupertinoAlertDialog(
                content: Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.chooseColor,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ColorPicker(
                        pickerColor: _currentColor,
                        onColorChanged: (Color color) {
                          setState(() {
                            _currentColor = color;
                          });
                        },
                        showLabel: false,
                        pickerAreaHeightPercent: 0.6,
                        displayThumbColor: false,
                        enableAlpha: false,
                        paletteType: PaletteType.hsv,
                        pickerAreaBorderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                      ),
                      SizedBox(
                        width: 160,
                        height: 40,
                        child: CupertinoButton(
                          color: AppColors.button, // Cor de fundo azul
                          borderRadius: BorderRadius.circular(
                              8.0), // Cantos ligeiramente arredondados
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0), // Tamanho do botão
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            AppLocalizations.of(context)!.select,
                            style: const TextStyle(
                              color: Colors.white, // Cor do texto branco
                              fontSize: 16.0, // Tamanho do texto
                              fontWeight: FontWeight.bold, // Texto em negrito
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildColorPicker() {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(8),
        child: ColorPicker(
            pickerColor: _currentColor,
            onColorChanged: (Color color) {
              setState(() {
                _currentColor = color;
              });
            },
            showLabel: false,
            pickerAreaHeightPercent: 0.6,
            displayThumbColor: false,
            enableAlpha: false,
            paletteType: PaletteType.hsv,
            pickerAreaBorderRadius: const BorderRadius.all(Radius.circular(20))));
  }

  // MARK: - Add Category
  void adicionar() async {
    int frequency = 2;
    CategoryModel? categoryHighFrequency =
        await CategoryService.getCategoryWithHighestFrequency();
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

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // MARK: - Build Method
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
                      AddCategoryHorizontalCircleList(
                        onItemSelected: (index) {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      CupertinoTextField(
                        style: const TextStyle(
                          color: AppColors.line,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.line,
                            ),
                          ),
                        ),
                        placeholder: AppLocalizations.of(context)!.category,
                        placeholderStyle: const TextStyle(
                            color: Color.fromARGB(144, 255, 255, 255)),
                        controller: categoriaController,
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Text(
                            "${AppLocalizations.of(context)!.chooseColor} ",
                            style:
                                const TextStyle(color: AppColors.label, fontSize: 20),
                          ),
                          const SizedBox(width: 15),
                          GestureDetector(
                            onTap: () => _pickColor(context),
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
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: CupertinoButton(
                          color: AppColors.button,
                          onPressed: () {
                            if (categoriaController.text.isNotEmpty) {
                              adicionar();
                              Navigator.pop(context);
                            }
                          },
                          child: Text(
                            AppLocalizations.of(context)!.addCategory,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
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
}

class AddCategoryHorizontalCircleList extends StatefulWidget {
  final Function(int) onItemSelected;

  const AddCategoryHorizontalCircleList({
    super.key,
    required this.onItemSelected,
  });

  @override
  _AddCategoryHorizontalCircleListState createState() =>
      _AddCategoryHorizontalCircleListState();
}

class _AddCategoryHorizontalCircleListState
    extends State<AddCategoryHorizontalCircleList> {
  int selectedIndex = 0;

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
