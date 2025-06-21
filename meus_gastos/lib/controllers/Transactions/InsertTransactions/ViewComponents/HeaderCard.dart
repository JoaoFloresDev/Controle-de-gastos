import 'package:flutter/cupertino.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'CampoComMascara.dart';
// VerticalCircleList - Nova versão vertical
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'ValorTextField.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:meus_gastos/controllers/AddTransaction/VerticalCircleList.dart';
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

class HeaderCardState extends State<HeaderCard> {
  late MoneyMaskedTextController valorController;
  late CampoComMascara dateController;
  final descricaoController = TextEditingController();
  DateTime lastDateSelected = DateTime.now();
  int lastIndexSelected = 0;

  final GlobalKey<VerticalCircleListState> _verticalCircleListKey =
      GlobalKey<VerticalCircleListState>(); // Alterado para VerticalCircleListState

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // update date format based in atuality configs
    final locale = Localizations.localeOf(context);
    final currencySymbol = Translateservice.getCurrencySymbol(context);

    valorController = MoneyMaskedTextController(
      leftSymbol: currencySymbol,
      decimalSeparator: locale.languageCode == 'pt' ? ',' : '.',
      initialValue: 0.0,
    );

    final DateFormat formatter = DateFormat(
        AppLocalizations.of(context)!.dateFormat,
        Localizations.localeOf(context).toString());
    formatter.format(lastDateSelected);

    dateController = CampoComMascara(
      currentDate: lastDateSelected,
      onCompletion: (DateTime dateTime) {
        lastDateSelected = dateTime;
      },
    );
  }

  // MARK: - InitState
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verticalCircleListKey.currentState?.loadCategories();
    });
  }

  // MARK: - Load Categories
  Future<void> loadCategories() async {
    _verticalCircleListKey.currentState?.loadCategories();
  }

  // MARK: - Adicionar
  void adicionar() async {
    final newCard = CardModel(
      amount: valorController.numberValue,
      description: descricaoController.text,
      date: lastDateSelected,
      category: (_verticalCircleListKey.currentState?.categorieList ??
          [])[lastIndexSelected],
      id: CardService.generateUniqueId(),
    );
    if (!(newCard.amount == 0)) CardService.addCard(newCard);

    await CategoryService.incrementCategoryFrequency(
        (_verticalCircleListKey.currentState?.categorieList ??
                [])[lastIndexSelected]
            .id);
    CategoryService().printAllCategories();
    setState(() {
      _verticalCircleListKey.currentState?.loadCategories();
      valorController.updateValue(0.0);
      descricaoController.clear();
    });
    FocusManager.instance.primaryFocus?.unfocus();
    Future.delayed(const Duration(milliseconds: 300), () {
      widget.onAddClicked();
    });
  }

  // MARK: - Build Method
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  key: widget.valueExpens,
                  child: ValorTextField(controller: valorController),
                ),
                const SizedBox(width: 8),
                Expanded(
                  key: widget.date,
                  child: dateController,
                ),
              ],
            ),
            const SizedBox(height: 8),
            CupertinoTextField(
              key: widget.description,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.white,
                  ),
                ),
              ),
              placeholder: AppLocalizations.of(context)!.description,
              placeholderStyle:
                  TextStyle(color: CupertinoColors.white.withOpacity(0.5)),
              style: const TextStyle(color: CupertinoColors.white),
              controller: descricaoController,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            Container(
              key: widget.categories,
              margin: EdgeInsets.zero,
              height: 350, // Altura definida para a lista vertical
              child: VerticalCircleList( // Alterado para VerticalCircleList
                key: _verticalCircleListKey,
                onItemSelected: (index) {
                  final categorieList =
                      _verticalCircleListKey.currentState?.categorieList ??
                          [];
                  if (categorieList[index].id == 'AddCategory') {
                    widget.onAddCategory();
                    _verticalCircleListKey.currentState?.loadCategories();
                  } else {
                    setState(() {
                      lastIndexSelected = index;
                    });
                  }
                },
                defaultdIndexCategory: 0,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  key: widget.addButon,
                  color: CupertinoColors.systemBlue,
                  onPressed: () {
                    adicionar();
                  },
                  child: Text(
                    AppLocalizations.of(context)!.add,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}