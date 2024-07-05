import 'package:meus_gastos/enums/Category.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import '../CampoComMascara.dart';
import '../HorizontalCircleList.dart';
import '../ValorTextField.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'package:meus_gastos/models/CategoryModel.dart';

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

  @override
  void initState() {
    super.initState();

    loadCategories();

    descricaoController = TextEditingController(text: widget.card.description);
    valorController = MoneyMaskedTextController(
      leftSymbol: 'R\$ ',
      decimalSeparator: ',',
      initialValue: widget.card.amount,
    );
    DateTime date = widget.card.date;
    String formattedDate =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().substring(2)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    dateController = CampoComMascara(
        dateText: formattedDate,
        onCompletion: (DateTime dateTime) {
          lastDateSelected = dateTime;
        });

    descricaoFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      descricaoFocusNode.requestFocus();
    });
  }

  Future<void> loadCategories() async {
    categorieList = await CategoryService().getAllCategories();
    setState(() {});
  }

  @override
  void dispose() {
    descricaoController.dispose();
    valorController.dispose();
    descricaoFocusNode.dispose();
    super.dispose();
  }

  int lastIndexSelected = 0;
  final DateTime dataInicial = DateTime.now();
  final double valorInicial = 0.0;

  void adicionar() {
    final newCard = CardModel(
      amount: valorController.numberValue,
      description: descricaoController.text,
      date: lastDateSelected,
      category: categorieList[lastIndexSelected],
      id: CardService.generateUniqueId(),
    );
    CardService.updateCard(widget.card.id, newCard);

    Future.delayed(Duration(milliseconds: 300), () {
      widget.onAddClicked();
    });
  }

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
                  color: CupertinoColors.systemGrey5,
                ),
              ),
            ),
            placeholder: 'Descrição',
            placeholderStyle: TextStyle(color: CupertinoColors.systemGrey3),
            controller: descricaoController,
            focusNode: descricaoFocusNode,
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 16),
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
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: CupertinoButton(
              color: CupertinoColors.systemBlue,
              onPressed: adicionar,
              child: Text(
                widget.adicionarButtonTitle,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
