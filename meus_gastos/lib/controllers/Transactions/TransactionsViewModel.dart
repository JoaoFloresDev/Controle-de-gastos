import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/ViewsModelsGerais/addCardViewModel.dart';
import 'package:meus_gastos/controllers/Login/LoginViewModel.dart';
import 'package:meus_gastos/controllers/Transactions/data/ITransactionsRepository.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/FixedExpensesViewModel.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/fixedExpensesModel.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/fixedExpensesServiceRefatore.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';

class TransactionsViewModel extends ChangeNotifier {
  final ITransactionsRepository repository;
  final CardEvents cardEvents;
  final LoginViewModel loginVM;
  TransactionsViewModel({
    required this.repository,
    required this.cardEvents,
    required this.loginVM,
  }) {
    loginVM.addListener(_onLoginChanged);
  }

  List<CardModel> _cardList = [];
  List<FixedExpense> _fixedCards = [];

  List<CardModel> get cardList => _cardList;
  List<FixedExpense> get fixedCards => _fixedCards;

  DateTime _currentDate = DateTime.now();

  DateTime get currentDate => _currentDate;

  bool isLoading = true;

  void _onLoginChanged() {
    loadCards();
  }

  Future<void> init() async {
    await loadCards();
    cardEvents.addListener(() {
      loadCards(); // recarrega sempre que um novo card é criado
    });
  }

  Future<void> addCard(CardModel card) async {
    await repository.addCard(card);
    cardList.add(card);
    notifyListeners();
  }

  void setCurrentDate(DateTime newDate) {
    _currentDate = newDate;
    notifyListeners();
  }

  Future<void> loadCards() async {
    isLoading = true;
    notifyListeners();

    List<CardModel> cards = await repository.retrieve();
    _cardList = cards.toList();

    isLoading = false;
    notifyListeners();
  }

  Future<void> _addAutomaticFixedExpenses(
      List<FixedExpense> fixedExpenses) async {
    for (var fixedExpense in fixedExpenses) {
      if (fixedExpense.isAutomaticAddition) {
        final newCard = CardModel(
          amount: fixedExpense.price,
          description: fixedExpense.description,
          date: fixedToNormalCard(fixedExpense).date,
          category: fixedExpense.category,
          id: CardService.generateUniqueId(),
          idFixoControl: fixedExpense.id,
        );
        await CardService().addCard(newCard);
      }
    }
  }

  CardModel fixedToNormalCard(FixedExpense fcard) {
    return FixedExpensesService().fixedToNormalCard(fcard, _currentDate);
  }

  Future<void> fakeExpens(FixedExpense cardFix) async {
    cardFix.price = 0;
    var car = fixedToNormalCard(cardFix);
    await addCard(car);
    // SaveExpensOnCloud().addNewDate(car);
  }

  Future<void> deleteCard(CardModel cardModel) async {
    List<String> idsFixed = await FixedExpensesService().getFixedExpenseIds([]);
    if (idsFixed.contains(cardModel.idFixoControl)) {
      cardModel.amount = 0;
      addCard(cardModel);
    }
    notifyListeners();
    await repository.deleteCard(cardModel);
  }

  Future<void> updateCard(CardModel oldCard, CardModel newCard) async {
    await repository.updateCard(oldCard, newCard);
    if (cardList.contains(oldCard)) {
      cardList.remove(oldCard);
    }
    cardList.add(newCard);
    notifyListeners();
  }

  @override
  void dispose() {
    loginVM.removeListener(_onLoginChanged);
    super.dispose();
  }
}
