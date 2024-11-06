import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/gastos_fixos/HorizontalCircleList.dart';
import 'package:meus_gastos/gastos_fixos/fixedExpensesModel.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:uuid/uuid.dart';
import '../fixedExpensesService.dart';
import 'package:meus_gastos/controllers/Transactions/InsertTransactions/ViewComponents/CampoComMascara.dart';
import 'package:meus_gastos/controllers/Transactions/InsertTransactions/ViewComponents/ValorTextField.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meus_gastos/services/TranslateService.dart';

class EditionHeaderCard extends StatefulWidget {
  final VoidCallback onAddClicked;
  final String adicionarButtonTitle;
  final FixedExpense card;
  final bool botomPageIsVisible;
  const EditionHeaderCard(
      {required this.onAddClicked,
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

  late int lastDateSelected = widget.card.day;
  List<CategoryModel> categorieList = [];
  final DateTime dataInicial = DateTime.now();
  final double valorInicial = 0.0;
  late int lastIndexSelected_category;
  List<CategoryModel> icons_list_recorrent = [];
  late bool _isPaga;

  Future<void> loadCategories() async {
    var categorieList = await CategoryService().getAllCategories();
    if (categorieList.isNotEmpty) {
      setState(() {
        icons_list_recorrent =
            categorieList.sublist(0, categorieList.length - 1);
        lastIndexSelected_category = icons_list_recorrent.indexWhere(
          (category) => category.id == widget.card.category.id);
      
      // Define um valor padrão se o item não for encontrado
      if (lastIndexSelected_category == -1) {
        lastIndexSelected_category = 0; // ou qualquer valor de fallback
      }

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
    loadCategories();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);

    valorController = MoneyMaskedTextController(
      leftSymbol: Translateservice.getCurrencySymbol(context),
      decimalSeparator: locale.languageCode == 'pt' ? ',' : '.',
      initialValue: widget.card.price,
    );
  }

  void _toggleStatus() {
    setState(() {
      _isPaga = !_isPaga; // Alterna entre 'Paga' e 'Não Paga'.
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
                  scrollController: FixedExtentScrollController(
                      initialItem: widget.card.day - 1),
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
    if (_isPaga) {
      final newCard = CardModel(
        amount: valorController.numberValue,
        description: descricaoController.text,
        date: DateTime(
            DateTime.now().year, DateTime.now().month, lastDateSelected),
        category: icons_list_recorrent[lastIndexSelected_category],
        id: widget.card.id,
      );
      CardService.addCard(newCard);
    } else {
      final newCard = FixedExpense(
        price: valorController.numberValue,
        description: descricaoController.text,
        day: lastDateSelected,
        category: icons_list_recorrent[lastIndexSelected_category],
        id: Uuid().v4(),
      );
      Fixedexpensesservice.updateCard(widget.card.id, newCard);
    }

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
                child: CupertinoTextField(
                  controller: _dateController,
                  focusNode: _focusNode,
                  style: const TextStyle(color: AppColors.label),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.label)),
                  ),
                  placeholder: "Dia ${lastDateSelected}",
                  placeholderStyle:
                      const TextStyle(color: AppColors.labelPlaceholder),
                  readOnly: true, // Impede que o usuário edite diretamente
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
          if (widget.botomPageIsVisible)
            ElevatedButton(
              onPressed: _toggleStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPaga ? Colors.green : Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(
                _isPaga ? 'Paga' : 'Não Paga',
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CupertinoButton(
              color: AppColors.button,
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
