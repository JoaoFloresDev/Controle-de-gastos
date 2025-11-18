import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/ViewsModelsGerais/addCardViewModel.dart';
import 'package:meus_gastos/controllers/Login/LoginViewModel.dart';
import 'package:meus_gastos/controllers/Transactions/data/TransactionsRepository.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/fixedExpensesModel.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/fixedExpensesService.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';

class TransactionsViewModel extends ChangeNotifier {
  final TransactionsRepository repository;
  final CardEvents cardEvents;

  TransactionsViewModel({
    required this.repository,
    required this.cardEvents,
  });

  List<CardModel> _cardList = [];
  List<FixedExpense> _fixedCards = [];

  List<CardModel> get cardList => _cardList;
  List<FixedExpense> get fixedCards => _fixedCards;

  DateTime _currentDate = DateTime.now();

  DateTime get currentDate => _currentDate;

  void _onloginChanged(bool isLogin) {
    if (isLogin) {
      loadCards();
    } else {
      notifyListeners();
    }
  }

  Future<void> init() async {
    await loadCards();
    cardEvents.addListener(() {
      loadCards(); // recarrega sempre que um novo card é criado
    });
  }

  void setCurrentDate(DateTime newDate) {
    _currentDate = newDate;
    notifyListeners();
  }

  Future<void> loadCards() async {
    List<CardModel> cards = await repository.retrieveCards();
    var fcard = await FixedExpensesService.getSortedFixedExpenses();
    _cardList = cards.where((card) => card.amount > 0).toList();
    _fixedCards = fcard;
    _fixedCards = await FixedExpensesService.filteredFixedCardsShow(
        fixedCards, currentDate);

    // Adiciona automaticamente os gastos fixos com additionType = 'automatic'
    await _addAutomaticFixedExpenses(_fixedCards);

    // Filtra apenas as sugestões para mostrar na tela
    _fixedCards = _fixedCards.where((item) => item.isSuggestion).toList();

    notifyListeners();
  }

  Future<void> _addAutomaticFixedExpenses(List<FixedExpense> fixedExpenses) async {
    for (var fixedExpense in fixedExpenses) {
      if (fixedExpense.isAutomaticAddition) {
        final newCard = CardModel(
          amount: fixedExpense.price,
          description: fixedExpense.description,
          date: FixedExpensesService.fixedToNormalCard(fixedExpense, _currentDate).date,
          category: fixedExpense.category,
          id: CardService.generateUniqueId(),
          idFixoControl: fixedExpense.id,
        );
        await CardService().addCard(newCard);
      }
    }
  }

  CardModel Fixed_to_NormalCard(FixedExpense fcard) {
    return FixedExpensesService.fixedToNormalCard(fcard, _currentDate);
  }

  Future<void> fakeExpens(FixedExpense cardFix) async {
    cardFix.price = 0;
    var car = FixedExpensesService.fixedToNormalCard(cardFix, _currentDate);
    await CardService().addCard(car);
    // SaveExpensOnCloud().addNewDate(car);
  }

  Future<void> deleteCard(CardModel cardModel) async {
    List<String> idsFixed = await FixedExpensesService.getFixedExpenseIds();
    await repository.deleteCard(cardModel);
    if (idsFixed.contains(cardModel.idFixoControl)){
      cardModel.amount = 0;
      CardService().addCard(cardModel);
    }
  }
}
