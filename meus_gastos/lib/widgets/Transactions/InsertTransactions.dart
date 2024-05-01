import 'package:flutter/material.dart';
import 'HeaderCard.dart';
import 'ListCard.dart';
import '../../models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart' as service;
import 'package:meus_gastos/widgets/Transactions/CardDetails/DetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/services/CardService.dart' as service;
import 'package:meus_gastos/widgets/Transactions/CardDetails/DetailScreen.dart';
import 'package:meus_gastos/widgets/Transactions/InsertTransactions.dart';
import 'package:flutter/cupertino.dart';

class InsertTransactions extends StatefulWidget {
  const InsertTransactions(
      {required this.onAddClicked, Key? key, required this.title})
      : super(key: key);
  final VoidCallback onAddClicked;
  final String title;

  @override
  State<InsertTransactions> createState() => _InsertTransactionsState();
}

class _InsertTransactionsState extends State<InsertTransactions> {
  final TextEditingController _dateController = TextEditingController();
  List<CardModel> cardList = [];

  @override
  void initState() {
    super.initState();
    loadCards();
  }

  Future<void> loadCards() async {
    var cards = await service.CardService.retrieveCards();
    setState(() {
      cardList = cards;
    });
  }

  bool _showHeaderCard = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CupertinoNavigationBar(
            middle: Text(widget.title),
          ),
          if (_showHeaderCard) ...[
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: HeaderCard(
                adicionarButtonTitle: 'Adicionar',
                onAddClicked: () {
                  widget.onAddClicked();
                  setState(() {
                    loadCards();
                  });
                },
              ),
            ),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 1,
                width: MediaQuery.of(context).size.width - 100,
                color: Colors.black.withOpacity(0.2),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showHeaderCard = !_showHeaderCard;
                  });
                },
                icon: Icon(
                  _showHeaderCard ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cardList.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListCard(
                    onTap: (card) {
                      widget.onAddClicked();
                      _showCupertinoModalBottomSheet(context, card);
                    },
                    card: cardList[cardList.length - index - 1],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCupertinoModalBottomSheet(BuildContext context, CardModel card) {
    FocusScope.of(context).unfocus();
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height / 1.05,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: DetailScreen(
            card: card,
            onAddClicked: () {
              loadCards();
              setState(() {
                _showHeaderCard = false;
              });
            },
          ),
        );
      },
    );
  }
}
