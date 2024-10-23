import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'package:meus_gastos/models/CategoryModel.dart';
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
      color: Color.fromARGB(255, 41, 40, 40), // Cor do indicador
    ),
    ProgressIndicatorModel(
      title: "Transporte",
      progress: 200,
      category: CategoryModel(
        id: "2",
        name: "Transporte",
        color: Color.fromARGB(255, 41, 40, 40), // Cor para a categoria
        icon: CupertinoIcons.car, // Ícone fictício
        frequency: 3, // Frequência de ocorrência
      ),
      color: Color.fromARGB(255, 41, 40, 40), // Cor do indicador
    ),
    ProgressIndicatorModel(
      title: "Lazer",
      progress: 300,
      category: CategoryModel(
        id: "3",
        name: "Lazer",
        color: Color.fromARGB(255, 41, 40, 40), // Cor para a categoria
        icon: CupertinoIcons.smiley, // Ícone fictício
        frequency: 2, // Frequência de ocorrência
      ),
      color: Color.fromARGB(255, 41, 40, 40), // Cor do indicador
    ),
  ];

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

  //mark - métodos privados
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

  // Future<void> _loadProgressMonthsInYear(DateTime currentDate) async {
  //   totalOfMonths = await CardService.getTotalExpensesByMonth(currentDate);
  //   totalExpansivesMonths_category =
  //       await CardService.getMonthlyExpensesByCategoryForYear(currentDate.year);
  // }

  Future<void> _loadProgressIndicators(DateTime currentDate) async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    progressIndicators =
        await CardService.getProgressIndicatorsByMonth(currentDate);
    // print("............. ${progressIndicators.length}");
    pieChartDataItems = progressIndicators
        .map((indicator) => indicator.toPieChartDataItem())
        .toList();

    totalGasto = progressIndicators.fold(
        0.0, (sum, indicator) => sum + indicator.progress);

    // totalOfMonths = await CardService.getTotalExpensesByMonth(currentDate);

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
      width: 468,
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
    return const CircularProgressIndicator(color: AppColors.background1);
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
                ],
              ),
      ),
    );
  }

  void _showMenuOptions(BuildContext context) {
  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) {
      return CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              _launchURL('https://www.apple.com/legal/internet-services/itunes/dev/stdeula/');
            },
            child: const Text('Terms of Use'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              _launchURL('https://drive.google.com/file/d/147xkp4cekrxhrBYZnzV-J4PzCSqkix7t/view?usp=sharing');
            },
            child: const Text('Privacy Policy'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      );
    },
  );
}

void _launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
}
