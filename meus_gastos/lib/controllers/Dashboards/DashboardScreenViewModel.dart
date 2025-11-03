import 'package:meus_gastos/controllers/Dashboards/ViewComponents/DashboardCard.dart';
import 'package:meus_gastos/models/ProgressIndicatorModel.dart';
import 'package:meus_gastos/services/CardServiceRefatore.dart';
import 'package:meus_gastos/services/DashbordService.dart';

class DashboardScreenViewModel {
  List<ProgressIndicatorModel> progressIndicators = [];
  List<PieChartDataItem> pieChartDataItems = [];
  List<double> totalOfMonths = [];
  Map<int, Map<String, Map<String, dynamic>>> totalExpansivesMonths_category =
      {};
  List<WeekInterval> Last5WeeksIntervals = [];
  List<List<ProgressIndicatorModel>> Last5WeeksProgressIndicators = [];
  List<List<List<ProgressIndicatorModel>>> weeklyData = [];


  double totalexpens = 0.0;
  bool isLoading = true;
  DateTime currentDate = DateTime.now();
  double totalGasto = 0.0;

  Future<void> _loadProgressIndicators(DateTime currentDate) async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    progressIndicators =
        await CardService().getProgressIndicatorsByMonth(currentDate);
    pieChartDataItems = progressIndicators
        .map((indicator) => indicator.toPieChartDataItem())
        .toList();
    totalGasto = progressIndicators.fold(
        0.0, (sum, indicator) => sum + indicator.progress);
    Last5WeeksIntervals = Dashbordservice.getLast5WeeksIntervals(currentDate);
    Last5WeeksProgressIndicators =
        await Dashbordservice.getLast5WeeksProgressIndicators(currentDate);
    weeklyData = await Dashbordservice.getProgressIndicatorsOfDaysForLast5Weeks(
        currentDate);
    setState(() {
      isLoading = false;
    });
  }
}