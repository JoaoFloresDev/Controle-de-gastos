import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/ViewsModelsGerais/SyncViewModel.dart';
import 'package:meus_gastos/controllers/CategoryCreater/CetegoryViewModel.dart';
import 'package:meus_gastos/controllers/Goals/Data/GoalsRepository.dart';
import 'package:meus_gastos/controllers/Goals/Data/GoalsService.dart';
import 'package:meus_gastos/controllers/Goals/GoalsModel.dart';
import 'package:meus_gastos/controllers/Transactions/TransactionsViewModel.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/models/ProgressIndicatorModel.dart';
import 'package:meus_gastos/services/CardServiceRefatore.dart';

class GoalsViewModel extends ChangeNotifier {
  CategoryViewModel categoryViewModel;
  TransactionsViewModel transactionsViewModel;
  GoalsRepository goalsRepo;
  SyncViewModel syncVM;

  GoalsViewModel(
      {required this.categoryViewModel,
      required this.transactionsViewModel,
      required this.goalsRepo,
      required this.syncVM}) {
    transactionsViewModel.addListener(_onTransactionsChanged);
    categoryViewModel.addListener(_onTransactionsChanged);
    syncVM.addListener(_onTransactionsChanged);
  }

  void _onTransactionsChanged() {
    recalculate();
  }

  @override
  void dispose() {
    transactionsViewModel.removeListener(_onTransactionsChanged);
    categoryViewModel.removeListener(_onTransactionsChanged);
    syncVM.removeListener(_onTransactionsChanged);
    super.dispose();
  }

  void recalculate() {
    init();
    notifyListeners();
  }

  final CardService serviceCard = CardService();
  GoalsService goalsService = GoalsService();

  bool _isLoading = false;
  List<CategoryModel> _categories = [];

  final DateTime _currentDate = DateTime.now();

  String _formattedDate = "";
  bool get isLoading => _isLoading;
  String get formattedDate => _formattedDate;
  List<ProgressIndicatorModel> _progressIndicators = [];

  double _totalExpenses = 0;
  Map<String, double> _expensByCategoryOfCurrentMonth = {};
  Map<String, double> get expensByCategoryOfCurrentMonth =>
      _expensByCategoryOfCurrentMonth;
  double get totalExpenses => _totalExpenses;
  double get totalProgressPercent => _totalGoal == 0
      ? (_totalExpenses > 0 ? 100 : 0)
      : (_totalExpenses / _totalGoal * 100).clamp(0, 100).toDouble();

  Map<String, double> _goalsByCategory = {};
  double _totalGoal = 0;
  Map<String, double> get goalsByCategory => _goalsByCategory;
  double get totalGoal => _totalGoal;

  List<CategoryModel> get categories => _categories;

  bool totalExpenseIsOverGoal() =>
      (_totalExpenses > _totalGoal && totalGoal > 0);

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await loadCategorys();

    await loadExpenses(notify: false);

    await loadGoals(notify: false);

    _isLoading = false;

    // print("CARREGADO: ${transactionsViewModel.cardList.length}");
    notifyListeners();
  }

  Future<void> loadCategorys() async {
    _categories = categoryViewModel.getAllCategoriesAvaliable();
    _removeAddCategory();
  }

  void _removeAddCategory() {
    if (_categories.isEmpty) return;
    try {
      _categories.removeWhere((category) => category.id == "AddCategory");
    } catch (e) {
      print("AddTransactions already removed");
    }
  }

  Future<void> loadGoals({bool notify = true}) async {
    _isLoading = true;
    if (notify) notifyListeners();

    List<GoalModel> _goals = await goalsRepo.fetchGoals();

    _goalsByCategory = await goalsService.getGoals(_goals, _categories);

    sumTotalGoal();

    _isLoading = false;
    if (notify) notifyListeners();
  }

  Future<void> loadExpenses({bool notify = true}) async {
    _isLoading = true;
    if (notify) notifyListeners();

    List<CardModel> filteredCards = serviceCard.filterCardsOfMonth(
        transactionsViewModel.cardList, _currentDate);
    _progressIndicators = await serviceCard.getProgressIndicators(
        filteredCards, categoryViewModel.avaliebleCetegories);

    _expensByCategoryOfCurrentMonth = {
      for (var item in _progressIndicators) item.category.id: item.progress
    };
    sumTotalExpens();

    _isLoading = false;
    if (notify) notifyListeners();
  }

  void updateGoals(Map<String, double> newGoalsByCategory) {
    if (_goalsByCategory != newGoalsByCategory) {
      _goalsByCategory = newGoalsByCategory;
      sumTotalGoal();
      notifyListeners();
    }
  }

  void sumTotalGoal() {
    double sum = 0;
    _goalsByCategory.forEach((_, goalValue) {
      sum += goalValue;
    });
    _totalGoal = sum;
  }

  void sumTotalExpens() {
    double sum = 0;
    _expensByCategoryOfCurrentMonth.forEach((_, expensValue) {
      sum += expensValue;
    });
    _totalExpenses = sum;
  }

  void addGoal(String newGoalCategoryId, double newGoalValue) {
    try {
      goalsRepo.addGoal(
          GoalModel(categoryId: newGoalCategoryId, value: newGoalValue));

      _goalsByCategory = {
        newGoalCategoryId: newGoalValue,
        ..._goalsByCategory..remove(newGoalCategoryId)
      };

      sumTotalGoal();

      notifyListeners();
    } catch (e) {
      print("Erro: $e");
    }
  }

  void formatDate(BuildContext context) {
    final DateFormat format =
        DateFormat('MMMM yyyy', Localizations.localeOf(context).toString());
    _formattedDate = format.format(_currentDate);
    _formattedDate =
        formattedDate[0].toUpperCase() + formattedDate.substring(1);
  }
}
