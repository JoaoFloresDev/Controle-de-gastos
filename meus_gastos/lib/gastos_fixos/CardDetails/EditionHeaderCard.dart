import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/gastos_fixos/fixedExpensesModel.dart';
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

  late int lastDateSelected = widget.card.day;
  List<CategoryModel> categorieList = [];
  final DateTime dataInicial = DateTime.now();
  final double valorInicial = 0.0;

  // MARK: - InitState
  @override
  void initState() {
    super.initState();

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

    valorController = MoneyMaskedTextController(
      leftSymbol: Translateservice.getCurrencySymbol(context),
      decimalSeparator: locale.languageCode == 'pt' ? ',' : '.',
      initialValue: widget.card.price,
    );
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
                  scrollController: FixedExtentScrollController(initialItem: widget.card.day-1),
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
    final newCard = FixedExpense(
      price: valorController.numberValue,
      description: descricaoController.text,
      day: lastDateSelected,
      category: widget.card.category,
      id: Uuid().v4(),
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
                      widget.card.category.icon,
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
