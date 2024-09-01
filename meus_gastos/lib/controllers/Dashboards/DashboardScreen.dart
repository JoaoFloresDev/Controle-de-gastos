import 'package:meus_gastos/controllers/Transactions/exportExcel/exportExcelScreen.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';

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
  //mark - propriedades
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

  PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _onScreenDisplayed();
  }

  //mark - métodos privados
  Future<void> _onScreenDisplayed() async {
    if (widget.isActive) {
      await _loadInitialData();
    }
    totalexpens = await CardService.getTotalExpenses(currentDate);
  }

  Future<void> _loadInitialData() async {
    await _loadProgressIndicators(currentDate);
    await _loadProgressMonthsInYear(currentDate);
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
    pieChartDataItems = progressIndicators
        .map((indicator) => indicator.toPieChartDataItem())
        .toList();

    totalGasto = progressIndicators.fold(
        0.0, (sum, indicator) => sum + indicator.progress);

    totalOfMonths = await CardService.getTotalExpensesByMonth(currentDate);

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
    return SizedBox(
      height: 60,
      width: double.infinity,
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
    // Defina um valor base para o cálculo da altura
    double baseHeight = 300;

    // Calcule o incremento na altura com base no número de itens
    double additionalHeight =
        (pieChartDataItems.length.toDouble() / 2 * 40).clamp(40, 120);

    // Defina um valor mínimo e máximo para a altura
    double minHeight = 400;

    // Calcule a altura total
    double pageHeight = baseHeight + additionalHeight;

    // Assegure-se de que a altura esteja dentro dos limites mínimos e máximos
    if (pageHeight < minHeight) {
      pageHeight = minHeight;
    }

    return pageHeight;
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

  Widget _buildPageView() {
    double pageHeight = _calculatePageHeight();

    return SizedBox(
      height: pageHeight,
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
                ? AppColors.buttonSelected
                : AppColors.buttonDeselected,
          ),
        );
      }),
    );
  }

  Widget _buildProgressIndicators(BuildContext context) {
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
          height: SizeOf(context).modal.mediumModal(),
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
    return const CircularProgressIndicator(color: AppColors.label);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
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
    );
  }

  //mark - construção da tela
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background1,
      navigationBar: CupertinoNavigationBar(
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
            size: 24.0, // Ajuste o tamanho conforme necessário
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildBannerAd(),
            if (totalexpens > 0)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      _buildMonthSelector(),
                      const SizedBox(height: 18),
                      _buildTotalSpentText(context),
                      _buildPageView(),
                      const SizedBox(height: 12),
                      _buildPageIndicators(),
                      const SizedBox(height: 12),
                      if (isLoading)
                        _buildLoadingIndicator()
                      else
                        _buildProgressIndicators(context),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: _buildEmptyState(context),
              ),
          ],
        ),
      ),
    );
  }
}
