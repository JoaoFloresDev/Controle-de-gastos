import 'package:flutter/cupertino.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'CampoComMascara.dart';
import 'HorizontalCircleList.dart';
import 'ValorTextField.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/services/TranslateService.dart';

class HeaderCard extends StatefulWidget {
  final VoidCallback onAddClicked;
  final VoidCallback onAddCategory;

  // final String adicionarButtonTitle;

  HeaderCard({
    // required this.adicionarButtonTitle,
    required this.onAddClicked,
    required this.onAddCategory,
    Key? key,
  }) : super(key: key);

  @override
  HeaderCardState createState() => HeaderCardState();
}

class HeaderCardState extends State<HeaderCard> {
  late MoneyMaskedTextController valorController;
  late CampoComMascara dateController;
  final descricaoController = TextEditingController();
  DateTime lastDateSelected = DateTime.now();
  int lastIndexSelected = 0;

  final GlobalKey<HorizontalCircleListState> _horizontalCircleListKey =
      GlobalKey<HorizontalCircleListState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Atualiza o formato do valor e da data com base nas configurações atuais
    final locale = Localizations.localeOf(context);
    final currencySymbol = Translateservice.getCurrencySymbol(context);
    // final dateFormat = AppLocalizations.of(context)!.dateFormat;

    valorController = MoneyMaskedTextController(
      leftSymbol: currencySymbol,
      decimalSeparator: locale.languageCode == 'pt' ? ',' : '.',
      initialValue: 0.0,
    );

    final DateFormat formatter = DateFormat(
        AppLocalizations.of(context)!.dateFormat,
        Localizations.localeOf(context).toString());
    String formattedDate = formatter.format(lastDateSelected);

    dateController = CampoComMascara(
      dateText: formattedDate,
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
    CardService.addCard(newCard);

    CategoryService.incrementCategoryFrequency(
        (_horizontalCircleListKey.currentState?.categorieList ??
                [])[lastIndexSelected]
            .id);

    setState(() {
      valorController.updateValue(0.0);
      descricaoController.clear();
    });
    FocusManager.instance.primaryFocus?.unfocus();
    Future.delayed(Duration(milliseconds: 300), () {
      widget.onAddClicked();
    });
  }

  // MARK: - Get Current Date
  String _getCurrentDate() {
    DateTime now = DateTime.now();
    final locale = Intl.getCurrentLocale();
    String customDateFormat =
        DateFormat('dd-MM-yyyy', locale.toString()).format(now);
    return '$customDateFormat ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
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
              SizedBox(width: 8),
              Expanded(
                child: dateController,
              ),
            ],
          ),
          SizedBox(height: 8),
          CupertinoTextField(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: CupertinoColors.white,
                ),
              ),
            ),
            placeholder: AppLocalizations.of(context)!.description,
            placeholderStyle:
                TextStyle(color: CupertinoColors.white.withOpacity(0.5)),
            style: TextStyle(color: CupertinoColors.white),
            controller: descricaoController,
          ),
          SizedBox(height: 24),
          Container(
            margin: EdgeInsets.zero,
            child: HorizontalCircleList(
              key: _horizontalCircleListKey,
              onItemSelected: (index) {
                final categorieList =
                    _horizontalCircleListKey.currentState?.categorieList ?? [];
                if (categorieList[index].id == 'AddCategory') {
                  widget.onAddCategory();
                  _horizontalCircleListKey.currentState?.loadCategories();
                } else {
                  setState(() {
                    lastIndexSelected = index;
                  });
                }
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: CupertinoButton(
              color: CupertinoColors.systemBlue,
              onPressed: adicionar,
              child: Text(
                AppLocalizations.of(context)!.add,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
