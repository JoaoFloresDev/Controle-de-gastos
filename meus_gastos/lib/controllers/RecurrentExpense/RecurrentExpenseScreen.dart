import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:meus_gastos/designSystem/Components/CustomHeader.dart';
import 'CardDetailsScreen/DetailScreen.dart';
import 'package:meus_gastos/controllers/AddTransaction/UIComponents/Header/ValorTextField.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/fixedExpensesModel.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/FixedExpensesViewModel.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import 'UI/ExpensesList.dart';
import 'UI/FormSection.dart';

class RecurrentExpenseScreen extends StatefulWidget {
  const RecurrentExpenseScreen(
      {super.key,
      required this.onAddPressedBack,
      required this.fixedExpensesViewModel,
      required this.categories});

  final VoidCallback onAddPressedBack;
  final FixedExpensesViewModel fixedExpensesViewModel;
  final List<CategoryModel> categories;

  @override
  State<RecurrentExpenseScreen> createState() => _RecurrentExpenseScreenState();
}

class _RecurrentExpenseScreenState extends State<RecurrentExpenseScreen> {
  late MoneyMaskedTextController valueController;
  final descriptionController = TextEditingController();

  int selectedCategoryIndex = 0;
  String repetitionType = "monthly";
  String additionType = "automatic";
  DateTime selectedDate = DateTime.now();

  bool _isControllerInitialized = false;
  List<FixedExpense> fixedExpenses = [];

  final valueFieldKey = GlobalKey<ValorTextFieldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isControllerInitialized) {
      final locale = Localizations.localeOf(context);
      final currencySymbol = TranslateService.getCurrencySymbol(context);

      valueController = MoneyMaskedTextController(
        leftSymbol: currencySymbol,
        decimalSeparator: locale.languageCode == 'pt' ? ',' : '.',
        initialValue: 0.0,
      );
      _isControllerInitialized = true;
    }
  }

  @override
  void dispose() {
    valueController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _resetForm() {
    valueFieldKey.currentState?.clear();
    descriptionController.clear();
    setState(() {
      selectedDate = DateTime.now();
    });
  }

  Future<void> _saveExpense() async {
    FocusScope.of(context).unfocus();
    if (valueController.numberValue > 0) {
      print("repetitionType: $repetitionType");
      print("repetitionType: $additionType");
      await widget.fixedExpensesViewModel.addExpense(FixedExpense(
        description: descriptionController.text,
        price: valueController.numberValue,
        date: selectedDate,
        category: widget.categories[selectedCategoryIndex],
        id: const Uuid().v4(),
        repetitionType: repetitionType,
        additionType: additionType,
      ));

      _resetForm();
      widget.onAddPressedBack();
    }
  }

  void _showExpenseDetails(FixedExpense expense) {
    FocusScope.of(context).unfocus();
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height - 70,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: DetailScreen(
            card: expense,
            onDeleteCliked: (card) {
              widget.fixedExpensesViewModel.delete(card);
            },
            updateCard: (card) {
              widget.fixedExpensesViewModel.update(card);
            },
            onAddClicked: () {
              setState(() {
                widget.onAddPressedBack();
              });
            },
            categories: widget.categories,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    fixedExpenses =
        widget.fixedExpensesViewModel.fixedExpenses.reversed.toList();
    if (!_isControllerInitialized) {
      return const Center(child: CupertinoActivityIndicator());
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background1,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            CustomHeader(
              title: AppLocalizations.of(context)!.repeat,
              onCancelPressed: () => Navigator.of(context).pop(),
              onDeletePressed: () {},
              showDeleteButton: false,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    FormSection(
                      valorFieldKey: valueFieldKey,
                      valorController: valueController,
                      descricaoController: descriptionController,
                      selectedDate: selectedDate,
                      repetitionType: repetitionType,
                      tipoAdicao: additionType,
                      icons_list_recorrent: widget.categories,
                      lastIndexSelected_category: selectedCategoryIndex,
                      onDateChanged: (newDate) {
                        setState(() => selectedDate = newDate);
                      },
                      onRepetitionChanged: (selectedRepetition) {
                        setState(() => repetitionType = selectedRepetition);
                      },
                      onAdditionTypeChanged: (selectedType) {
                        setState(() => additionType = selectedType);
                      },
                      onCategoryChanged: (index) {
                        setState(() => selectedCategoryIndex = index);
                      },
                      onAddPressed: _saveExpense,
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Divider(
                        color: Colors.grey,
                        thickness: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ExpensesList(
                      fixedExpenses: fixedExpenses,
                      onExpenseTap: _showExpenseDetails,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
