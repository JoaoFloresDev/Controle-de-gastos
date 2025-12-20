import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/UI/HorizontalCircleList.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/fixedExpensesModel.dart';
import 'package:meus_gastos/controllers/CardDetails/ViewComponents/CampoComMascara.dart';
import 'package:meus_gastos/controllers/AddTransaction/UIComponents/Header/ValorTextField.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/UI/RepetitionMenu.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/UI/AdditionTypeSelector.dart';

class EditionHeaderCard extends StatefulWidget {
  final Function(FixedExpense) onAddClicked;
  final String adicionarButtonTitle;
  final FixedExpense card;
  final bool botomPageIsVisible;
  final List<CategoryModel> categoryList;
  const EditionHeaderCard(
      {super.key,
      required this.onAddClicked,
      required this.adicionarButtonTitle,
      required this.card,
      required this.botomPageIsVisible,
      required this.categoryList});

  @override
  _EditionHeaderCardState createState() => _EditionHeaderCardState();
}

class _EditionHeaderCardState extends State<EditionHeaderCard> {
  late TextEditingController descricaoController;
  late MoneyMaskedTextController valorController;
  late CampoComMascara dateController;
  late FocusNode descricaoFocusNode;

  List<CategoryModel> icons_list_recorrent = [];
  final DateTime dataInicial = DateTime.now();
  final double valorInicial = 0.0;
  late int lastIndexSelected_category = 0;
  late bool _isPaga;

  late DateTime _selectedDate = widget.card.date;
  String repetitionType = "";
  String tipoAdicao = "";

  Future<void> loadCategories() async {
    // TÁ ERRADO
    if (widget.categoryList.isNotEmpty) {
      setState(() {
        icons_list_recorrent =
            widget.categoryList;
        lastIndexSelected_category = icons_list_recorrent
            .indexWhere((category) => category.id == widget.card.category.id);

        // Define um valor padrão se o item não for encontrado
        if (lastIndexSelected_category == -1) {
          lastIndexSelected_category = 0; // ou qualquer valor de fallback
        }
      });
    }
    // print(lastIndexSelected_category);
  }

  // MARK: - InitState
  @override
  void initState() {
    super.initState();
    _isPaga = false;

    descricaoController = TextEditingController(text: widget.card.description);

    descricaoFocusNode = FocusNode();

    repetitionType = widget.card.repetitionType;
    tipoAdicao = widget.card.additionType ?? 'suggestion';
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
      repetitionType: repetitionType,
      additionType: tipoAdicao,
    );
    // FixedExpensesService.updateCard(widget.card.id, newCard);

    Future.delayed(const Duration(milliseconds: 300), () {
      widget.onAddClicked(newCard);
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
                  repetitionType = selectedRepetition;

                  print(repetitionType);
                });
              },
              defaultRepetition: widget.card.repetitionType,
            ),
          const SizedBox(height: 12),
          if (widget.botomPageIsVisible)
            AdditionTypeSelector(
              selectedType: tipoAdicao,
              onTypeSelected: (String selectedType) {
                setState(() {
                  tipoAdicao = selectedType;
                });
              },
            ),
          const SizedBox(height: 12),
          HorizontalCircleList(
            onItemSelected: (index) {
              setState(() {
                lastIndexSelected_category = index;
              });
              // print(lastIndexSelected_category);
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
