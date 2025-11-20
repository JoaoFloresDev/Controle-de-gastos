import 'package:meus_gastos/controllers/exportExcel/exportExcelScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/controllers/CardDetails/DetailScreen.dart';
import 'package:meus_gastos/controllers/Transactions/ViewComponents/ListCard.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';

class ExtractByCategoryScreen extends StatefulWidget {
  final String category;
  final DateTime currentMonth;
  const ExtractByCategoryScreen(
      {Key? key, required this.category, required this.currentMonth})
      : super(key: key);
  
  @override
  _ExtractByCategoryState createState() => _ExtractByCategoryState();
}

class _ExtractByCategoryState extends State<ExtractByCategoryScreen> {
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
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    List<CardModel> filtered = selectByCategory(cards, widget.currentMonth);
    return Scaffold(
      backgroundColor: AppColors.background1,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: _buildHeader(),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background1,
              ),
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        "No transactions found",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.5),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 0,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Icon(
              CupertinoIcons.xmark_circle_fill,
              color: AppColors.label,
              size: 24,
            ),
          ),
          Text(
            TranslateService.getTranslatedCategoryName(context, widget.category),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              color: AppColors.label,
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 0,
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
            child: const Icon(
              CupertinoIcons.share,
              color: AppColors.label,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}