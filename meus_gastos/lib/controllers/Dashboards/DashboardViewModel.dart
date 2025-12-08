import 'package:meus_gastos/ViewsModelsGerais/addCardViewModel.dart';
import 'package:meus_gastos/controllers/CategoryCreater/CetegoryViewModel.dart';
import 'package:meus_gastos/controllers/Dashboards/ViewComponents/DashboardCard.dart';
import 'package:meus_gastos/controllers/Transactions/TransactionsViewModel.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/models/ProgressIndicatorModel.dart';
import 'package:meus_gastos/controllers/Dashboards/DashbordService.dart';

class DashboardViewModel extends ChangeNotifier {
  final TransactionsViewModel transactionsVM;
  final CardEvents cardEvents;
  final CategoryViewModel categoriesVM;
  DashboardViewModel(
      {required this.transactionsVM,
      required this.cardEvents,
      required this.categoriesVM}) {
    // Ouve automaticamente mudanças de cards
    transactionsVM.addListener(_onDependenciesChanged);
  }
  void _onDependenciesChanged() {
    // Quando os cards mudarem, recarrega os dados
    loadProgressIndicators();
  }

  List<CardModel> cards = [];
  List<ProgressIndicatorModel> _progressIndicators = [];
  List<PieChartDataItem> _pieChartDataItems = [];
  List<double> _totalOfMonths = [];
  Map<int, Map<String, Map<String, dynamic>>> _totalExpansivesMonths_category =
      {};
  List<WeekInterval> _Last5WeeksIntervals = [];
  List<List<ProgressIndicatorModel>> _Last5WeeksProgressIndicators = [];
  List<List<List<ProgressIndicatorModel>>> _weeklyData = [];

  double _totalexpens = 0.0;
  bool _isLoading = true;
  DateTime _currentDate = DateTime.now();
  double _totalGasto = 0.0;

  List<ProgressIndicatorModel> get progressIndicators => _progressIndicators;
  List<PieChartDataItem> get pieChartDataItems => _pieChartDataItems;
  List<double> get totalOfMonths => _totalOfMonths;
  Map<int, Map<String, Map<String, dynamic>>>
      get totalExpansivesMonths_category => _totalExpansivesMonths_category;
  List<WeekInterval> get Last5WeeksIntervals => _Last5WeeksIntervals;
  List<List<ProgressIndicatorModel>> get Last5WeeksProgressIndicators =>
      _Last5WeeksProgressIndicators;
  List<List<List<ProgressIndicatorModel>>> get weeklyData => _weeklyData;

  double get totalexpens => _totalexpens;
  bool get isLoading => _isLoading;
  DateTime get currentDate => _currentDate;
  double get totalGasto => _totalGasto;

  Future<void> loadProgressIndicators() async {
    _isLoading = true;
    notifyListeners();
    cards = transactionsVM.cardList;
    _progressIndicators = await Dashbordservice.getProgressIndicatorsByMonth(
        _currentDate, cards, categoriesVM.categories);
    _progressIndicators.forEach((element) {
      print(element.category.name);
    });
    _pieChartDataItems = _progressIndicators
        .map((indicator) => indicator.toPieChartDataItem())
        .toList();
    _totalGasto = _progressIndicators.fold(
        0.0, (sum, indicator) => sum + indicator.progress);
    _Last5WeeksIntervals = Dashbordservice.getLast5WeeksIntervals(_currentDate);
    _Last5WeeksProgressIndicators =
        await Dashbordservice.getLast5WeeksProgressIndicators(
            cards, _currentDate, categoriesVM.categories);
    _weeklyData =
        await Dashbordservice.getProgressIndicatorsOfDaysForLast5Weeks(
            cards, _currentDate, categoriesVM.categories);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> changeMonth(int delta) async {
    _currentDate = DateTime(_currentDate.year, _currentDate.month + delta);
    await loadProgressIndicators();
    notifyListeners();
  }
}
