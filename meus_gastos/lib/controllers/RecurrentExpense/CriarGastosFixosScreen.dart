import 'package:meus_gastos/controllers/CardDetails/ViewComponents/CampoComMascara.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
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
import 'UI/RepetitionMenu.dart';
// import 'UI/AdditionTypeSelector.dart';
import 'fixedExpensesModel.dart';
// import 'UI/FormSection.dart';
// import 'UI/ExpensesList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:meus_gastos/controllers/AddTransaction/UIComponents/Header/ValorTextField.dart';
import 'package:meus_gastos/controllers/CardDetails/ViewComponents/CampoComMascara.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/UI/HorizontalCircleList.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/UI/RepetitionMenu.dart';
// import 'package:meus_gastos/controllers/RecurrentExpense/UI/AdditionTypeSelector.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/UI/ListCardFixeds.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/fixedExpensesModel.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';

class AdditionTypeSelector extends StatelessWidget {
  const AdditionTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  final String selectedType;
  final ValueChanged<String> onTypeSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(
            selectedType == 'automatica' 
                ? CupertinoIcons.checkmark_circle_fill 
                : CupertinoIcons.lightbulb,
            color: CupertinoColors.white.withOpacity(0.7),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              selectedType == 'automatica'
                  ? "AppLocalizations.of(context)!.automaticAddition"
                  : "AppLocalizations.of(context)!.suggestion",
              style: TextStyle(
                color: CupertinoColors.white.withOpacity(0.9),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              _showActionSheet(context);
            },
            child: Row(
              children: [
                Text(
                  _getShortLabel(context),
                  style: const TextStyle(
                    color: AppColors.label,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  CupertinoIcons.chevron_down,
                  color: AppColors.label,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getShortLabel(BuildContext context) {
    return selectedType == 'automatica'
        ? "AppLocalizations.of(context)!.automatic"
        : "AppLocalizations.of(context)!.suggestion";
  }

  void _showActionSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text(
            "AppLocalizations.of(context)!.selectAdditionType",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          message: Text(
            "AppLocalizations.of(context)!.selectAdditionTypeDescription",
            style: const TextStyle(fontSize: 13),
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                onTypeSelected('automatica');
                Navigator.pop(context);
              },
              isDefaultAction: selectedType == 'automatica',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.checkmark_circle_fill,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text("AppLocalizations.of(context)!.automaticAddition"),
                ],
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                onTypeSelected('sugestao');
                Navigator.pop(context);
              },
              isDefaultAction: selectedType == 'sugestao',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.lightbulb,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text("AppLocalizations.of(context)!.suggestion"),
                ],
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            isDestructiveAction: true,
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        );
      },
    );
  }
}

class ExpensesList extends StatelessWidget {
  const ExpensesList({
    super.key,
    required this.fixedExpenses,
    required this.onExpenseTap,
  });

  final List<FixedExpense> fixedExpenses;
  final Function(FixedExpense) onExpenseTap;

  @override
  Widget build(BuildContext context) {
    if (fixedExpenses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(
            left: 16.0, right: 16.0, top: 20.0, bottom: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.inbox,
              color: AppColors.card,
              size: 40,
            ),
            Text(
              AppLocalizations.of(context)!.addNewTransactions,
              style: const TextStyle(
                color: AppColors.label,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.8,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        ...(fixedExpenses.map((expense) {
          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 2),
            child: ListCardFixeds(
              onTap: onExpenseTap,
              card: expense,
            ),
          );
        }).toList()),
        const SizedBox(height: 80),
      ],
    );
  }
}
class FormSection extends StatelessWidget {
  const FormSection({
    super.key,
    required this.valorFieldKey,
    required this.valorController,
    required this.descricaoController,
    required this.selectedDate,
    required this.tipoRepeticao,
    required this.tipoAdicao,
    required this.icons_list_recorrent,
    required this.lastIndexSelected_category,
    required this.onDateChanged,
    required this.onRepetitionChanged,
    required this.onAdditionTypeChanged,
    required this.onCategoryChanged,
    required this.onAddPressed,
  });

  final GlobalKey<ValorTextFieldState> valorFieldKey;
  final MoneyMaskedTextController valorController;
  final TextEditingController descricaoController;
  final DateTime selectedDate;
  final String tipoRepeticao;
  final String tipoAdicao;
  final List<CategoryModel> icons_list_recorrent;
  final int lastIndexSelected_category;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<String> onRepetitionChanged;
  final ValueChanged<String> onAdditionTypeChanged;
  final ValueChanged<int> onCategoryChanged;
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: 16.0, left: 16.0, right: 16.0, bottom: 0.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ValorTextField(
                  key: valorFieldKey,
                  controller: valorController,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CampoComMascara(
                  currentDate: selectedDate,
                  onCompletion: onDateChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CupertinoTextField(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: CupertinoColors.white,
                ),
              ),
            ),
            placeholder: AppLocalizations.of(context)!.description,
            placeholderStyle: TextStyle(
                color: CupertinoColors.white.withOpacity(0.5)),
            style: const TextStyle(color: CupertinoColors.white),
            controller: descricaoController,
          ),
          const SizedBox(height: 6),
          RepetitionMenu(
            referenceDate: selectedDate,
            onRepetitionSelected: onRepetitionChanged,
            defaultRepetition: tipoRepeticao,
          ),
          const SizedBox(height: 6),
          AdditionTypeSelector(
            selectedType: tipoAdicao,
            onTypeSelected: onAdditionTypeChanged,
          ),
          HorizontalCircleList(
            onItemSelected: onCategoryChanged,
            icons_list_recorrent: icons_list_recorrent,
            defaultIndexCategory: lastIndexSelected_category,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                color: AppColors.button,
                onPressed: onAddPressed,
                child: Text(
                  AppLocalizations.of(context)!.add,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.label),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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