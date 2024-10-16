import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
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
  @override
  State<CriarGastosFixos> createState() => _CriarGastosFixos();
}

class _CriarGastosFixos extends State<CriarGastosFixos> {
  late MoneyMaskedTextController valorController;
  final descricaoController = TextEditingController();
  int lastIndexSelected = 0;
  List<FixedExpense> _fixedExpenses = [];

  @override
  void didChangeDependencies() {
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

  final TextEditingController _dateController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late int lastDateSelected = 1;
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
                    setState(() {
                      int selectedDay = index + 1; // Dia selecionado (1 a 31)
                      lastDateSelected = selectedDay;
                      _dateController.text =
                          'Dia $selectedDay'; // Atualiza o campo de texto
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
  }

  Future<void> _loadFixedExpenses() async {
    List<FixedExpense> expenses = await Fixedexpensesservice.getSortedFixedExpenses();
    setState(() {
      _fixedExpenses = expenses;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.background1,
        appBar: AppBar(
          backgroundColor: AppColors.background1,
          title: Text(
            'Criar Gastos Fixos',
            style: TextStyle(color: AppColors.label),
          ),
          iconTheme: IconThemeData(
            color: AppColors.label, // Cor da seta de voltar
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Column(
            children: [
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
                            placeholder: "Dia X",
                            placeholderStyle: const TextStyle(
                                color: AppColors.labelPlaceholder),
                            readOnly:
                                true, // Impede que o usuário edite diretamente
                            onTap:
                                _handleTap, // Chama o modal ao clicar no campo
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
                    Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: AppColors.buttonSelected,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        category.icon,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Translateservice.getTranslatedCategoryUsingModel(
                          context, category),
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: CupertinoButton(
                        color: CupertinoColors.systemBlue,
                        onPressed: () {
                          print(int.parse(_dateController.text
                              .replaceAll(RegExp(r'[^0-9]'), '')));
                          Fixedexpensesservice.addCard(FixedExpense(
                              description: descricaoController.text,
                              price: valorController.numberValue,
                              day: int.parse(_dateController.text
                                  .replaceAll(RegExp(r'[^0-9]'), '')),
                              category: category,
                              id: Uuid().v4()));
                          _loadFixedExpenses();
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
                              style: TextStyle(
                                  color: AppColors.label, fontSize: 16),
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
                                  description:
                                      _fixedExpenses[index].description,
                                  day: 
                                      _fixedExpenses[index].day,
                                  category: category),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ));
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
              setState(() {});
            },
          ),
        );
      },
    );
  }
}
