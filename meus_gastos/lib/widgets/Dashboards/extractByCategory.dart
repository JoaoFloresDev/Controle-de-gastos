import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/widgets/Transactions/CardDetails/DetailScreen.dart';
import 'package:meus_gastos/widgets/Transactions/InsertTransactions/ViewComponents/ListCard.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:meus_gastos/widgets/ads_review/bannerAdconstruct.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Extractbycategory extends StatefulWidget {
  final String category;

  Extractbycategory({Key? key, required this.category}) : super(key: key);

  _Extractbycategory createState() => _Extractbycategory();
}

class _Extractbycategory extends State<Extractbycategory> {
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
    List<CardModel> aux = [];
    for (var card in cardList) {
      if (card.category.name == widget.category) {
        aux.add(card);
      }
    }
    return aux;
  }

  @override
  Widget build(BuildContext context) {
    List<CardModel> filtered = selectbycategory(cards);
    return Container(
        color: Colors.grey[900],
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Column(
            children: [
              Container(
                  width: double.maxFinite,
                  alignment: Alignment.center,
                  color: Colors.black,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {
                              Future.microtask(() => Navigator.pop(context));
                            },
                            child: Text(
                              AppLocalizations.of(context)!.cancel,
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              Translateservice.getTranslatedCategoryName(context, widget.category),
                              style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              SizedBox(
                height: 60, // banner height
                width: double.infinity, // banner width
                child: BannerAdconstruct(), // banner widget
              ),
              Expanded(
                child: Container(
                  color: Colors.black38,
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: ListCard(
                          onTap: (card) {
                            FocusScope.of(context).unfocus();
                            showCupertinoModalPopup(
                                context: context,
                                builder: (BuildContext context) {
                                  return Container(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              1.05,
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
                                        },
                                      ));
                                });
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
        ));
  }
}
