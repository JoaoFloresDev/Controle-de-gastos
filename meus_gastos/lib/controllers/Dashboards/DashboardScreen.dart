import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/controllers/exportExcel/exportExcelScreen.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/controllers/ads_review/constructReview.dart';

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
import 'package:meus_gastos/controllers/Dashboards/ViewComponents/bar_chartWeek/BarChartDaysofWeek.dart';
import 'package:meus_gastos/controllers/ExtractByCategory/ExtractByCategory.dart';
import 'package:meus_gastos/controllers/Dashboards/ViewComponents/bar_chartWeek/BarChartWeek.dart';
import 'package:meus_gastos/controllers/ads_review/bannerAdconstruct.dart';

// Imports de widgets
import 'package:meus_gastos/controllers/Dashboards/ViewComponents/DashboardCard.dart';
import 'package:meus_gastos/controllers/Dashboards/ViewComponents/MonthSelector.dart';
import 'package:meus_gastos/controllers/Dashboards/ViewComponents/LinearProgressIndicatorSection.dart';
import 'package:meus_gastos/controllers/Dashboards/ViewComponents/TotalSpentCarousel.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  final bool isActive;

  const DashboardScreen({super.key, this.isActive = false});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  bool _isPro = false;

  //mark - propriedades
  List<ProgressIndicatorModel> progressIndicators = [];
  List<PieChartDataItem> pieChartDataItems = [];
  List<double> totalOfMonths = [];
  Map<int, Map<String, Map<String, dynamic>>> totalExpansivesMonths_category =
      {};
  List<WeekInterval> Last5WeeksIntervals = [];
  List<List<ProgressIndicatorModel>> Last5WeeksProgressIndicators = [];
  List<List<List<ProgressIndicatorModel>>> weeklyData = [];
  List<ProgressIndicatorModel> progressIndicators2 = [
    ProgressIndicatorModel(
      title: "Alimentação",
      progress: 400,
      category: CategoryModel(
        id: "1",
        name: "Alimentação",
        color: const Color.fromARGB(255, 41, 40, 40), // Cor para a categoria
        icon: CupertinoIcons.cart, // Ícone fictício
        frequency: 5, // Frequência de ocorrência
      ),
      color: const Color.fromARGB(255, 41, 40, 40), // Cor do indicador
    ),
    ProgressIndicatorModel(
      title: "Transporte",
      progress: 200,
      category: CategoryModel(
        id: "2",
        name: "Transporte",
        color: const Color.fromARGB(255, 41, 40, 40), // Cor para a categoria
        icon: CupertinoIcons.car, // Ícone fictício
        frequency: 3, // Frequência de ocorrência
      ),
      color: const Color.fromARGB(255, 41, 40, 40), // Cor do indicador
    ),
    ProgressIndicatorModel(
      title: "Lazer",
      progress: 300,
      category: CategoryModel(
        id: "3",
        name: "Lazer",
        color: const Color.fromARGB(255, 41, 40, 40), // Cor para a categoria
        icon: CupertinoIcons.smiley, // Ícone fictício
        frequency: 2, // Frequência de ocorrência
      ),
      color: const Color.fromARGB(255, 41, 40, 40), // Cor do indicador
    ),
  ];

  double totalexpens = 0.0;
  bool isLoading = true;
  DateTime currentDate = DateTime.now();
  double totalGasto = 0.0;

  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _onScreenDisplayed();
    _checkUserProStatus();
  }

  Future<void> _checkUserProStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool isYearlyPro = prefs.getBool('yearly.pro') ?? false;
    bool isMonthlyPro = prefs.getBool('monthly.pro') ?? false;
    setState(() {
      _isPro = isYearlyPro || isMonthlyPro;
    });
  }

  Future<void> _onScreenDisplayed() async {
    if (widget.isActive) {
      await _loadInitialData();
    }
    totalexpens = await CardService.getTotalExpenses(currentDate);
  }

  Future<void> _loadInitialData() async {
    await _loadProgressIndicators(currentDate);
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

  Widget _buildBannerAd() {
    if (_isPro) {
      return const SizedBox.shrink();
    }
    return Container(
      height: 60,
      width: double.infinity, // Largura total da tela
      alignment: Alignment.center, // Centraliza no eixo X
      child: LoadingContainer(),
    );
  }

  Widget _buildMonthSelector() {
    return MonthSelector(
      currentDate: currentDate,
      onChangeMonth: _changeMonth,
    );
  }

  double _calculatePageHeight() {
    double baseHeight = 300;
    double heightPerLine = 40;
    List<String> labels = pieChartDataItems.map((item) => item.label).toList();
    int calculateLines(List<String> labels) {
      int lines = 0;
      int i = 0;

      while (i < labels.length) {
        String current = labels[i];
        if (i + 1 < labels.length &&
            (current.length + labels[i + 1].length) <= 20) {
          i += 2;
        } else {
          i += 1;
        }
        lines++;
      }

      return lines;
    }

    int totalLines = calculateLines(labels);
    double additionalHeight = totalLines * heightPerLine;
    double minHeight = 380;
    double maxHeight = MediaQuery.of(context).size.height - 100;
    double pageHeight = baseHeight + additionalHeight;
    pageHeight = pageHeight.clamp(minHeight, maxHeight);

    return pageHeight;
  }

  Widget _buildTotalSpentCarousel() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      child: SizedBox(
        height: 440,
        child: TotalSpentCarouselWithTitles(currentMonth: currentDate),
      ),
    );
  }

  Widget _buildPageView() {
    double pageHeight = _calculatePageHeight();

    return SizedBox(
      height: pageHeight,
      child: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.only(left: 8.0, right: 8.0, top: 4, bottom: 8),
            child: DashboardCard(
              items: pieChartDataItems,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 8.0, right: 8.0, top: 4, bottom: 8),
            child: WeeklyStackedBarChart(
              weekIntervals: Last5WeeksIntervals,
              weeklyData: Last5WeeksProgressIndicators,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 8.0, right: 8.0, top: 4, bottom: 8),
            child: DailyStackedBarChart(
              last5weewdailyData: weeklyData,
              last5WeeksIntervals: Last5WeeksIntervals,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: 12.0,
          height: 12.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentIndex == index
                ? AppColors.button
                : AppColors.buttonSelected,
          ),
        );
      }),
    );
  }

  Widget _buildProgressIndicators(BuildContext context) {
    print(progressIndicators.isEmpty);
    if (progressIndicators.isEmpty) {
      return Column(
        crossAxisAlignment:
            CrossAxisAlignment.center, // Centraliza os itens horizontalmente
        children: [
          Text(
            AppLocalizations.of(context)!.topExpensesOfTheMonth,
            style: const TextStyle(
              color: AppColors.label,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center, // Centraliza o texto dentro do widget
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.categoryExpensesDescription,
            style: const TextStyle(
              color: AppColors.label,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center, // Centraliza o texto dentro do widget
          ),
          const SizedBox(height: 30),
        ],
      );
    }

    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.topExpensesOfTheMonth,
          style: const TextStyle(
            color: AppColors.label,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        for (var progressIndicator in progressIndicators)
          GestureDetector(
            onTap: () => _showExpenseDetails(context, progressIndicator),
            child: LinearProgressIndicatorSection(
              model: progressIndicator,
              totalAmount: progressIndicators.fold(
                  0,
                  (maxValue, item) =>
                      maxValue > item.progress ? maxValue : item.progress),
            ),
          ),
      ],
    );
  }

  void _showExpenseDetails(BuildContext context, ProgressIndicatorModel model) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height - 150,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Extractbycategory(category: model.category.name),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return const CircularProgressIndicator(color: AppColors.background1);
  }

  Widget _buildTotalSpentText(BuildContext context) {
    return Text(
      "${AppLocalizations.of(context)!.totalSpent}: ${Translateservice.formatCurrency(totalGasto, context)}",
      style: const TextStyle(
        color: AppColors.label,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  //mark - construção da tela
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.background1,
      appBar: CupertinoNavigationBar(
        middle: Text(
          AppLocalizations.of(context)!.myControl,
          style: const TextStyle(color: AppColors.label, fontSize: 16),
        ),
        backgroundColor: AppColors.background1,
        trailing: GestureDetector(
            onTap: () {
              showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    height: SizeOf(context).modal.halfModal(),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Exportexcelscreen(),
                  );
                },
              );
            },
            child: const Icon(
              CupertinoIcons.share,
              size: 24.0,
              color: Colors.white,
            )),
      ),
      body: SafeArea(
        child: isLoading
            ? Center(
                child: _buildLoadingIndicator(),
              )
            : Column(
                children: [
                  _buildBannerAd(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildMonthSelector(),
                          const SizedBox(height: 16),
                          _buildTotalSpentText(context),
                          const SizedBox(height: 8),
                          _buildPageView(),
                          _buildPageIndicators(),
                          const SizedBox(height: 12),
                          _buildTotalSpentCarousel(),
                          const SizedBox(height: 8),
                          if (isLoading)
                            _buildLoadingIndicator()
                          else
                            _buildProgressIndicators(context),
                        ],
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
