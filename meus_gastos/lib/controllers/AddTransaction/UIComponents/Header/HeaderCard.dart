import 'package:meus_gastos/l10n/app_localizations.dart';
import 'dart:io';
import 'package:meus_gastos/controllers/Purchase/ProModalAndroid.dart';
import 'package:meus_gastos/controllers/Transactions/ViewComponents/ListCardRecorrent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:meus_gastos/controllers/Purchase/ProModal.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/controllers/gastos_fixos/UI/criar_gastosFixos.dart';
import 'package:meus_gastos/controllers/gastos_fixos/fixedExpensesModel.dart';
import 'package:meus_gastos/controllers/gastos_fixos/fixedExpensesService.dart';
import 'package:meus_gastos/services/CardService.dart' as service;
import 'package:meus_gastos/controllers/CardDetails/DetailScreen.dart';
import 'package:meus_gastos/controllers/ads_review/BannerAdConstruct.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:meus_gastos/controllers/gastos_fixos/fixedExpensesService.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
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
  final Function(List<CategoryModel>) onCategoriesLoaded;
  final GlobalKey valueExpens;
  final GlobalKey date;
  final GlobalKey description;
  final GlobalKey categories;
  final GlobalKey addButon;

  const HeaderCard({
    required this.onAddClicked,
    required this.onAddCategory,
    required this.onCategoriesLoaded,
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
  DateTime lastDateSelected = DateTime.now();
  int lastIndexSelected = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // State for holding categories, populated by the child widget
  bool _isCategoriesLoaded = false;
  List<CategoryModel> _categories = [];

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
    final currencySymbol = TranslateService.getCurrencySymbol(context);
    valorController = MoneyMaskedTextController(
      leftSymbol: '$currencySymbol ',
      decimalSeparator: locale.languageCode == 'pt' ? ',' : '.',
      initialValue: 0.0,
    );
  }

  //mark - actions

  /// This method is passed to the VerticalCircleList widget to receive the loaded categories.
  void onCategoriesLoaded(List<CategoryModel> loadedCategories) {
    setState(() {
      _categories = loadedCategories;
      _isCategoriesLoaded = true;
    });
    // Pass the data up to the parent screen if needed
    widget.onCategoriesLoaded(loadedCategories);
  }

  /// Sets the selected category index from the child list.
  void onCategorySelected(int index) {
    setState(() {
      lastIndexSelected = index;
    });
  }

  void adicionar() async {
    if (!_isCategoriesLoaded) {
      // Show a toast or just ignore the click if categories aren't ready
      return;
    }

    if (Platform.isIOS) HapticFeedback.mediumImpact();

    // Check for out of bounds error
    if (lastIndexSelected >= _categories.length) {
      print("Error: Selected index is out of bounds.");
      return;
    }

    final selectedCategory = _categories[lastIndexSelected];

    final newCard = CardModel(
      amount: valorController.numberValue,
      description: descricaoController.text,
      date: lastDateSelected,
      category: selectedCategory, // Use the actual selected category
      id: CardService.generateUniqueId(),
    );

    CardService().addCard(newCard);
    await CategoryService().incrementCategoryFrequency(selectedCategory.id);

    setState(() {
      valorController.updateValue(0.0);
      descricaoController.clear();
    });

    Future.delayed(const Duration(milliseconds: 200), widget.onAddClicked);
  }

  Future<void> _showDatePicker() async {
    if (Platform.isIOS) HapticFeedback.lightImpact();
    await showModalBottomSheet<DateTime>(
      isScrollControlled: true,
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
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: TextStyle(color: CupertinoColors.systemGrey),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.dateAndHour,
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
                      'OK',
                      style: TextStyle(color: CupertinoColors.activeBlue),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: CupertinoTheme(
                data: const CupertinoThemeData(
                  brightness: Brightness.dark,
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle:
                        TextStyle(color: CupertinoColors.white),
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
