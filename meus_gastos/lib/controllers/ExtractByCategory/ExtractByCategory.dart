import 'package:meus_gastos/controllers/exportExcel/exportExcelScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/controllers/CardDetails/DetailScreen.dart';
import 'package:meus_gastos/controllers/Transactions/InsertTransactions/ViewComponents/ListCard.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';

class Extractbycategory extends StatefulWidget {
  final String category;

  const Extractbycategory({super.key, required this.category});

  @override
  _ExtractbycategoryState createState() => _ExtractbycategoryState();
}

class _ExtractbycategoryState extends State<Extractbycategory> {
  late List<CardModel> cards = [];
  late List<CardModel> mergeCardList = [];

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

  List<CardModel> selectbycategory(
      List<CardModel> cardList, DateTime currentDate) {
    return cardList
        .where((card) => card.category.name == widget.category)
        .where((c) => c.date.month == currentDate.month)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    List<CardModel> filtered = selectbycategory(cards, DateTime.now());
    print(filtered.length);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          CustomHeader(
              title: Translateservice.getTranslatedCategoryName(
                  context, widget.category),
              onCancelPressed: () {
                Navigator.pop(context);
              },
              onDeletePressed: () {
                showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      height: SizeOf(context).modal.halfModal(),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Exportexcelscreen(category: widget.category),
                    );
                  },
                );
              },
              showDeleteButton: true,
              deleteButtonIcon: const Icon(
                CupertinoIcons.share,
                size: 24.0,
                color: Colors.white,
              )),
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
                              height: MediaQuery.of(context).size.height - 150,
                              decoration: const BoxDecoration(
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
                      background: AppColors.card,
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
