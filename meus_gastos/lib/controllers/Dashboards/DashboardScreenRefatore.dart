import 'dart:io';
import 'package:meus_gastos/controllers/Dashboards/DashboardViewModel.dart';
import 'package:meus_gastos/controllers/Transactions/TransactionsViewModel.dart';
import 'package:meus_gastos/controllers/ads_review/BannerAdFactory.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/controllers/Dashboards/ViewComponents/monthInsights/TotalSpentCarousel.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/controllers/exportExcel/exportExcelScreen.dart';

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

// Imports de widgets
import 'package:meus_gastos/controllers/Dashboards/ViewComponents/DashboardCard.dart';
import 'package:meus_gastos/controllers/Dashboards/ViewComponents/MonthSelector.dart';
import 'package:meus_gastos/controllers/Dashboards/ViewComponents/LinearProgressIndicatorSection.dart';

class DashboardScreen extends StatefulWidget {
  final bool isActive;

  const DashboardScreen({Key? key, this.isActive = false}) : super(key: key);

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  final GlobalKey<TotalSpentCarouselWithTitlesState> insights =
      GlobalKey<TotalSpentCarouselWithTitlesState>();

  
  // List<ProgressIndicatorModel> progressIndicators2 = [
  //   ProgressIndicatorModel(
  //     title: "Alimentação",
  //     progress: 400,
  //     category: CategoryModel(
  //       id: "1",
  //       name: "Alimentação",
  //       color: Color.fromARGB(255, 41, 40, 40),
  //       icon: CupertinoIcons.cart,
  //       frequency: 5,
  //     ),
  //     color: Color.fromARGB(255, 41, 40, 40),
  //   ),
  //   ProgressIndicatorModel(
  //     title: "Transporte",
  //     progress: 200,
  //     category: CategoryModel(
  //       id: "2",
  //       name: "Transporte",
  //       color: Color.fromARGB(255, 41, 40, 40),
  //       icon: CupertinoIcons.car,
  //       frequency: 3,
  //     ),
  //     color: Color.fromARGB(255, 41, 40, 40),
  //   ),
  //   ProgressIndicatorModel(
  //     title: "Lazer",
  //     progress: 300,
  //     category: CategoryModel(
  //       id: "3",
  //       name: "Lazer",
  //       color: Color.fromARGB(255, 41, 40, 40),
  //       icon: CupertinoIcons.smiley,
  //       frequency: 2,
  //     ),
  //     color: Color.fromARGB(255, 41, 40, 40),
  //   ),
  // ];

  final PageController _pageController = PageController();
  // int _currentIndex = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // _onScreenDisplayed();
  }

  void inicializeDashboard() {
    // _currentIndex = 0;
    // _onScreenDisplayed();
  }

  // Future<void> _onScreenDisplayed() async {
  //   if (widget.isActive) {
  //     await _loadInitialData();
  //   }
  //   totalexpens = await CardService.getTotalExpenses(currentDate);
  // }

  Future<void> _loadInitialData() async {
    // await _loadProgressIndicators(currentDate);
  }

  void _onPageChanged(int index) {
    setState(() {
      // _currentIndex = index;
      _currentIndexNotifier.value = index;
    });
  }

  

  void refreshData() {
    // _onScreenDisplayed();
    _loadInitialData();
  }

  Widget _buildBannerAd() {
    return BannerAdFactory().build();
  }

  Widget _buildMonthSelector(DashboardViewModel dashboardVM) {
    return MonthSelector(
      currentDate: dashboardVM.currentDate,
      onChangeMonth: dashboardVM.changeMonth,
    );
  }

  double _calculatePageHeight(DashboardViewModel dashboardVM) {
    double baseHeight = 300;
    double heightPerLine = 40;
    List<String> labels = dashboardVM.pieChartDataItems.map((item) => item.label).toList();
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
    double maxHeight = MediaQuery.of(context).size.height - 70;
    double pageHeight = baseHeight + additionalHeight;
    pageHeight = pageHeight.clamp(minHeight, maxHeight);
    return pageHeight;
  }

  Widget _buildTotalSpentCarousel(DashboardViewModel dashboardVM) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      child: SizedBox(
        height: 520,
        child: dashboardVM.totalGasto == 0
            ? Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.card, AppColors.background1],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.insights,
                      color: AppColors.label,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.monthlyInsights,
                      style: const TextStyle(
                        color: AppColors.label,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)!
                          .youWillBeAbleToUnderstandYourExpensesHere,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.label,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              )
            : TotalSpentCarouselWithTitles(currentDate: dashboardVM.currentDate),
      ),
    );
  }

  Widget _buildPageView(DashboardViewModel dashboardVM) {
    double pageHeight = _calculatePageHeight(dashboardVM);
    print(" Consumer rebuildou! Total de categorias: ${dashboardVM.cards.length}");
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
              items: dashboardVM.pieChartDataItems,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 8.0, right: 8.0, top: 4, bottom: 8),
            child: WeeklyStackedBarChart(
              weekIntervals: dashboardVM.Last5WeeksIntervals,
              weeklyData: dashboardVM.Last5WeeksProgressIndicators,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 8.0, right: 8.0, top: 4, bottom: 8),
            child: DailyStackedBarChart(
              last5weewdailyData: dashboardVM.weeklyData,
              last5WeeksIntervals: dashboardVM.Last5WeeksIntervals,
            ),
          ),
        ],
      ),
    );
  }

  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);
