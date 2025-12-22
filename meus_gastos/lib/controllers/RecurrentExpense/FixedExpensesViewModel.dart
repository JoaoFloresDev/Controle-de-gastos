import 'package:flutter/material.dart';
import 'package:meus_gastos/controllers/Transactions/TransactionsViewModel.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/fixedExpensesModel.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/fixedExpensesServiceRefatore.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/data/FixedExpensesRepository.dart';
import 'package:meus_gastos/models/CardModel.dart';

class FixedExpensesViewModel extends ChangeNotifier {
  final FixedExpensesRepository _repo;

  FixedExpensesViewModel(this._repo);

  FixedExpensesService fixedExpensesService = FixedExpensesService();

  TransactionsViewModel? _transactionsVM;

  List<FixedExpense> _fixedExpense = [];
  List<FixedExpense> get fixedExpenses => _fixedExpense;

  List<String> fcardIds = [];
  DateTime currentWeekdayDate = DateTime.now();

  List<FixedExpense> listFilteredFixedCardsShow = [];

  List<CardModel> listFixedExpenseAsNormalCard = [];

  Future<void> init() async {
    await fetchExpenses();
    _recalculate();
  }

  void updateTransactionsVM(TransactionsViewModel transactionsVM) {
    if (_transactionsVM == transactionsVM) return;

    // Remove listener antigo

    _transactionsVM?.removeListener(_onTransactionsChanged);

    _transactionsVM = transactionsVM;

    // Adiciona listener novo
    _transactionsVM!.addListener(_onTransactionsChanged);

    _recalculate();
  }

  void _onTransactionsChanged() {
    _recalculate();
  }

  void _recalculate() {
    if (_transactionsVM == null) return;

    print("RECAUCULATE...");

    final cards = _transactionsVM!.cardList;
    final now = DateTime.now();

    listFilteredFixedCardsShow = fixedExpensesService.filteredFixedCardsShow(
      cards,
      _fixedExpense,
      now,
    );

    listFixedExpenseAsNormalCard = listFilteredFixedCardsShow
        .map((item) => fixedExpensesService.fixedToNormalCard(item, now))
        .toList();

    notifyListeners();
  }

  Future<void> fetchExpenses() async {
    _fixedExpense = await _repo.fetch();
    _fixedExpense.sort((a, b) {
      return a.date.compareTo(b.date);
    });
    _recalculate();
  }

  Future<void> addExpense(FixedExpense fexpense) async {
    _fixedExpense.add(fexpense);
    await _repo.add(fexpense);
    _recalculate();
  }

  Future<void> delete(FixedExpense card) async {
    _fixedExpense.remove(card);
    _repo.delete(card.id);

    _recalculate();
  }

  Future<void> update(FixedExpense card) async {
    for (int i = 0; i < _fixedExpense.length; i++) {
      if (_fixedExpense[i].id == card.id) _fixedExpense[i] = card;
    }
    notifyListeners();
    _repo.update(card);

    _recalculate();
  }

  void filteredFixedCardsShow(List<CardModel> cards, DateTime currentDate) {
    for (var fc in _fixedExpense) {
      print(fc.price);
    }

    fixedToNormalCardList(currentDate);

    listFilteredFixedCardsShow = fixedExpensesService.filteredFixedCardsShow(
        cards, _fixedExpense, currentDate);

    notifyListeners();
  }

  void fixedToNormalCardList(DateTime currentDate) {
    listFixedExpenseAsNormalCard = listFilteredFixedCardsShow
        .map((item) => fixedToNormalCard(item, DateTime.now()))
        .toList();
  }

  CardModel fixedToNormalCard(FixedExpense fixedCard, DateTime currentDate) {
    return fixedExpensesService.fixedToNormalCard(fixedCard, currentDate);
  }

  @override
  void dispose() {
    _transactionsVM?.removeListener(_onTransactionsChanged);
    super.dispose();
  }
}
