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
import 'package:meus_gastos/controllers/ads_review/bannerAdconstruct.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

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
  bool _isPro = false; // Indica se o usuário é PRO
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
    _verifyPastPurchases(); // Verifica se o usuário é PRO
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

  // Método para verificar compras passadas e definir o estado PRO
  Future<void> _verifyPastPurchases() async {
    // Restaura as compras, mas não retorna uma lista diretamente
    await InAppPurchase.instance.restorePurchases();
  
    // O estado de restauração será escutado no listener _listenToPurchaseUpdated
  }

  // Método para carregar os dados na inicialização
  Future<void> _onScreenDisplayed() async {
    if (widget.isActive) {
      await _loadInitialData();
    }
    totalGasto = await CardService.getTotalExpenses(currentDate);
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

    progressIndicators = await CardService.getProgressIndicatorsByMonth(currentDate);
    pieChartDataItems = progressIndicators.map((indicator) => indicator.toPieChartDataItem()).toList();

    totalGasto = progressIndicators.fold(0.0, (sum, indicator) => sum + indicator.progress);

    setState(() {
      isLoading = false;
    });
  }

  Widget _buildBannerAd() {
    if (_isPro) {
      return const SizedBox.shrink(); // Se for PRO, não exibe o banner
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
    double baseHeight = 300;
    double additionalHeight = (pieChartDataItems.length.toDouble() / 2 * 40).clamp(40, 120);
    double minHeight = 400;
    double pageHeight = baseHeight + additionalHeight;

    return pageHeight < minHeight ? minHeight : pageHeight;
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
            child: DashboardCard(items: pieChartDataItems),
          ),
        ],
      ),
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
            onTap: () {},
            child: LinearProgressIndicatorSection(
              model: progressIndicator,
              totalAmount: progressIndicators.fold(
                  0, (maxValue, item) => maxValue > item.progress ? maxValue : item.progress),
            ),
          ),
      ],
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
            size: 24.0,
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
                  _buildBannerAd(), // Mostra ou esconde a propaganda com base no estado _isPro
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
