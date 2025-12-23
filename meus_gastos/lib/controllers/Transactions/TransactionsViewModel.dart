import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/ViewsModelsGerais/SyncViewModel.dart';
import 'package:meus_gastos/ViewsModelsGerais/addCardViewModel.dart';
import 'package:meus_gastos/controllers/Login/LoginViewModel.dart';
import 'package:meus_gastos/controllers/Transactions/data/ITransactionsRepository.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/fixedExpensesModel.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/fixedExpensesServiceRefatore.dart';
import 'package:meus_gastos/models/CardModel.dart';

class TransactionsViewModel extends ChangeNotifier {
  final ITransactionsRepository repository;
  final CardEvents cardEvents;
  final LoginViewModel loginVM;
  final SyncViewModel syncVM;

  TransactionsViewModel(
      {required this.repository,
      required this.cardEvents,
      required this.loginVM,
      required this.syncVM}) {
    loginVM.addListener(_onLoginChanged);
    syncVM.addListener(_onSync);
  }

  void _onSync() {
    if (syncVM.hasSynced) {
      loadCards();
    }
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
    cardList.add(card);
    notifyListeners();
    await repository.addCard(card);
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

  CardModel fixedToNormalCard(FixedExpense fcard) {
    return FixedExpensesService().fixedToNormalCard(fcard, _currentDate);
  }

  Future<void> fakeExpens(FixedExpense cardFix) async {
    cardFix.price = 0;
    var car = fixedToNormalCard(cardFix);
    await addCard(car);
  }

  Future<void> deleteCard(
      CardModel cardModel, List<FixedExpense> fcards) async {
    List<String> idsFixed =
        await FixedExpensesService().getFixedExpenseIds(fcards);
    if (idsFixed.contains(cardModel.idFixoControl)) {
      cardModel.amount = 0;
      updateCard(cardModel, cardModel);
      print(cardModel.amount);
    }
    notifyListeners();
    await repository.deleteCard(cardModel);
  }

  Future<void> updateCard(CardModel oldCard, CardModel newCard) async {
    if (cardList.contains(oldCard)) {
      cardList.remove(oldCard);
    }
    cardList.add(newCard);
    notifyListeners();
    await repository.updateCard(oldCard, newCard);
  }

  @override
  void dispose() {
    loginVM.removeListener(_onLoginChanged);
    syncVM.removeListener(_onSync);
    super.dispose();
  }
}
