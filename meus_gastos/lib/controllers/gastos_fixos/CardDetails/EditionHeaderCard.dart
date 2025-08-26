import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/controllers/gastos_fixos/HorizontalCircleList.dart';
import 'package:meus_gastos/controllers/gastos_fixos/fixedExpensesModel.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:uuid/uuid.dart';
import '../fixedExpensesService.dart';
import 'package:meus_gastos/controllers/Transactions/InsertTransactions/ViewComponents/CampoComMascara.dart';
import 'package:meus_gastos/controllers/Transactions/InsertTransactions/ViewComponents/ValorTextField.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:meus_gastos/controllers/gastos_fixos/UI/RepetitionMenu.dart';

class EditionHeaderCard extends StatefulWidget {
  final VoidCallback onAddClicked;
  final String adicionarButtonTitle;
  final FixedExpense card;
  final bool botomPageIsVisible;
  const EditionHeaderCard(
      {super.key,
      required this.onAddClicked,
      required this.adicionarButtonTitle,
      required this.card,
      required this.botomPageIsVisible});

  @override
  _EditionHeaderCardState createState() => _EditionHeaderCardState();
}

class _EditionHeaderCardState extends State<EditionHeaderCard> {
  late TextEditingController descricaoController;
  late MoneyMaskedTextController valorController;
  late CampoComMascara dateController;
  late FocusNode descricaoFocusNode;

  List<CategoryModel> categorieList = [];
  final DateTime dataInicial = DateTime.now();
  final double valorInicial = 0.0;
  late int lastIndexSelected_category = 0;
  List<CategoryModel> icons_list_recorrent = [];
  late bool _isPaga;

  late DateTime _selectedDate = widget.card.date;
  String tipoRepeticao = "";

  Future<void> loadCategories() async {
    var categorieList = await CategoryService().getAllCategoriesAvaliable();
    if (categorieList.isNotEmpty) {
      icons_list_recorrent = categorieList.sublist(0, categorieList.length - 1);
      lastIndexSelected_category = icons_list_recorrent
          .indexWhere((category) => category.id == widget.card.category.id);
      if (lastIndexSelected_category == -1) {
        lastIndexSelected_category = 0; // ou qualquer valor de fallback
      }
      setState(() {
        lastIndexSelected_category = lastIndexSelected_category;
        // Define um valor padrão se o item não for encontrado
      });
    }
    print(lastIndexSelected_category);
  }

  // MARK: - InitState
  @override
  void initState() {
    super.initState();
    _isPaga = false;

    descricaoController = TextEditingController(text: widget.card.description);

    descricaoFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      descricaoFocusNode.requestFocus();
    });
    tipoRepeticao = widget.card.tipoRepeticao;
    loadCategories();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);

    valorController = MoneyMaskedTextController(
      leftSymbol: TranslateService.getCurrencySymbol(context),
      decimalSeparator: locale.languageCode == 'pt' ? ',' : '.',
      initialValue: widget.card.price,
    );

    final DateFormat formatter = DateFormat(
        AppLocalizations.of(context)!.dateFormat,
        Localizations.localeOf(context).toString());
    formatter.format(_selectedDate);

    dateController = CampoComMascara(
      currentDate: _selectedDate,
      onCompletion: (DateTime dateTime) {
        _selectedDate = dateTime;
      },
    );
  }

  void _toggleStatus() {
    setState(() {
      _isPaga = !_isPaga; // Alterna entre 'Paga' e 'Não Paga'.
    });
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

  // MARK: - Adicionar
  void adicionar() {
    print(icons_list_recorrent[lastIndexSelected_category].name);

    final newCard = FixedExpense(
      price: valorController.numberValue,
      description: descricaoController.text,
      date: _selectedDate,
      category: icons_list_recorrent[lastIndexSelected_category],
      id: widget.card.id,
      tipoRepeticao: tipoRepeticao,
    );
    Fixedexpensesservice.updateCard(widget.card.id, newCard);

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
          const SizedBox(height: 12),
          if (widget.botomPageIsVisible)
            RepetitionMenu(
              referenceDate: _selectedDate,
              onRepetitionSelected: (String selectedRepetition) {
                setState(() {
                  tipoRepeticao = selectedRepetition;

                  print(tipoRepeticao);
                });
              },
              defaultRepetition: widget.card.tipoRepeticao,
            ),
          const SizedBox(height: 12),
          HorizontalCircleList(
            onItemSelected: (index) {
              setState(() {
                lastIndexSelected_category = index;
              });
              print(lastIndexSelected_category);
            },
            icons_list_recorrent: icons_list_recorrent,
            defaultIndexCategory: lastIndexSelected_category ?? 0,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                color: AppColors.button,
                onPressed: () {
                  adicionar();
                  widget.onAddClicked;
                  // Fixedexpensesservice.printCardsInfo();
                },
                child: Text(
                  widget.adicionarButtonTitle,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.label),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
