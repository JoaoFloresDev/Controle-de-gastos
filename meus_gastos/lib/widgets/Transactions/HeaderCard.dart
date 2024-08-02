import 'package:flutter/cupertino.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'CampoComMascara.dart';
import 'HorizontalCircleList.dart';
import 'ValorTextField.dart';

class HeaderCard extends StatefulWidget {
  final VoidCallback onAddClicked;
  final VoidCallback onAddCategory;
  final String adicionarButtonTitle;

  HeaderCard({
    required this.onAddClicked,
    required this.adicionarButtonTitle,
    required this.onAddCategory,
    Key? key,
  }) : super(key: key);

  @override
  HeaderCardState createState() => HeaderCardState();
}

class HeaderCardState extends State<HeaderCard> {
  final valorController = MoneyMaskedTextController(
    leftSymbol: 'R\$ ',
    decimalSeparator: ',',
  );
  final descricaoController = TextEditingController();
  late CampoComMascara dateController = CampoComMascara(
    dateText: _getCurrentDate(),
    onCompletion: (DateTime dateTime) {
      lastDateSelected = dateTime;
    },
  );

  final GlobalKey<HorizontalCircleListState> _horizontalCircleListKey =
      GlobalKey<HorizontalCircleListState>();

  DateTime lastDateSelected = DateTime.now();
  int lastIndexSelected = 0;

  @override
  void initState() {
    super.initState();
    // Inicializa as categorias quando o widget é criado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _horizontalCircleListKey.currentState?.loadCategories();
    });
  }

  Future<void> loadCategories() async {
    _horizontalCircleListKey.currentState?.loadCategories();
  }

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

    setState(() {
      valorController.updateValue(0.0);
      descricaoController.clear();
    });
    FocusManager.instance.primaryFocus?.unfocus();
    Future.delayed(Duration(milliseconds: 300), () {
      widget.onAddClicked();
    });
  }

  String _getCurrentDate() {
    DateTime now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year.toString().substring(2)} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
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
                  color: CupertinoColors.white,
                ),
              ),
            ),
            placeholder: 'Descrição',
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
