import 'package:flutter/material.dart';
import 'package:meus_gastos/controllers/gastos_fixos/data/FixedExpensesRepository.dart';
import 'package:meus_gastos/controllers/gastos_fixos/fixedExpensesModel.dart';
import 'package:meus_gastos/controllers/gastos_fixos/fixedExpensesServiceRefatore.dart';
import 'package:meus_gastos/models/CardModel.dart';

class FixedExpensesViewModel extends ChangeNotifier {
  final FixedExpensesRepository _repo;

  FixedExpensesViewModel(this._repo);

  FixedExpensesService fixedExpensesService = FixedExpensesService();

  List<FixedExpense> _fixedExpense = [];
  List<FixedExpense> get fixedExpenses => _fixedExpense;

  List<String> fcardIds = [];
  DateTime currentWeekdayDate = DateTime.now();

  List<FixedExpense> listFilteredFixedCardsShow = [];

  Future<void> fetchExpenses() async {
    _fixedExpense = await _repo.fetch();
    notifyListeners();
  }

  void addExpense(FixedExpense fexpense) {
    _fixedExpense.add(fexpense);
    _repo.add(fexpense);
    notifyListeners();
  }

  void removeExpense(String expenseId) {
    _fixedExpense.remove(expenseId);
    _repo.delete(expenseId);
    notifyListeners();
  }

  Future<void> getFixedExpenseIds(List<FixedExpense> fcards) async {
    fcardIds = await fixedExpensesService.getFixedExpenseIds(fcards);
  }

  void getCurrentWeekdayDate(DateTime referenceDate) {
    currentWeekdayDate =
        fixedExpensesService.getCurrentWeekdayDate(referenceDate);
  }

  Future<void> filteredFixedCardsShow(DateTime currentDate) async {
    listFilteredFixedCardsShow = await fixedExpensesService
        .filteredFixedCardsShow(_fixedExpense, currentDate);
  }

  CardModel fixedToNormalCard(FixedExpense fixedCard, DateTime currentDate) {
    return fixedExpensesService.fixedToNormalCard(fixedCard, currentDate);
  }
}
