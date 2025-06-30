import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import '../VerticalCircleList.dart';
import 'HeaderBar.dart';
import 'ValueInputSection.dart';
import 'DescriptionInputField.dart';

class HeaderCard extends StatefulWidget {
  final VoidCallback onAddClicked;
  final VoidCallback onAddCategory;
  final GlobalKey valueExpens;
  final GlobalKey date;
  final GlobalKey description;
  final GlobalKey categories;
  final GlobalKey addButon;

  const HeaderCard({
    required this.onAddClicked,
    required this.onAddCategory,
    required super.key,
    required this.valueExpens,
    required this.date,
    required this.description,
    required this.categories,
    required this.addButon,
  });

  @override
  HeaderCardState createState() => HeaderCardState();
}

class HeaderCardState extends State<HeaderCard> with TickerProviderStateMixin {
  //mark - variables
  late final MoneyMaskedTextController valorController;
  final descricaoController = TextEditingController();
  final GlobalKey<VerticalCircleListState> _verticalCircleListKey = GlobalKey();
  DateTime lastDateSelected = DateTime.now();
  int lastIndexSelected = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  //mark - lifecycle
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verticalCircleListKey.currentState?.loadCategories();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    valorController.dispose();
    descricaoController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    final currencySymbol = Translateservice.getCurrencySymbol(context);
    valorController = MoneyMaskedTextController(
      leftSymbol: '$currencySymbol ',
      decimalSeparator: locale.languageCode == 'pt' ? ',' : '.',
      initialValue: 0.0,
    );
  }

  //mark - actions
  Future<void> loadCategories() async {
    _verticalCircleListKey.currentState?.loadCategories();
  }

  void adicionar() async {
    if (Platform.isIOS) HapticFeedback.mediumImpact();
    final categories = _verticalCircleListKey.currentState?.categorieList ?? [];
    if (categories.isEmpty) return;
    final selectedCategory = categories[lastIndexSelected];
    final newCard = CardModel(
      amount: valorController.numberValue,
      description: descricaoController.text,
      date: lastDateSelected,
      category: selectedCategory,
      id: CardService.generateUniqueId(),
    );
    if (newCard.amount > 0) {
      CardService.addCard(newCard);
      await CategoryService.incrementCategoryFrequency(selectedCategory.id);
    }
    setState(() {
      valorController.updateValue(0.0);
      descricaoController.clear();
      _verticalCircleListKey.currentState?.loadCategories();
    });
    Future.delayed(const Duration(milliseconds: 200), widget.onAddClicked);
  }

  Future<void> _showDatePicker() async {
    if (Platform.isIOS) HapticFeedback.lightImpact();
    await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (ctx) => Container(
        height: 280,
        decoration: const BoxDecoration(
          color: CupertinoColors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.systemGrey.withOpacity(0.4),
                  ),
                ),
              ),
              child: Row(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: CupertinoColors.systemGrey),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: const Text(
                        'Data e Hora',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text(
                      '     OK',
                      style: TextStyle(color: CupertinoColors.activeBlue),
                    ),
                  ),
                ],
              ),
            ),
Expanded(
  child: CupertinoTheme(
    data: const CupertinoThemeData(
      brightness: Brightness.dark,
      textTheme: CupertinoTextThemeData(
        dateTimePickerTextStyle: TextStyle(color: CupertinoColors.white),
      ),
    ),
    child: CupertinoDatePicker(
      backgroundColor: CupertinoColors.black,
      initialDateTime: lastDateSelected,
      onDateTimeChanged: (newDate) {
        setState(() => lastDateSelected = newDate);
      },
      mode: CupertinoDatePickerMode.dateAndTime,
      use24hFormat: true,
    ),
  ),
),

          ],
        ),
      ),
    );
  }

  //mark - build
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HeaderBar(
            selectedDate: lastDateSelected,
            onDateTap: _showDatePicker,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ValueInputSection(
                  valueKey: widget.valueExpens,
                  controller: valorController,
                ),
                const SizedBox(height: 8),
                DescriptionInputField(
                  descriptionKey: widget.description,
                  controller: descricaoController,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
