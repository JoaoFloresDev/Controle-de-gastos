import 'package:flutter/cupertino.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:meus_gastos/controllers/CategoryCreater/CetegoryViewModel.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'CampoComMascara.dart';
import 'HorizontalCircleList.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/controllers/AddTransaction/UIComponents/Header/ValorTextField.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/services/TranslateService.dart';

class HeaderCard extends StatefulWidget {
  final VoidCallback onAddClicked;
  final VoidCallback onAddCategory;

  final GlobalKey valueExpens;
  final GlobalKey date;
  final GlobalKey description;
  final GlobalKey categories;
  final GlobalKey addButon;
  final CategoryViewModel categoryVM;
  // final String adicionarButtonTitle;

  const HeaderCard({
    // required this.adicionarButtonTitle,
    required this.onAddClicked,
    required this.onAddCategory,
    required super.key,
    required this.valueExpens,
    required this.date,
    required this.description,
    required this.categories,
    required this.addButon,
    required this.categoryVM,
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
  // User? user;

  final GlobalKey<HorizontalCircleListState> _horizontalCircleListKey =
      GlobalKey<HorizontalCircleListState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      // user = FirebaseAuth.instance.currentUser;
    });
    // update date format based in atuality configs
    final locale = Localizations.localeOf(context);
    final currencySymbol = TranslateService.getCurrencySymbol(context);

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
    setState(() {
      // user = FirebaseAuth.instance.currentUser;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _horizontalCircleListKey.currentState?.loadCategories();
    });
  }

  // MARK: - Load Categories
  Future<void> loadCategories() async {
    _horizontalCircleListKey.currentState?.loadCategories();
  }

  // MARK: - Adicionar
  void adicionar() async {
    final newCard = CardModel(
      amount: valorController.numberValue,
      description: descricaoController.text,
      date: lastDateSelected,
      category: (_horizontalCircleListKey.currentState?.categorieList ??
          [])[lastIndexSelected],
      id: CardService.generateUniqueId(),
    );
    // print("object");

    if (!(newCard.amount == 0)) CardService().addCard(newCard);

    // await CategoryService().incrementCategoryFrequency(
    //     (_horizontalCircleListKey.currentState?.categorieList ??
    //             [])[lastIndexSelected]
    //         .id);
    // CategoryService().printAllCategories();
    setState(() {
      _horizontalCircleListKey.currentState?.loadCategories();
      _horizontalCircleListKey.currentState?.selectedIndex = 0;
      valorController.updateValue(0.0);
      descricaoController.clear();
      lastIndexSelected = 0;
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
              child: HorizontalCircleList(
                key: _horizontalCircleListKey,
                onItemSelected: (index) {
                  final categorieList =
                      _horizontalCircleListKey.currentState?.categorieList ??
                          [];
                  if (categorieList[index].id == 'AddCategory') {
                    widget.onAddCategory();
                    _horizontalCircleListKey.currentState?.loadCategories();
                  } else {
                    setState(() {
                      lastIndexSelected = index;
                    });
                  }
                },
                defaultdIndexCategory: 0,
                categories: widget.categoryVM.avaliebleCetegories,
              ),
            ),
            const SizedBox(height: 6),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                width: double
                    .infinity, // Define a largura para ocupar toda a área disponível
                child: CupertinoButton(
                  key: widget.addButon,
                  color: CupertinoColors.systemBlue,
                  onPressed: () {
                    setState(() {
                      // user = FirebaseAuth.instance.currentUser;
                    });
                    adicionar();
                  },
                  child: Text(
                    AppLocalizations.of(context)!.add,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors
                          .white, // Cor do texto definida como branca
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
