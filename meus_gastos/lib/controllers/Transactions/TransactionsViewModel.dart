import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/ViewsModelsGerais/SyncViewModel.dart';
import 'package:meus_gastos/ViewsModelsGerais/addCardViewModel.dart';
import 'package:meus_gastos/controllers/Goals/Data/GoalsRepository.dart';
import 'package:meus_gastos/controllers/Login/LoginViewModel.dart';
import 'package:meus_gastos/controllers/Transactions/data/ITransactionsRepository.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/fixedExpensesModel.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/fixedExpensesServiceRefatore.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/ReviewPrompt.dart';

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

  /// Returns whether the card was persisted.
  Future<bool> addCard(CardModel card) async {
    // Optimistic update: card aparece na lista imediatamente. Se o repo falhar,
    // removemos para que o usuário veja claramente que não foi persistido,
    // em vez do bug antigo (card aparecia, falha silenciosa, sumia no próximo
    // reload sem aviso).
    cardList.add(card);
    notifyListeners();
    try {
      await repository.addCard(card);
      return true;
    } catch (_) {
      cardList.remove(card);
      notifyListeners();
      return false;
    }
  }

  /// An expense the user typed and saved on the Add screen. Automatic recurring
  /// additions, widget drains and zeroed recurring entries go through [addCard]
  /// and never count as the aha-moment.
  Future<void> addManualCard(CardModel card) async {
    final saved = await addCard(card);
    if (saved) await _recordAhaIfOnTrack(card);
  }

  // MARK: - Review prompt

  /// Days of the current month with a manual entry before a save counts as the
  /// aha-moment: from then on the month summary reflects a habit, not a test.
  static const int _ahaMinTrackedDays = 3;

  /// The app's aha-moment: an expense saved in the current month, in a month the
  /// user is really tracking, with the month and that category still within
  /// budget. An over-budget save is a negative moment, not one to ask for a
  /// rating. Anything that can't be read (goals, user) skips the event.
  Future<void> _recordAhaIfOnTrack(CardModel card) async {
    try {
      final now = DateTime.now();
      if (card.date.year != now.year || card.date.month != now.month) return;

      final monthCards = [..._cardList.where((c) => c.id != card.id), card]
          .where((c) =>
              c.date.year == now.year &&
              c.date.month == now.month &&
              c.amount > 0)
          .toList();
      final trackedDays = monthCards
          .where((c) => c.idFixoControl.isEmpty)
          .map((c) => c.date.day)
          .toSet();
      if (trackedDays.length < _ahaMinTrackedDays) return;

      final goals = await GoalsRepository(loginVM: loginVM).fetchGoals();
      final totalGoal = goals.fold<double>(0, (sum, g) => sum + g.value);
      final monthTotal =
          monthCards.fold<double>(0, (sum, c) => sum + c.amount);
      if (totalGoal > 0 && monthTotal > totalGoal) return;

      final categoryGoal = goals
          .where((g) => g.categoryId == card.category.id)
          .fold<double>(0, (sum, g) => sum + g.value);
      final categoryTotal = monthCards
          .where((c) => c.category.id == card.category.id)
          .fold<double>(0, (sum, c) => sum + c.amount);
      if (categoryGoal > 0 && categoryTotal > categoryGoal) return;

      await ReviewPrompt.instance.recordPositiveEvent(trigger: 'expense_saved');
    } catch (_) {
      // The review prompt must never break the save flow.
    }
  }

  void setCurrentDate(DateTime newDate) {
    _currentDate = newDate;
    notifyListeners();
  }

  Future<void> loadCards() async {
    isLoading = true;
    notifyListeners();

    List<CardModel> cards = await repository.retrieve();
    // Filtra tombstones aqui (não no repo) para que o SyncService veja todos
    // os items, incluindo deleções, e possa propagá-las entre devices.
    _cardList = cards.where((c) => !c.deleted).toList();

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
    }else{
      await repository.deleteCard(cardModel);
    }
      notifyListeners();
  }

  Future<void> updateCard(CardModel oldCard, CardModel newCard) async {
    if (cardList.contains(oldCard)) {
      cardList.remove(oldCard);
    }
    cardList.add(newCard);
    notifyListeners();
    await repository.updateCard(oldCard, newCard);
  }

  List<CardModel> _filteredTransactions = []; // Lista filtrada
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  // Método para filtrar por período
  void filterByDateRange(DateTime startDate, DateTime endDate) {
    _filterStartDate = startDate;
    _filterEndDate = endDate;
    _applyDateFilter();
    notifyListeners();
  }

  // Método privado para aplicar o filtro
  void _applyDateFilter() {
    if (_filterStartDate == null || _filterEndDate == null) {
      _filteredTransactions = List.from(_cardList);
      return;
    }

    _filteredTransactions = _cardList.where((transaction) {
      final transactionDate = transaction.date; // Ajuste conforme seu modelo
      return transactionDate.isAfter(_filterStartDate!) &&
          transactionDate.isBefore(_filterEndDate!);
    }).toList();

    // Ordene se necessário
    _filteredTransactions.sort((a, b) => b.date.compareTo(a.date));
  }

  // Método para limpar o filtro
  void clearFilter() {
    _filterStartDate = null;
    _filterEndDate = null;
    _filteredTransactions = List.from(_cardList);
    notifyListeners();
  }

  double getTotalExpenses() {
    return _filteredTransactions.fold(0.0, (sum, t) => sum + t.amount);
  }

  @override
  void dispose() {
    loginVM.removeListener(_onLoginChanged);
    syncVM.removeListener(_onSync);
    super.dispose();
  }
}
