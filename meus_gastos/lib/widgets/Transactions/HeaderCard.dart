import 'package:flutter/cupertino.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'CampoComMascara.dart';
import 'HorizontalCircleList.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'ValorTextField.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'package:meus_gastos/models/CategoryModel.dart';

class HeaderCard extends StatefulWidget {
  final VoidCallback onAddClicked; // Delegate to notify the parent view
  final VoidCallback onAddCategory;
  final String adicionarButtonTitle; // Parameter to initialize the class

  HeaderCard(
      {required this.onAddClicked,
      required this.adicionarButtonTitle,
      required this.onAddCategory});

  @override
  _HeaderCardState createState() => _HeaderCardState();
}

class _HeaderCardState extends State<HeaderCard> {
  final valorController = MoneyMaskedTextController(
    leftSymbol: 'R\$ ',
    decimalSeparator: ',',
  );
  final descricaoController = TextEditingController();
  late CampoComMascara dateController = CampoComMascara(
      dateText: _getCurrentDate(),
      onCompletion: (DateTime dateTime) {
        lastDateSelected = dateTime;
      });

  DateTime lastDateSelected = DateTime.now();
  int lastIndexSelected = 0;
  List<CategoryModel> categorieList = [];
  @override
  void initState() {
    super.initState();

    loadCategories();
  }

  Future<void> loadCategories() async {
    await Future.delayed(Duration(seconds: 1));
    List<CategoryModel> aux = await CategoryService().getAllCategories();
    setState(() {
      categorieList = [];
    });
    print(CategoryService().printAllCategories());
    setState(() {
      categorieList = aux;
    });
  }

  void adicionar() async {
    print(" ----- ");
    print(lastIndexSelected);
    print(categorieList[lastIndexSelected].name);
    print(categorieList[lastIndexSelected].id);
    print(" ----- ");

    final newCard = CardModel(
        amount: valorController.numberValue,
        description: descricaoController.text,
        date: lastDateSelected,
        category: categorieList[lastIndexSelected],
        id: CardService.generateUniqueId());
    CardService.addCard(newCard);
    // CategoryService().updateFrequencyCategory(categorieList[lastIndexSelected]);
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
    String formattedDate =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year.toString().substring(2)} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return formattedDate;
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
              onItemSelected: (index) {
                if (categorieList[index].id == "AddCategory") {
                  widget.onAddCategory();
                  setState(() {
                    loadCategories();
                  });
                  print("adicionar");
                } else {
                  setState(() {
                    print(index);
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
