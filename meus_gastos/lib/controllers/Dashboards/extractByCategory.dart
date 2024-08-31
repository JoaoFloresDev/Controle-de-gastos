import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/controllers/Transactions/CardDetails/DetailScreen.dart';
import 'package:meus_gastos/controllers/Transactions/InsertTransactions/ViewComponents/ListCard.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';

class Extractbycategory extends StatefulWidget {
  final String category;

  Extractbycategory({Key? key, required this.category}) : super(key: key);

  @override
  _ExtractbycategoryState createState() => _ExtractbycategoryState();
}

class _ExtractbycategoryState extends State<Extractbycategory> {
  late List<CardModel> cards = [];

  @override
  void initState() {
    super.initState();
    loadCards();
  }

  Future<void> loadCards() async {
    var cardList = await CardService.retrieveCards();
    setState(() {
      cards = cardList;
    });
  }

  List<CardModel> selectbycategory(List<CardModel> cardList) {
    return cardList
        .where((card) => card.category.name == widget.category)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    List<CardModel> filtered = selectbycategory(cards);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.label),
                    onPressed: () {
                      print("aqui");
                      Navigator.pop(context);
                    },
                  ),

                  Expanded(
                    child: Center(
                      child: Text(
                        Translateservice.getTranslatedCategoryName(
                            context, widget.category),
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.label,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 48), // Space for alignment
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: AppColors.background1,
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListCard(
                      onTap: (card) {
                        FocusScope.of(context).unfocus();
                        showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: MediaQuery.of(context).size.height / 1.05,
                              decoration: BoxDecoration(
                                color: AppColors.background1,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: DetailScreen(
                                card: card,
                                onAddClicked: () {
                                  loadCards();
                                },
                              ),
                            );
                          },
                        );
                      },
                      card: filtered[filtered.length - index - 1],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
