import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/designSystem/Components/CustomHeader.dart';
import 'package:meus_gastos/gastos_fixos/HorizontalCircleList.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'CardDetails/DetailScreen.dart';
import 'ListCard.dart';
import 'package:meus_gastos/controllers/Transactions/InsertTransactions/ViewComponents/ValorTextField.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:meus_gastos/gastos_fixos/fixedExpensesModel.dart';
import 'package:meus_gastos/gastos_fixos/fixedExpensesService.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

class CriarGastosFixos extends StatefulWidget {
  CriarGastosFixos({
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

  List<FixedExpense> _fixedExpenses = [];

  List<CategoryModel> icons_list_recorrent = [];
  // CategoryModel(
  //   id: '1',
  //   color: Colors.blue,
  //   icon: Icons.water_drop,
  //   name: 'Água',
  // ),
  // CategoryModel(
  //   id: '2',
  //   color: Colors.yellow,
  //   icon: Icons.lightbulb,
  //   name: 'Luz',
  // ),
  // CategoryModel(
  //   id: '3',
  //   color: Colors.green,
  //   icon: Icons.account_balance_wallet,
  //   name: 'PIX',
  // ),
  // CategoryModel(
  //   id: '4',
  //   color: Colors.orange,
  //   icon: Icons.home,
  //   name: 'Aluguel',
  // ),
  // CategoryModel(
  //   id: '5',
  //   color: Colors.grey,
  //   icon: Icons.apartment,
  //   name: 'Condomínio',
  // ),
  // CategoryModel(
  //   id: '6',
  //   color: Colors.red,
  //   icon: Icons.local_gas_station,
  //   name: 'Combustível',
  // ),
  // CategoryModel(
  //   id: '7',
  //   color: Colors.purple,
  //   icon: Icons.wifi,
  //   name: 'Internet',
  // ),
  // CategoryModel(
  //   id: '8',
  //   color: Colors.pink,
  //   icon: Icons.phone,
  //   name: 'Telefone',
  // ),
  // CategoryModel(
  //   id: '9',
  //   color: Colors.brown,
  //   icon: Icons.tv,
  //   name: 'TV por assinatura',
  // ),
  // CategoryModel(
  //   id: '10',
  //   color: Colors.teal,
  //   icon: Icons.credit_card,
  //   name: 'Cartão de crédito',
  // ),

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
    var categorieList = await CategoryService().getAllCategories();
    setState(() {
      icons_list_recorrent = categorieList.sublist(0, categorieList.length - 1);
    });
  }

  final TextEditingController _dateController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  void _handleTap() {
    _focusNode.unfocus(); // Fecha o teclado, se estiver aberto
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: Colors.white, // Defina a cor do fundo do modal
          child: Column(
            children: <Widget>[
              Container(
                height: 200,
                child: CupertinoPicker(
                  itemExtent: 32.0, // Altura de cada item
                  onSelectedItemChanged: (int index) {
                    print(index);
                    setState(() {
                      if ((0 <= index) && (index <= 31)) {
                        int selectedDay = index + 1;
                        lastIndexSelected_day = selectedDay;
                        print(lastIndexSelected_day);
                        _dateController.text =
                            'Dia $lastIndexSelected_day'; // Atualiza o campo de texto
                      }
                    });
                  },
                  children: List<Widget>.generate(31, (int index) {
                    return Center(
                      child:
                          Text('Dia ${index + 1}'), // Mostra os dias de 1 a 31
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  CategoryModel category = CategoryModel(
      id: Uuid().v4(),
      color: Colors.yellow,
      icon: Icons.event_repeat_rounded,
      name: "Recorrente");

  @override
  void initState() {
    super.initState(); // Necessário no initState
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
        decoration: BoxDecoration(
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
              padding: const EdgeInsets.all(0.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ValorTextField(controller: valorController),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CupertinoTextField(
                          controller: _dateController,
                          focusNode: _focusNode,
                          style: const TextStyle(color: AppColors.label),
                          decoration: const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(color: AppColors.label)),
                          ),
                          placeholder: "Dia ${lastIndexSelected_day}",
                          placeholderStyle: const TextStyle(
                              color: AppColors.labelPlaceholder),
                          readOnly:
                              true, // Impede que o usuário edite diretamente
                          onTap: _handleTap, // Chama o modal ao clicar no campo
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
                  const SizedBox(height: 24),
                  HorizontalCircleList(
                    onItemSelected: (index) {
                      setState(() {
                        lastIndexSelected_category = index;
                      });
                      print(lastIndexSelected_category);
                    },
                    icons_list_recorrent: icons_list_recorrent,
                    defaultIndexCategory: 0,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: CupertinoButton(
                      color: AppColors.button,
                      onPressed: () async {
                        print(icons_list_recorrent[lastIndexSelected_category].name);
                        await Fixedexpensesservice.addCard(FixedExpense(
                            description: descricaoController.text,
                            price: valorController.numberValue,
                            day: lastIndexSelected_day,
                            category: icons_list_recorrent[
                                lastIndexSelected_category],
                            id: Uuid().v4()));
                        setState(() {
                          widget.onAddPressedBack();
                          _loadFixedExpenses();
                        });
                        print(_fixedExpenses.isEmpty);
                      },
                      child: Text(
                        AppLocalizations.of(context)!.add,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // List of fixed expens
            _fixedExpenses.isEmpty
                ? Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, bottom: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 80), // Espaçamento acima do ícone
                          Icon(
                            Icons.inbox,
                            color: AppColors.card,
                            size: 60,
                          ),
                          const SizedBox(
                              height: 16), // Espaçamento entre ícone e texto
                          Text(
                            AppLocalizations.of(context)!.addNewTransactions,
                            style:
                                TextStyle(color: AppColors.label, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: _fixedExpenses.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          child: ListCardFixeds(
                            onTap: (card) {
                              _showCupertinoModalBottomSheet(context, card);
                            },
                            card: FixedExpense(
                              id: _fixedExpenses[index].id,
                              price: _fixedExpenses[index].price,
                              description: _fixedExpenses[index].description,
                              day: _fixedExpenses[index].day,
                              category: _fixedExpenses[index].category,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _showCupertinoModalBottomSheet(BuildContext context, FixedExpense card) {
    FocusScope.of(context).unfocus();
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height / 1.05,
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
              print("Apagou");
              setState(() {
                widget.onAddPressedBack();
              });
            },
          ),
        );
      },
    );
  }
}
