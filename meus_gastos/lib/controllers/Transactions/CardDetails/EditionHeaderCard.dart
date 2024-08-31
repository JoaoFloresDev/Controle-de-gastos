import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import '../InsertTransactions/ViewComponents/CampoComMascara.dart';
import '../InsertTransactions/ViewComponents/HorizontalCircleList.dart';
import '../InsertTransactions/ViewComponents/ValorTextField.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meus_gastos/services/TranslateService.dart';

class EditionHeaderCard extends StatefulWidget {
  final VoidCallback onAddClicked;
  final String adicionarButtonTitle;
  final CardModel card;

  const EditionHeaderCard({
    required this.onAddClicked,
    required this.adicionarButtonTitle,
    required this.card,
  });

  @override
  _EditionHeaderCardState createState() => _EditionHeaderCardState();
}

class _EditionHeaderCardState extends State<EditionHeaderCard> {
  late TextEditingController descricaoController;
  late MoneyMaskedTextController valorController;
  late CampoComMascara dateController;
  late FocusNode descricaoFocusNode;

  late DateTime lastDateSelected = widget.card.date;
  List<CategoryModel> categorieList = [];
  int lastIndexSelected = 0;
  final DateTime dataInicial = DateTime.now();
  final double valorInicial = 0.0;

  // MARK: - InitState
  @override
  void initState() {
    super.initState();
    loadCategories();

    descricaoController = TextEditingController(text: widget.card.description);

    descricaoFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      descricaoFocusNode.requestFocus();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    DateTime date = widget.card.date;

    // With that, acess AppLocalizations.of(context) is security
    DateFormat(AppLocalizations.of(context)!.dateFormat).format(date);

    valorController = MoneyMaskedTextController(
      leftSymbol: Translateservice.getCurrencySymbol(context),
      decimalSeparator: locale.languageCode == 'pt' ? ',' : '.',
      initialValue: widget.card.amount,
    );
    dateController = CampoComMascara(
      currentDate: lastDateSelected,
      onCompletion: (DateTime dateTime) {
        lastDateSelected = dateTime;
      },
    );
  }

  // MARK: - Dispose
  @override
  void dispose() {
    descricaoController.dispose();
    valorController.dispose();
    descricaoFocusNode.dispose();
    super.dispose();
  }

  // MARK: - Load Categories
  Future<void> loadCategories() async {
    categorieList = await CategoryService().getAllCategories();
    setState(() {});
  }

  // MARK: - Adicionar
  void adicionar() {
    final newCard = CardModel(
      amount: valorController.numberValue,
      description: descricaoController.text,
      date: lastDateSelected,
      category: categorieList[lastIndexSelected],
      id: CardService.generateUniqueId(),
    );
    CardService.updateCard(widget.card.id, newCard);

    Future.delayed(const Duration(milliseconds: 300), () {
      widget.onAddClicked();
    });
  }

  // MARK: - Build Method
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: ValorTextField(controller: valorController)),
              const SizedBox(width: 8),
              Expanded(
                child: dateController,
              ),
            ],
          ),
          const SizedBox(height: 8),
          CupertinoTextField(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: CupertinoColors.systemGrey5,
                ),
              ),
            ),
            placeholder: AppLocalizations.of(context)!.description,
            placeholderStyle:
                const TextStyle(color: CupertinoColors.systemGrey3),
            controller: descricaoController,
            focusNode: descricaoFocusNode,
            style: const TextStyle(color: AppColors.label),
          ),
          const SizedBox(height: 16),
          Container(
            margin: EdgeInsets.zero,
            child: HorizontalCircleList(
              onItemSelected: (index) {
                setState(() {
                  lastIndexSelected = index;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CupertinoButton(
              color: CupertinoColors.systemBlue,
              onPressed: adicionar,
              child: Text(
                widget.adicionarButtonTitle,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
