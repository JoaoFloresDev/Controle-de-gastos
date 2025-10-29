import 'package:meus_gastos/controllers/exportExcel/exportExcelScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/controllers/CardDetails/DetailScreen.dart';
import 'package:meus_gastos/controllers/Transactions/ViewComponents/ListCard.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';

class ExtractByCategory extends StatefulWidget {
  final String category;
  final DateTime currentMonth;
  const ExtractByCategory(
      {Key? key, required this.category, required this.currentMonth})
      : super(key: key);
  
  @override
  _ExtractByCategoryState createState() => _ExtractByCategoryState();
}

class _ExtractByCategoryState extends State<ExtractByCategory> {
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

  List<CardModel> selectByCategory(
      List<CardModel> cardList, DateTime currentDate) {
    return cardList
        .where((card) => card.category.name == widget.category)
        .where((c) => (c.date.month == currentDate.month && c.amount > 0))
        .where((c) => (c.date.month == currentDate.month && c.amount > 0))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    List<CardModel> filtered = selectByCategory(cards, widget.currentMonth);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Icon(CupertinoIcons.clear, color: Colors.white, size: 28),
                    onPressed: () {
                      print("Close button pressed");
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    TranslateService.getTranslatedCategoryName(context, widget.category),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Icon(CupertinoIcons.share, color: Colors.white, size: 28),
                    onPressed: () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            height: SizeOf(context).modal.halfModal(),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            child: Exportexcelscreen(category: widget.category),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Lista de transações sem espaço extra entre o header e o conteúdo
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -4), // desloca 4 pixels para cima
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
                ),
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          "No transactions found",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          CardModel card = filtered[filtered.length - index - 1];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: ListCard(
                              onTap: (card) {
                                FocusScope.of(context).unfocus();
                                showCupertinoModalPopup(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Container(
                                      height: MediaQuery.of(context).size.height - 70,
                                      decoration: const BoxDecoration(
                                        color: AppColors.background1,
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                      ),
                                      child: DetailScreen(
                                        card: card,
                                        onAddClicked: () {
                                          loadCards();
                                        },
                                        onDelete: (card) {}
                                      ),
                                    );
                                  },
                                );
                              },
                              card: card,
                              background: AppColors.card,
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        ]
        ),
    );
  }
}
