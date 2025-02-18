import 'dart:io';
import 'package:meus_gastos/controllers/Purchase/ProModalAndroid.dart';
import 'package:meus_gastos/controllers/Transactions/InsertTransactions/ViewComponents/ListCardRecorrent.dart';
import 'package:meus_gastos/gastos_fixos/CardDetails/DetailScreenMainScrean.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:meus_gastos/controllers/Purchase/ProModal.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/gastos_fixos/ListCardFixeds.dart';
import 'package:meus_gastos/gastos_fixos/UI/criar_gastosFixos.dart';
import 'package:meus_gastos/gastos_fixos/fixedExpensesModel.dart';
import 'package:meus_gastos/gastos_fixos/fixedExpensesService.dart';
import '../../../models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart' as service;
import 'package:meus_gastos/controllers/CardDetails/DetailScreen.dart';
import 'package:meus_gastos/controllers/CategoryCreater/CategoryCreater.dart';
import 'package:meus_gastos/controllers/ads_review/constructReview.dart';
import 'package:meus_gastos/controllers/ads_review/bannerAdconstruct.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:meus_gastos/controllers/Dashboards/ViewComponents/monthInsights/TotalSpentCarousel.dart';
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
import 'package:meus_gastos/controllers/Dashboards/ViewComponents/monthInsights/TotalSpentCarousel.dart';
import 'package:flutter/material.dart';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/models/ProgressIndicatorModel.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/services/DashbordService.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:meus_gastos/controllers/ads_review/bannerAdconstruct.dart';
import 'package:meus_gastos/controllers/Dashboards/ViewComponents/DashboardCard.dart';
import 'package:meus_gastos/controllers/Dashboards/ViewComponents/MonthSelector.dart';
import 'package:meus_gastos/controllers/Dashboards/ViewComponents/LinearProgressIndicatorSection.dart';
import 'package:meus_gastos/controllers/Dashboards/ViewComponents/monthInsights/TotalSpentCarousel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DashboardScreen extends StatefulWidget {
  final bool isActive;
  const DashboardScreen({Key? key, this.isActive = false}) : super(key: key);

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  bool _isPro = false;
  final GlobalKey<TotalSpentCarouselWithTitlesState> insights = GlobalKey<TotalSpentCarouselWithTitlesState>();

  List<ProgressIndicatorModel> progressIndicators = [];
  List<PieChartDataItem> pieChartDataItems = [];
  List<double> totalOfMonths = [];
  Map<int, Map<String, Map<String, dynamic>>> totalExpansivesMonths_category = {};
  List<WeekInterval> Last5WeeksIntervals = [];
  List<List<ProgressIndicatorModel>> Last5WeeksProgressIndicators = [];
  List<List<List<ProgressIndicatorModel>>> weeklyData = [];


  double totalexpens = 0.0;
  bool isLoading = true;
  DateTime currentDate = DateTime.now();
  double totalGasto = 0.0;

  final PageController _pageController = PageController();

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
      _currentIndexNotifier.value = index;
  }

  Future<void> _loadProgressIndicators(DateTime currentDate) async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    progressIndicators = await CardService.getProgressIndicatorsByMonth(currentDate);
    pieChartDataItems = progressIndicators.map((indicator) => indicator.toPieChartDataItem()).toList();
    totalGasto = progressIndicators.fold(0.0, (sum, indicator) => sum + indicator.progress);
    Last5WeeksIntervals = Dashbordservice.getLast5WeeksIntervals(currentDate);
    Last5WeeksProgressIndicators = await Dashbordservice.getLast5WeeksProgressIndicators(currentDate);
    weeklyData = await Dashbordservice.getProgressIndicatorsOfDaysForLast5Weeks(currentDate);
    setState(() {
      isLoading = false;
    });
  }

  void refreshData() {
    _onScreenDisplayed();
    _loadInitialData();
  }

  Widget _buildBannerAd() {
    if (_isPro || Platform.isMacOS) return const SizedBox.shrink();
    return Container(
      height: 60,
      width: double.infinity,
      alignment: Alignment.center,
      child: BannerAdconstruct(),
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
        if (i + 1 < labels.length && (current.length + labels[i + 1].length) <= 20) {
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

  Widget _buildTotalSpentCarousel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      child: SizedBox(
        height: 520,
        child: totalGasto == 0 
            ? Container(
              
  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
        AppLocalizations.of(context)!.youWillBeAbleToUnderstandYourExpensesHere,
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

            : TotalSpentCarouselWithTitles(currentDate: currentDate),
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
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4, bottom: 8),
            child: DashboardCard(
              items: pieChartDataItems,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4, bottom: 8),
            child: WeeklyStackedBarChart(
              weekIntervals: Last5WeeksIntervals,
              weeklyData: Last5WeeksProgressIndicators,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4, bottom: 8),
            child: DailyStackedBarChart(
              last5weewdailyData: weeklyData,
              last5WeeksIntervals: Last5WeeksIntervals,
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
              color: currentIndex == index ? AppColors.button : AppColors.buttonSelected,
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

  Widget _buildProgressIndicators(BuildContext context) {
    if (progressIndicators.isEmpty) {
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        for (var progressIndicator in progressIndicators)
          GestureDetector(
            onTap: () => _showExpenseDetails(context, progressIndicator),
            child: LinearProgressIndicatorSection(
              model: progressIndicator,
              totalAmount: progressIndicators.fold(
                  0,
                  (maxValue, item) => maxValue > item.progress ? maxValue : item.progress),
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
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: ExtractByCategory(category: model.category.name),
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
          ),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? Center(child: _buildLoadingIndicator())
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildBannerAd(),
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
                            const SizedBox(height: 40),
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
