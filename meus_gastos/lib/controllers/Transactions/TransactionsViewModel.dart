import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/controllers/gastos_fixos/fixedExpensesModel.dart';
import 'package:meus_gastos/controllers/gastos_fixos/fixedExpensesService.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';

class TransactionsViewModel extends ChangeNotifier {
  List<CardModel> _cardList = [];
  List<FixedExpense> _fixedCards = [];

  Future<void> loadCards() async {
    var cards = await CardService.retrieveCards();
    var fcard = await Fixedexpensesservice.getSortedFixedExpenses();
    await _loadFixedExpenseIds();
    _cardList = cards;
    _fixedCards = fcard;
    mergeCardList = await Fixedexpensesservice.mergeFixedWithNormal(
        fixedCards, cardList, currentDate);
    setState(() {});
  }

  Future<void> _loadFixedExpenseIds() async {
    final Fixedids = await Fixedexpensesservice.getFixedExpenseIds();
    final normalids = await CardService.getNormalExpenseIds();
    final fixedsControlIds =
        await service.CardService().getIdFixoControlList(cardList);
    setState(() {
      fixedExpenseIds = Fixedids;
      normalExpenseIds = normalids;
      idsFixosControlList = fixedsControlIds;
    });
  }

  Future<void> fakeExpens(FixedExpense cardFix) async {
    cardFix.price = 0;
    var car = Fixedexpensesservice.Fixed_to_NormalCard(cardFix, currentDate);
    await service.CardService().addCard(car);
    // SaveExpensOnCloud().addNewDate(car);
  }
}
