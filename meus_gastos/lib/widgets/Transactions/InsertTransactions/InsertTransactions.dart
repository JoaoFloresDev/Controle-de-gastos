import 'package:flutter/material.dart';
import 'ViewComponents/HeaderCard.dart';
import 'ViewComponents/ListCard.dart';
import '../../../models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart' as service;
import 'package:meus_gastos/widgets/Transactions/CardDetails/DetailScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/widgets/Transactions/CategoryCreater/CategoryCreater.dart';
import 'package:meus_gastos/widgets/ads_review/constructReview.dart';
import 'package:meus_gastos/widgets/ads_review/bannerAdconstruct.dart';
import 'package:meus_gastos/widgets/Transactions/exportExcel/exportExcelScreen.dart';

class InsertTransactions extends StatefulWidget {
  const InsertTransactions({
    required this.onAddClicked,
    Key? key,
    required this.title,
  }) : super(key: key);
  final VoidCallback onAddClicked;
  final String title;

  @override
  State<InsertTransactions> createState() => _InsertTransactionsState();
}

class _InsertTransactionsState extends State<InsertTransactions> {
  List<CardModel> cardList = [];
  final GlobalKey<HeaderCardState> _headerCardKey = GlobalKey();
  bool _showHeaderCard = true;

  // MARK: - InitState
  @override
  void initState() {
    super.initState();
    loadCards();
  }

  // MARK: - Load Cards
  Future<void> loadCards() async {
    var cards = await service.CardService.retrieveCards();
    setState(() {
      cardList = cards;
    });
  }

  // MARK: - Build Method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        middle: Text(
          widget.title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: Colors.black,
        trailing: GestureDetector(
          onTap: () {
            showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                      height: MediaQuery.of(context).size.height / 1.6,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Exportexcelscreen());
                });
          },
          child: const Icon(Icons.save_alt),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 60, // banner height
            width: double.infinity, // banner width
            child: BannerAdconstruct(), // banner widget
          ),
          if (_showHeaderCard) ...[
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: HeaderCard(
                key: _headerCardKey,
                onAddClicked: () {
                  widget.onAddClicked();
                  setState(() async {
                    loadCards();
                    await Constructreview.checkAndRequestReview();
                  });
                },
                onAddCategory: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        height: MediaQuery.of(context).size.height / 1.1,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Categorycreater(
                          onCategoryAdded: () {
                            setState(() {
                              _headerCardKey.currentState?.loadCategories();
                            });
                          },
                        ),
                      );
                    },
                  );
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
                color: Colors.white.withOpacity(0.4),
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
      backgroundColor: Colors.black.withOpacity(0.9),
    );
  }

  // MARK: - Show Cupertino Modal Bottom Sheet
  void _showCupertinoModalBottomSheet(BuildContext context, CardModel card) {
    FocusScope.of(context).unfocus();
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height / 1.05,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: DetailScreen(
            card: card,
            onAddClicked: () {
              loadCards();
              setState(() {});
            },
          ),
        );
      },
    );
  }
}
