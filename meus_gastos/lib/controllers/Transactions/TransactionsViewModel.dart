import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/controllers/Transactions/data/TransactionsRepository.dart';
import 'package:meus_gastos/controllers/gastos_fixos/fixedExpensesModel.dart';
import 'package:meus_gastos/controllers/gastos_fixos/fixedExpensesService.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';

class TransactionsViewModel extends ChangeNotifier {
  final TransactionsRepository repository;

  TransactionsViewModel({required this.repository});

  List<CardModel> _cardList = [];
  List<FixedExpense> _fixedCards = [];

  List<CardModel> get cardList => _cardList;
  List<FixedExpense> get fixedCards => _fixedCards;

  DateTime _currentDate = DateTime.now();

  DateTime get currentDate => _currentDate;

  Future<void> init() async {
    await loadCards();
  }

  void setCurrentDate(DateTime newDate) {
    _currentDate = newDate;
    notifyListeners();
  }

  Future<void> loadCards() async {
    var cards = await repository.retrieveCards();
    var fcard = await Fixedexpensesservice.getSortedFixedExpenses();
    _cardList = cards;
    _fixedCards = fcard;
    _fixedCards = await Fixedexpensesservice.filteredFixedCardsShow(
        fixedCards, currentDate);
    print("${_cardList.length} Entrou no loadCards");
    notifyListeners();
  }

  CardModel Fixed_to_NormalCard(FixedExpense fcard) {
    return Fixedexpensesservice.Fixed_to_NormalCard(fcard, _currentDate);
  }

  Future<void> fakeExpens(FixedExpense cardFix) async {
    cardFix.price = 0;
    var car = Fixedexpensesservice.Fixed_to_NormalCard(cardFix, _currentDate);
    await CardService().addCard(car);
    // SaveExpensOnCloud().addNewDate(car);
  }

  Future<void> deleteCard(CardModel cardModel) async {
    await repository.deleteCard(cardModel);
  }
}
