import 'package:meus_gastos/controllers/CardDetails/ViewComponents/CampoComMascara.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:meus_gastos/designSystem/Components/CustomHeader.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/UI/HorizontalCircleList.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'CardDetails/DetailScreen.dart';
import 'UI/ListCardFixeds.dart';
import 'package:meus_gastos/controllers/AddTransaction/UIComponents/Header/ValorTextField.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/fixedExpensesModel.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/fixedExpensesService.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import 'UI/ExpensesList.dart';
import 'UI/FormSection.dart';

class CriarGastosFixos extends StatefulWidget {
  const CriarGastosFixos({
    super.key,
    required this.onAddPressedBack,
  });

  final VoidCallback onAddPressedBack;

  @override
  State<CriarGastosFixos> createState() => _CriarGastosFixos();
}

class _CriarGastosFixos extends State<CriarGastosFixos> {
  late MoneyMaskedTextController valorController;
  final descricaoController = TextEditingController();
  int lastIndexSelected_category = 0;
  int lastIndexSelected_day = 1;
  String tipoRepeticao = "mensal";
  String tipoAdicao = "automatica";
  bool _controllerInitialized = false;

  List<FixedExpense> _fixedExpenses = [];
  List<CategoryModel> icons_list_recorrent = [];

  DateTime _selectedDate = DateTime.now();

  final valorFieldKey = GlobalKey<ValorTextFieldState>();

  @override
  void initState() {
    super.initState();
    _loadFixedExpenses();
    loadCategories();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_controllerInitialized) {
      final locale = Localizations.localeOf(context);
      final currencySymbol = TranslateService.getCurrencySymbol(context);

      valorController = MoneyMaskedTextController(
        leftSymbol: currencySymbol,
        decimalSeparator: locale.languageCode == 'pt' ? ',' : '.',
        initialValue: 0.0,
      );
      _controllerInitialized = true;
    }
  }

  @override
  void dispose() {
    valorController.dispose();
    descricaoController.dispose();
    super.dispose();
  }

  Future<void> loadCategories() async {
    var categorieList = await CategoryService().getAllCategoriesAvaliable();
    setState(() {
      icons_list_recorrent = categorieList.sublist(0, categorieList.length - 1);
    });
  }

  Future<void> _loadFixedExpenses() async {
    List<FixedExpense> expenses =
        await Fixedexpensesservice.getSortedFixedExpenses();
    setState(() {
      _fixedExpenses = expenses;
    });
  }

  void _resetForm() {
    valorFieldKey.currentState?.clear();
    descricaoController.clear();
    setState(() {
      lastIndexSelected_category = 0;
      tipoRepeticao = "mensal";
      tipoAdicao = "automatica";
      _selectedDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_controllerInitialized) {
      return const Center(child: CupertinoActivityIndicator());
    }

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
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
              onCancelPressed: () {
                Navigator.of(context).pop();
              },
              onDeletePressed: () {},
              showDeleteButton: false,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    FormSection(
                      valorFieldKey: valorFieldKey,
                      valorController: valorController,
                      descricaoController: descricaoController,
                      selectedDate: _selectedDate,
                      tipoRepeticao: tipoRepeticao,
                      tipoAdicao: tipoAdicao,
                      icons_list_recorrent: icons_list_recorrent,
                      lastIndexSelected_category: lastIndexSelected_category,
                      onDateChanged: (DateTime newDate) {
                        setState(() {
                          _selectedDate = newDate;
                        });
                      },
                      onRepetitionChanged: (String selectedRepetition) {
                        setState(() {
                          tipoRepeticao = selectedRepetition;
                        });
                      },
                      onAdditionTypeChanged: (String selectedType) {
                        setState(() {
                          tipoAdicao = selectedType;
                        });
                      },
                      onCategoryChanged: (int index) {
                        setState(() {
                          lastIndexSelected_category = index;
                        });
                      },
                      onAddPressed: () async {
                        FocusScope.of(context).unfocus();

                        await Fixedexpensesservice.addCard(FixedExpense(
                          description: descricaoController.text,
                          price: valorController.numberValue,
                          date: _selectedDate,
                          category: icons_list_recorrent[
                              lastIndexSelected_category],
                          id: const Uuid().v4(),
                          tipoRepeticao: tipoRepeticao,
                        ));
                        _resetForm();
                        await _loadFixedExpenses();
                        widget.onAddPressedBack();

                        setState(() {});
                      },
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
                      fixedExpenses: _fixedExpenses,
                      onExpenseTap: (card) {
                        _showCupertinoModalBottomSheet(context, card);
                      },
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

  void _showCupertinoModalBottomSheet(BuildContext context, FixedExpense card) {
    print(card.tipoRepeticao);
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
            card: card,
            onAddClicked: () {
              _loadFixedExpenses();
              setState(() {
                widget.onAddPressedBack();
              });
            },
            // onDelete: () {
            //   _loadFixedExpenses();
            //   setState(() {
            //     widget.onAddPressedBack();
            //   });
            // },
          ),
        );
      },
    );
  }
}