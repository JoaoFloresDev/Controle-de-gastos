import 'package:meus_gastos/designSystem/exportDS.dart';

// Imports externos
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Imports de serviços
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/services/DashbordService.dart';
import 'package:meus_gastos/services/TranslateService.dart';

// Imports de modelos
import 'package:meus_gastos/models/ProgressIndicatorModel.dart';

// Imports de controllers
import 'package:meus_gastos/controllers/Dashboards/bar_chartWeek/BarChartDaysofWeek.dart';
import 'package:meus_gastos/controllers/Dashboards/extractByCategory.dart';
import 'package:meus_gastos/controllers/Dashboards/bar_chartWeek/BarChartWeek.dart';
import 'package:meus_gastos/controllers/ads_review/bannerAdconstruct.dart';

// Imports de widgets
import 'package:meus_gastos/controllers/Dashboards/DashboardCard.dart';
import 'package:meus_gastos/controllers/Dashboards/MonthSelector.dart';
import 'package:meus_gastos/controllers/Dashboards/LinearProgressIndicatorSection.dart';

class DashboardScreen extends StatefulWidget {
  final bool isActive;

  DashboardScreen({Key? key, this.isActive = false}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  List<ProgressIndicatorModel> progressIndicators = [];
  List<PieChartDataItem> pieChartDataItems = [];

  List<double> totalOfMonths = []; // total expansives of Months in current Year
  Map<int, Map<String, Map<String, dynamic>>> totalExpansivesMonths_category =
      {}; // to sobreposition of expansives by category

  List<WeekInterval> Last5WeeksIntervals =
      []; // list intervals of last 5 weeks (to the week chart)
  List<List<ProgressIndicatorModel>> Last5WeeksProgressIndicators =
      []; // list expens of last 5 weeks (to the week chart)
  List<List<List<ProgressIndicatorModel>>> weeklyData = [];

  double totalexpens = 0.0;

  bool isLoading = true;
  DateTime currentDate = DateTime.now();
  double totalGasto = 0.0;

  PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _onScreenDisplayed();
  }

  void _onScreenDisplayed() async {
    if (widget.isActive) {
      _loadProgressIndicators(currentDate);
      _loadProgressMonthsInYear(currentDate);
    }
    totalexpens = await CardService.getTotalExpenses(currentDate);
  }

  void _changeMonth(int delta) {
    setState(() {
      currentDate = DateTime(currentDate.year, currentDate.month + delta);
      _loadProgressIndicators(currentDate);
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _loadProgressMonthsInYear(DateTime currentDate) async {
    totalOfMonths = await CardService.getTotalExpensesByMonth(currentDate);
    totalExpansivesMonths_category =
        await CardService.getMonthlyExpensesByCategoryForYear(currentDate.year);
  }

  Future<void> _loadProgressIndicators(DateTime currentDate) async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    progressIndicators =
        await CardService.getProgressIndicatorsByMonth(currentDate);
    pieChartDataItems.clear();
    totalGasto = 0.0;
    for (var progressIndicator in progressIndicators) {
      pieChartDataItems.add(progressIndicator.toPieChartDataItem());
      totalGasto += progressIndicator.progress;
    }
    totalOfMonths = await CardService.getTotalExpensesByMonth(currentDate);

    // to the barchart of week
    Last5WeeksIntervals = Dashbordservice.getLast5WeeksIntervals(currentDate);
    Last5WeeksProgressIndicators =
        await Dashbordservice.getLast5WeeksProgressIndicators(currentDate);
    weeklyData = await Dashbordservice.getProgressIndicatorsOfDaysForLast5Weeks(
        currentDate);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background1,
      navigationBar: CupertinoNavigationBar(
        middle: Text(AppLocalizations.of(context)!.myControl,
            style: const TextStyle(color: AppColors.label, fontSize: 16)),
        backgroundColor: AppColors.background1,
      ),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 60, // banner height
              width: double.infinity, // banner width
              child: BannerAdconstruct(), // banner Widget
            ),
            if (totalexpens > 0)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      MonthSelector(
                        currentDate: currentDate,
                        onChangeMonth: _changeMonth,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        "${AppLocalizations.of(context)!.totalSpent}: ${Translateservice.formatCurrency(totalGasto, context)}",
                        style: const TextStyle(
                          color: AppColors.label,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height:
                            350 + pieChartDataItems.length.toDouble() / 2 * 30 >
                                    500
                                ? 350 +
                                    pieChartDataItems.length.toDouble() / 2 * 30
                                : 500,
                        child: PageView(
                            controller: _pageController,
                            onPageChanged: _onPageChanged,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: DashboardCard(
                                  items: pieChartDataItems,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: WeeklyStackedBarChart(
                                  weekIntervals: Last5WeeksIntervals,
                                  weeklyData: Last5WeeksProgressIndicators,
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: DailyStackedBarChart(
                                      last5weewdailyData: weeklyData,
                                      last5WeeksIntervals:
                                          Last5WeeksIntervals)),
                            ]),
                      ),
                      const SizedBox(
                          height:
                              12), // space between grafics and progressIndicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List<Widget>.generate(3, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            width: 12.0,
                            height: 12.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentIndex == index
                                  ? AppColors.buttonSelected
                                  : AppColors.buttonDeselected,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                      if (isLoading)
                        const CircularProgressIndicator(color: AppColors.label)
                      else
                        Column(
                          children: [
                            Text(
                              AppLocalizations.of(context)!
                                  .topExpensesOfTheMonth,
                              style: const TextStyle(
                                color: AppColors.label,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            for (var progressIndicator in progressIndicators)
                              GestureDetector(
                                onTap: () {
                                  showCupertinoDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Extractbycategory(
                                            category: progressIndicator
                                                .category.name);
                                      });
                                },
                                child: LinearProgressIndicatorSection(
                                    model: progressIndicator,
                                    totalAmount: progressIndicators.fold(
                                        0,
                                        (maxValue, item) =>
                                            maxValue > item.progress
                                                ? maxValue
                                                : item.progress)),
                              )
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            if (totalexpens <= 0)
              Expanded(
                child: Container(
                  width: double.maxFinite,
                  alignment: Alignment.center,
                  child: Text(
                    AppLocalizations.of(context)!.addNewTransactions,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.label,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
