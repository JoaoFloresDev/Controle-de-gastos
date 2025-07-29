import 'package:meus_gastos/controllers/Transactions/InsertTransactions/ViewComponents/CampoComMascara.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/designSystem/Components/CustomHeader.dart';
import 'package:meus_gastos/controllers/gastos_fixos/HorizontalCircleList.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import '../CardDetails/DetailScreen.dart';
import '../ListCardFixeds.dart';
import 'package:meus_gastos/controllers/Transactions/InsertTransactions/ViewComponents/ValorTextField.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:meus_gastos/controllers/gastos_fixos/fixedExpensesModel.dart';
import 'package:meus_gastos/controllers/gastos_fixos/fixedExpensesService.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import 'RepetitionMenu.dart';

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

  List<FixedExpense> _fixedExpenses = [];
  List<CategoryModel> icons_list_recorrent = [];

  // Variável para armazenar a data selecionada
  DateTime _selectedDate = DateTime.now();

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    // Atualiza o formato da data baseado nas configurações do usuário
    final locale = Localizations.localeOf(context);
    final currencySymbol = Translateservice.getCurrencySymbol(context);

    valorController = MoneyMaskedTextController(
      leftSymbol: currencySymbol,
      decimalSeparator: locale.languageCode == 'pt' ? ',' : '.',
      initialValue: 0.0,
    );
  }

  Future<void> loadCategories() async {
    var categorieList = await CategoryService().getAllCategoriesAvaliable();
    setState(() {
      icons_list_recorrent = categorieList.sublist(0, categorieList.length - 1);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadFixedExpenses();
    loadCategories();
  }

  Future<void> _loadFixedExpenses() async {
    List<FixedExpense> expenses =
        await Fixedexpensesservice.getSortedFixedExpenses();
    setState(() {
      _fixedExpenses = expenses;
    });
  }

  @override
  Widget build(BuildContext context) {
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
            Padding(
              padding: const EdgeInsets.only(
                  top: 16.0, left: 16.0, right: 16.0, bottom: 0.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ValorTextField(controller: valorController),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CampoComMascara(
                          currentDate: _selectedDate,
                          onCompletion: (DateTime newDate) {
                            setState(() {
                              _selectedDate = newDate;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.label,
                        ),
                      ),
                    ),
                    placeholder: AppLocalizations.of(context)!.description,
                    placeholderStyle:
                        TextStyle(color: AppColors.labelPlaceholder),
                    style: const TextStyle(color: AppColors.label),
                    controller: descricaoController,
                  ),
                  const SizedBox(height: 12),
                  RepetitionMenu(
                    referenceDate: _selectedDate,
                    onRepetitionSelected: (String selectedRepetition) {
                      setState(() {
                        tipoRepeticao = selectedRepetition;
                      });
                    },
                    defaultRepetition: 'mensal',
                  ),
                  const SizedBox(height: 12),
                  HorizontalCircleList(
                    onItemSelected: (index) {
                      setState(() {
                        lastIndexSelected_category = index;
                      });
                    },
                    icons_list_recorrent: icons_list_recorrent,
                    defaultIndexCategory: 0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        color: AppColors.button,
                        onPressed: () async {
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
                          setState(() {
                            widget.onAddPressedBack();
                            _loadFixedExpenses();
                          });
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
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
            ),
            SizedBox(
              height: 16,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(
                color: Colors.grey,
                thickness: 0.5,
              ),
            ),
            _fixedExpenses.isEmpty
                ? Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, bottom: 0.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          const Icon(
                            Icons.inbox,
                            color: AppColors.card,
                            size:
                                40, // Ícone levemente maior para maior impacto visual
                          ),
                          Text(
                            AppLocalizations.of(context)!.addNewTransactions,
                            style: const TextStyle(
                              color: AppColors.label,
                              fontSize:
                                  12, // Levemente maior para melhor leitura
                              fontWeight: FontWeight.w500,
                              height: 1.8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: _fixedExpenses.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListCardFixeds(
                            onTap: (card) {
                              _showCupertinoModalBottomSheet(context, card);
                            },
                            card: FixedExpense(
                              id: _fixedExpenses[index].id,
                              price: _fixedExpenses[index].price,
                              description: _fixedExpenses[index].description,
                              date: _fixedExpenses[index].date,
                              category: _fixedExpenses[index].category,
                              tipoRepeticao:
                                  _fixedExpenses[index].tipoRepeticao,
                            ),
                          ),
                        );
                      },
                    ),
                  )
          ],
        ),
      ),
    );
  }

  void _showCupertinoModalBottomSheet(BuildContext context, FixedExpense card) {
    print(card.tipoRepeticao);
    FocusScope.of(context).unfocus();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
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
            ),
          ),
        );
      },
    );
  }
}
