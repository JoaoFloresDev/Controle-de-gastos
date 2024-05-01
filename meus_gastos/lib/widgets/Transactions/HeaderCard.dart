import 'package:meus_gastos/enums/Category.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'CampoComMascara.dart';
import 'HorizontalCircleList.dart';
import 'package:meus_gastos/Scenes/InsertTransaction/InsertTransactions/models/CardModel.dart';
import 'ValorTextField.dart';
import 'package:meus_gastos/Scenes/InsertTransaction/InsertTransactions/services/CardService.dart';

class HeaderCard extends StatefulWidget {
  final VoidCallback onAddClicked; // Delegate to notify the parent view
  final String adicionarButtonTitle; // Parameter to initialize the class

  HeaderCard({required this.onAddClicked, required this.adicionarButtonTitle});

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

  void adicionar() {
    final newCard = CardModel(
        amount: valorController.numberValue,
        description: descricaoController.text,
        date: lastDateSelected,
        category: Category.values[lastIndexSelected].toString(),
        id: CardService.generateUniqueId());
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
    String formattedDate =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year.toString().substring(2)} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // FocusScope.of(context).unfocus();
        dispose();
      },
      child: Padding(
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
                    color: CupertinoColors
                        .systemGrey5, // Change the color of the bottom line
                  ),
                ),
              ),
              placeholder: 'Descrição',
              controller: descricaoController,
            ),
            SizedBox(height: 24),
            Container(
              margin: EdgeInsets.zero,
              child: HorizontalCircleList(
                onItemSelected: (index) {
                  setState(() {
                    lastIndexSelected = index; // Save the last selected index
                  });
                },
              ),
            ),
            SizedBox(
              height: 60,
              width: 300, // Largura igual à da tela
              child: CupertinoButton(
                color:
                    CupertinoColors.systemGreen.darkHighContrastElevatedColor,
                onPressed: adicionar,
                child: Text(
                  widget.adicionarButtonTitle,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
