import 'package:meus_gastos/controllers/ads_review/bannerAdconstruct.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'ViewComponents/CampoComMascara.dart';
import 'ViewComponents/HorizontalCircleList.dart';
import 'package:meus_gastos/controllers/CardDetails/ViewComponents/ValorTextField.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/services/TranslateService.dart';

class EditionHeaderCard extends StatefulWidget {
  final VoidCallback onAddClicked;
  final String adicionarButtonTitle;
  final CardModel card;

  const EditionHeaderCard({
    super.key,
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
  late int? lastIndexSelected;
  final DateTime dataInicial = DateTime.now();
  final double valorInicial = 0.0;
  bool isLoading = true;

  // MARK: - InitState
  @override
  void initState() {
    super.initState();
    _loadCategories();

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
      leftSymbol: TranslateService.getCurrencySymbol(context),
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

  Future<void> _loadCategories() async {
    await loadCategories();
  }

  // MARK: - Load Categories
  Future<void> loadCategories() async {
    categorieList = await CategoryService().getAllCategoriesAvaliable();
    CategoryService().printAllCategories();
    lastIndexSelected = categorieList
        .indexWhere((category) => category.id == widget.card.category.id);
    if (lastIndexSelected == -1) {
      lastIndexSelected = 0;
    }
    setState(() {
      lastIndexSelected = categorieList
          .indexWhere((category) => category.id == widget.card.category.id);
      print(lastIndexSelected);
      isLoading = false;
    });
  }

  // MARK: - Adicionar
  void adicionar() {
    final newCard = CardModel(
      amount: valorController.numberValue,
      description: descricaoController.text,
      date: lastDateSelected,
      category: categorieList[lastIndexSelected!],
      id: CardService.generateUniqueId(),
    );
    CardService().updateCard(widget.card.id, newCard);

    Future.delayed(const Duration(milliseconds: 300), () {
      widget.onAddClicked();
    });
  }

  // MARK: - Build Method
  @override
  Widget build(BuildContext context) {
    print(lastDateSelected);
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
                  color: AppColors.line,
                ),
              ),
            ),
            placeholder: AppLocalizations.of(context)!.description,
            placeholderStyle: const TextStyle(color: AppColors.line),
            controller: descricaoController,
            focusNode: descricaoFocusNode,
            style: const TextStyle(color: AppColors.label),
          ),
          const SizedBox(height: 24),
          if (isLoading) ...[
            LoadingContainer(),
          ] else ...[
            Container(
              margin: EdgeInsets.zero,
              child: HorizontalCircleList(
                onItemSelected: (index) {
                  setState(() {
                    lastIndexSelected = index;
                  });
                },
                defaultdIndexCategory: lastIndexSelected! ?? 0,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                color: AppColors.button,
                onPressed: adicionar,
                child: Text(
                  widget.adicionarButtonTitle,
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
    );
  }
}