//mark - view: PageView indicators
  Widget _buildPageIndicators() {
    bool isMac = Platform.isMacOS;
    return ValueListenableBuilder<int>(
      valueListenable: _currentIndexNotifier,
      builder: (context, currentIndex, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(3, (index) {
            Widget indicator = Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              width: isMac ? 16.0 : 12.0,
              height: isMac ? 16.0 : 12.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentIndex == index
                    ? AppColors.button
                    : AppColors.buttonSelected,
              ),
            );
            return isMac
                ? GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: indicator,
                  )
                : indicator;
          }),
        );
      },
    );
  }

  Widget _buildProgressIndicators(BuildContext context, DashboardViewModel dashboardVM) {
    if (dashboardVM.progressIndicators.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.topExpensesOfTheMonth,
            style: const TextStyle(
              color: AppColors.label,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.categoryExpensesDescription,
            style: const TextStyle(
              color: AppColors.label,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
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
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        for (var progressIndicator in dashboardVM.progressIndicators)
          GestureDetector(
            onTap: () => _showExpenseDetails(context, progressIndicator, dashboardVM),
            child: LinearProgressIndicatorSection(
              model: progressIndicator,
              totalAmount: dashboardVM.progressIndicators.fold(
                  0,
                  (maxValue, item) =>
                      maxValue > item.progress ? maxValue : item.progress),
            ),
          ),
      ],
    );
  }

  void _showExpenseDetails(BuildContext context, ProgressIndicatorModel model, DashboardViewModel dashboardVM) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height - 70,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: ExtractByCategory(
              category: model.category.name, currentMonth: dashboardVM.currentDate),
        ); // O widget com o código acima
      },
    );
    // showCupertinoModalPopup(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return Container(
    //       height: MediaQuery.of(context).size.height - 70,
    //       decoration: const BoxDecoration(
    //         borderRadius: BorderRadius.only(
    //           topLeft: Radius.circular(20),
    //           topRight: Radius.circular(20),
    //         ),
    //       ),
    //       child: ExtractByCategory(
    //           category: model.category.name, currentMonth: currentDate),
    //     );
    //   },
    // );
  }

  Widget _buildLoadingIndicator() {
    return const CircularProgressIndicator(color: AppColors.background1);
  }

  Widget _buildTotalSpentText(BuildContext context, DashboardViewModel dashboardVM) {
    return Text(
      "${AppLocalizations.of(context)!.totalSpent}: ${TranslateService.formatCurrency(dashboardVM.totalGasto, context)}",
      style: const TextStyle(
        color: AppColors.label,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.background1,
      appBar: CupertinoNavigationBar(
        middle: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: Text(
            AppLocalizations.of(context)!.myControl,
            style: const TextStyle(color: AppColors.label, fontSize: 20),
          ),
        ),
        backgroundColor: AppColors.background1,
        trailing: GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (BuildContext context) {
                return Exportexcelscreen(); // O widget com o código acima
              },
            );
          },
          child: const Icon(
            CupertinoIcons.share,
            size: 24.0,
            color: Colors.white,
          ),
        ),
      ),
      body: Consumer<DashboardViewModel>(
        builder: (context, dashboardVM, child) => SafeArea(
          child: dashboardVM.isLoading
              ? Center(child: _buildLoadingIndicator())
              : Column(
                  children: [
                    _buildBannerAd(),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            _buildMonthSelector(dashboardVM),
                            const SizedBox(height: 16),
                            _buildTotalSpentText(context, dashboardVM),
                            const SizedBox(height: 8),
                            _buildPageView(dashboardVM),
                            _buildPageIndicators(),
                            const SizedBox(height: 12),
                            _buildTotalSpentCarousel(dashboardVM),
                            const SizedBox(height: 8),
                            if (dashboardVM.isLoading)
                              _buildLoadingIndicator()
                            else
                              _buildProgressIndicators(context, dashboardVM),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
