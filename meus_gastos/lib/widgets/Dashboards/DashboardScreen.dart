import 'dart:ffi';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/widgets/Dashboards/BarChart.dart';
import 'package:meus_gastos/widgets/Dashboards/bar_chartWeek/BarChartDaysofWeek.dart';
import 'package:meus_gastos/widgets/Dashboards/extractByCategory.dart';
import 'MonthSelector.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'LinearProgressIndicatorSection.dart';
import 'package:meus_gastos/models/ProgressIndicatorModel.dart';
import 'DashboardCard.dart';
import 'package:meus_gastos/widgets/Dashboards/bar_chartWeek/BarChartWeek.dart';
import 'package:meus_gastos/services/DashbordService.dart';

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

  bool isLoading = true;
  DateTime currentDate = DateTime.now();
  double totalGasto = 0.0;
  bool graficCircle = true;

  PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _onScreenDisplayed();
  }

  void _onScreenDisplayed() {
    print("DashboardScreen is displayed.2");
    if (widget.isActive) {
      print("aaa22");
      _loadProgressIndicators(currentDate);
      _loadProgressMonthsInYear(currentDate);
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      currentDate = DateTime(currentDate.year, currentDate.month + delta);
      _loadProgressIndicators(currentDate);
    });
  }

  void _changeYear(int increment) {
    setState(() {
      currentDate = DateTime(currentDate.year + increment);
      _loadProgressMonthsInYear(currentDate);
      _loadProgressIndicators(currentDate);
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
      graficCircle = true;
      if (index == 1) {
        graficCircle = false;
      }
      _loadProgressIndicators(currentDate);
    });
  }

  Future<void> _loadProgressMonthsInYear(DateTime currentDate) async {
    totalOfMonths = await CardService.getTotalExpensesByMonth(currentDate);
    totalExpansivesMonths_category =
        await CardService.getMonthlyExpensesByCategoryForYear(currentDate.year);
    print("${totalExpansivesMonths_category.isEmpty}");
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
      backgroundColor: Colors.black.withOpacity(0.9),
      navigationBar: CupertinoNavigationBar(
        middle: Text("Meu Controle",
            style: TextStyle(color: Colors.white, fontSize: 20)),
        backgroundColor: Colors.black.withOpacity(0.8),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 15),
              MonthSelector(
                currentDate: currentDate,
                onChangeMonth: _changeMonth,
              ),
              SizedBox(height: 18),
              Text(
                "Total gasto: ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(totalGasto)}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                height: 350 + pieChartDataItems.length.toDouble() / 2 * 30 > 500
                    ? 350 + pieChartDataItems.length.toDouble() / 2 * 30
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
                              last5WeeksIntervals: Last5WeeksIntervals)),
                    ]),
              ),
              SizedBox(height: 12), // Espaço entre o PageView e o indicador
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(3, (index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    width: 12.0,
                    height: 12.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index ? Colors.blue : Colors.grey,
                    ),
                  );
                }),
              ),
              SizedBox(height: 12),
              if (isLoading)
                CircularProgressIndicator(color: Colors.white)
              else
                Column(
                  children: [
                    Text(
                      "Maiores gastos do Mês",
                      style: TextStyle(
                        color: Colors.white,
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
                                return Container(
                                  child: Extractbycategory(
                                      category:
                                          progressIndicator.category.name),
                                );
                              });
                        },
                        child: LinearProgressIndicatorSection(
                            model: progressIndicator,
                            totalAmount: progressIndicators.fold(
                                0,
                                (maxValue, item) => maxValue > item.progress
                                    ? maxValue
                                    : item.progress)),
                      )
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
