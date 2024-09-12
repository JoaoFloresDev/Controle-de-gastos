import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/widgets/Dashboards/bar_chartWeek/BarChartDaysofWeek.dart';
import 'package:meus_gastos/widgets/Dashboards/extractByCategory.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'MonthSelector.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'LinearProgressIndicatorSection.dart';
import 'package:meus_gastos/models/ProgressIndicatorModel.dart';
import 'DashboardCard.dart';
import 'package:meus_gastos/widgets/Dashboards/bar_chartWeek/BarChartWeek.dart';
import 'package:meus_gastos/services/DashbordService.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:meus_gastos/widgets/ads_review/bannerAdconstruct.dart';

class DashboardScreen extends StatefulWidget {
  final bool isActive;

  DashboardScreen({Key? key, this.isActive = false}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  // this is variables useds in grafics by paraments
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
  // if the usuary have not expens in month, we make a empity grafic to send him how the grafics will be.
  final List<ProgressIndicatorModel> dataEmpity = [
    ProgressIndicatorModel(
      title: 'Example',
      progress: 100,
      category: CategoryModel(
        id: '',
        icon: Icons.device_unknown,
        name: 'Exemple',
        color: Colors.grey,
      ),
      color: Colors.grey.withOpacity(0.2),
    ),
  ];

  List<List<ProgressIndicatorModel>> generateLast5WeeksProgressIndicators() {
    return List.generate(
      5,
      (_) => List<ProgressIndicatorModel>.from(dataEmpity),
    );
  }

  late List<List<ProgressIndicatorModel>> Last5WeeksProgressIndicatorsEmpity =
      generateLast5WeeksProgressIndicators();

  List<List<List<ProgressIndicatorModel>>> generateWeeklyData() {
    return List.generate(
      5,
      (_) => List.generate(
        7,
        (_) => List<ProgressIndicatorModel>.from(dataEmpity),
      ),
    );
  }

  late List<List<List<ProgressIndicatorModel>>> weeklyDataEmpity =
      generateWeeklyData();

  bool isLoading = true;
  bool _isDataReady = false;

  DateTime currentDate = DateTime.now();
  double totalGasto = 0.0;
  double totalExpensOfUsuary = 0.0;

  PageController _pageController = PageController();
  int _currentIndex = 0;

  GlobalKey circleGrafic = GlobalKey();
  GlobalKey graficWeeksOfMonth = GlobalKey();
  GlobalKey graficDaysOfWeek = GlobalKey();

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
    }
    totalExpensOfUsuary = await CardService.getTotalExpenses(currentDate);
    _loadData();
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

  Future<void> _loadData() async {
    
    setState(() {
      _isDataReady =
          true; 
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CupertinoPageScaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      navigationBar: CupertinoNavigationBar(
        middle: Text(AppLocalizations.of(context)!.myControl,
            style: const TextStyle(color: Colors.white, fontSize: 20)),
        backgroundColor: Colors.black.withOpacity(0.8),
      ),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 60, // banner height
              width: double.infinity, // banner width
              child: BannerAdconstruct(), // banner Widget
            ),
            // if (totalexpens > 0)
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
                    if (totalExpensOfUsuary > 0)
                      Text(
                        "${AppLocalizations.of(context)!.totalSpent}: ${Translateservice.formatCurrency(totalGasto, context)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (_isDataReady)
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
                              Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: DashboardCard(
                                      items: totalExpensOfUsuary > 0
                                          ? pieChartDataItems
                                          : [
                                              dataEmpity[0].toPieChartDataItem()
                                            ],
                                    ),
                                  ),
                                  if (totalExpensOfUsuary == 0)
                                    Positioned.fill(
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                            sigmaX: 5.0, sigmaY: 5.0),
                                        child: Container(
                                          color: Colors.black.withOpacity(0.1),
                                          alignment: Alignment.center,
                                          child: const Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.warning_amber_rounded,
                                                color: Colors.white,
                                                size: 40,
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                'Adicione gastos para acessar os gráficos',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Stack(
                                children: [
                                  Padding(
                                    key: graficWeeksOfMonth,
                                    padding: const EdgeInsets.all(8.0),
                                    child: WeeklyStackedBarChart(
                                      weekIntervals: Last5WeeksIntervals,
                                      weeklyData: totalExpensOfUsuary > 0
                                          ? Last5WeeksProgressIndicators
                                          : Last5WeeksProgressIndicatorsEmpity,
                                    ),
                                  ),
                                  if (totalExpensOfUsuary == 0)
                                    Positioned.fill(
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                            sigmaX: 5.0, sigmaY: 5.0),
                                        child: Container(
                                          color: Colors.black.withOpacity(0.1),
                                          alignment: Alignment.center,
                                          child: const Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.warning_amber_rounded,
                                                color: Colors.white,
                                                size: 40,
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                'Adicione gastos para acessar os gráficos',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Stack(
                                children: [
                                  Padding(
                                    key: graficDaysOfWeek,
                                    padding: const EdgeInsets.all(8.0),
                                    child: DailyStackedBarChart(
                                      last5weewdailyData:
                                          totalExpensOfUsuary > 0
                                              ? weeklyData
                                              : weeklyDataEmpity,
                                      last5WeeksIntervals: Last5WeeksIntervals,
                                    ),
                                  ),
                                  if (totalExpensOfUsuary == 0)
                                    Positioned.fill(
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                            sigmaX: 5.0, sigmaY: 5.0),
                                        child: Container(
                                          color: Colors.black.withOpacity(0.1),
                                          alignment: Alignment.center,
                                          child: const Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.warning_amber_rounded,
                                                color: Colors.white,
                                                size: 40,
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                'Adicione gastos para acessar os gráficos',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
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
                                ? Colors.blue
                                : Colors.grey,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    if (totalGasto > 0)
                      if (isLoading)
                        const CircularProgressIndicator(color: Colors.white)
                      else
                        Column(
                          children: [
                            Text(
                              AppLocalizations.of(context)!
                                  .topExpensesOfTheMonth,
                              style: const TextStyle(
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
          ],
        ),
      ),
    );
  }
}
