import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/ViewsModelsGerais/addCardViewModel.dart';
import 'package:meus_gastos/controllers/Login/LoginViewModel.dart';
import 'package:meus_gastos/controllers/Transactions/data/ITransactionsRepository.dart';
import 'package:meus_gastos/controllers/gastos_fixos/fixedExpensesModel.dart';
import 'package:meus_gastos/controllers/gastos_fixos/fixedExpensesService.dart';
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

  void _onLoginChanged() {
    final userId = loginVM.isLogin ? loginVM.user!.uid : "";
    final isLoggedIn = loginVM.isLogin;
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
    List<CardModel> cards = await repository.retrieve();
    var fcard = await Fixedexpensesservice.getSortedFixedExpenses();
    _cardList = cards.where((card) => card.amount > 0).toList();
    _fixedCards = fcard;
    _fixedCards = await Fixedexpensesservice.filteredFixedCardsShow(
        fixedCards, currentDate);

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
    List<String> idsFixed = await Fixedexpensesservice.getFixedExpenseIds();
    await repository.deleteCard(cardModel);
    if (idsFixed.contains(cardModel.idFixoControl)) {
      cardModel.amount = 0;
      CardService().addCard(cardModel);
    }
  }

  @override
  void dispose() {
    loginVM.removeListener(_onLoginChanged);
    super.dispose();
  }
}
