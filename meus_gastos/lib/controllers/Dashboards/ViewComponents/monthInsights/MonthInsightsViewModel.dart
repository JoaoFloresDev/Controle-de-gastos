import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/controllers/Dashboards/ViewComponents/monthInsights/MonthInsightsServices.dart';
import 'package:meus_gastos/controllers/Transactions/TransactionsViewModel.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'package:meus_gastos/services/TranslateService.dart';

class MonthInsightsViewModel extends ChangeNotifier {
  TransactionsViewModel transactionsViewModel;

  MonthInsightsViewModel({required this.transactionsViewModel}) {
    print(">>> NOVO VIEWMODEL CRIADO <<<");
  }

  bool isLoading = false;

  DateTime currentDate = DateTime.now();

  List<CategoryModel> categories = [];
  List<CardModel> cards = [];
  double avaregeDaily = 0;
  double monthExpenses = 0;
  double monthFixedExpensesTotals = 0;
  double monthFixedExpenses = 0;
  double businessExpensives = 0;
  double avaregeBusinessDailys = 0;
  double weekendExpensives = 0;
  double avaregeWeekendExpensives = 0;
  List<dynamic> daysWithMostVariavelExepenses = [];
  double averageCostPerPurchase = 0;
  int transectionsDaily = 0;
  Map<int, double> dayWithHigerExpense = {};
  List<double> tenDaysExpenses = [];
  Map<String, dynamic> resumeCurrentMonth = {};
  Map<String, dynamic> resumePreviousMonth = {};
  Map<String, double> highestIncrease = {};
  Map<String, double> highestDrop = {};
  Map<String, int> highestFrequency = {};
  Map<String, double> listOfExpensesByCategoryOfCurrentMonth = {};
  Map<String, double> listOfExpenseByCategoryOfPreviousMonth = {};
  Map<String, double> listDiferencesExpenseByCategory = {};
  double projecaoFixed = 0;

  final Monthinsightsservices _monthServices = Monthinsightsservices();
  final CategoryService _categoryService = CategoryService();

  Future<void> loadValues(DateTime NewDate) async {
    isLoading = true;
    notifyListeners();

    currentDate = NewDate;

    await getValues();

    isLoading = false;
    notifyListeners();
  }

  void getCards(){
    cards = transactionsViewModel.cardList;
  }

  Future<void> getValues() async {
    isLoading = true;
    notifyListeners();

    getCards();
    categories = await _categoryService.getAllCategories();
    print(">>> loadValues() rodou, qtd cards: ${cards.length} | data: ${currentDate}");
    monthExpenses = await _monthServices.monthExpenses(currentDate, cards);

    monthFixedExpensesTotals =
        await _monthServices.getFixedExpenses(currentDate, cards);
    businessExpensives =
        await _monthServices.getBusinessDaysExpenses(currentDate, cards);
    weekendExpensives =
        await _monthServices.getWeekendExpenses(currentDate, cards);
    daysWithMostVariavelExepenses =
        await _monthServices.doisDiasComMaiorGasto(currentDate, cards);
    averageCostPerPurchase =
        await _monthServices.avaregeCostPerPurchase(currentDate, cards);
    transectionsDaily = await _monthServices
        .avareCardsByDay(currentDate, cards)
        .then((value) => value.round());
    dayWithHigerExpense =
        await _monthServices.dayWithHigerExpense(currentDate, cards);
    tenDaysExpenses =
        await _monthServices.expensesInDezenas(currentDate, cards);

    resumePreviousMonth = await _monthServices.resumeMonth(
        _monthServices.diminuirUmMes(currentDate), cards);
    resumeCurrentMonth = await _monthServices.resumeMonth(currentDate, cards);

    listDiferencesExpenseByCategory =
        await _monthServices.diferencesExpenseByCategory(currentDate, cards);
    highestFrequency =
        await _monthServices.mostFrequentCategoryByMonth(currentDate, cards);
    listOfExpensesByCategoryOfCurrentMonth = await _monthServices
        .expenseByCategoryOfCurrentMonth(currentDate, cards);
    listOfExpenseByCategoryOfPreviousMonth = await _monthServices
        .expenseByCategoryOfPreviousMonth(currentDate, cards);
    projecaoFixed =
        await _monthServices.projectionFixedForTheMonth(currentDate, cards);
    highestIncrease = await _monthServices.highestIncreaseCategory(
        listDiferencesExpenseByCategory, cards);
    highestDrop = await _monthServices.highestDropCategory(
        listDiferencesExpenseByCategory, cards);

    avaregeDaily = _monthServices.dailyAverage(currentDate, monthExpenses);

    monthFixedExpenses =
        _monthServices.dailyAverage(currentDate, monthFixedExpensesTotals);
    businessExpensives = businessExpensives;
    avaregeBusinessDailys = _monthServices.dailyAverageBusinessDays(
        currentDate, businessExpensives);

    avaregeWeekendExpensives =
        _monthServices.dailyAverageWeekendDays(currentDate, weekendExpensives);

    isLoading = false;
    notifyListeners();
    print(listOfExpensesByCategoryOfCurrentMonth[highestFrequency.keys.first]);
  }

  List<Map<String, dynamic>> buildGroupedPhrases(
      BuildContext context, DateTime currentDate) {
    if (isLoading) return [];
    return [
      {
        "sections": [
          {
            "title": AppLocalizations.of(context)!.mediaDiaria,
            "phrases": [
              [
                "${AppLocalizations.of(context)!.geral}: ${TranslateService.formatCurrency(avaregeDaily, context)}",
              ],
              [
                "${AppLocalizations.of(context)!.custoFixo}: ${TranslateService.formatCurrency(monthFixedExpenses, context)} (${_safePercent(monthFixedExpenses, avaregeDaily)}%)",
                "${AppLocalizations.of(context)!.custoVariavel}: ${TranslateService.formatCurrency((avaregeDaily - monthFixedExpenses), context)} (${_safePercent(avaregeDaily - monthFixedExpenses, avaregeDaily)}%)"
              ],
              [
                "${AppLocalizations.of(context)!.diasUteis}: ${TranslateService.formatCurrency(avaregeBusinessDailys, context)} (${_safePercent(businessExpensives, monthExpenses)}%)",
                "${AppLocalizations.of(context)!.finaisDeSemana}: ${TranslateService.formatCurrency(avaregeWeekendExpensives, context)} (${_safePercent(avaregeWeekendExpensives, monthExpenses)}%)",
              ],
            ],
          },
          {
            "title": AppLocalizations.of(context)!.diasMaiorCustoVariavel,
            "phrases": [
              [
                daysWithMostVariavelExepenses.length >= 2
                    ? "1. ${daysWithMostVariavelExepenses[0].key}: ${TranslateService.formatCurrency(daysWithMostVariavelExepenses[0].value, context)} (${_safePercent(daysWithMostVariavelExepenses[0].value, monthExpenses)}%)"
                    : "",
                daysWithMostVariavelExepenses.length >= 2
                    ? "2. ${daysWithMostVariavelExepenses[1].key}: ${TranslateService.formatCurrency(daysWithMostVariavelExepenses[1].value, context)} (${_safePercent(daysWithMostVariavelExepenses[1].value, monthExpenses)}%)"
                    : ""
              ],
            ],
          },
          {
            "title": AppLocalizations.of(context)!.projecaoMes,
            "phrases": [
              [
                "${AppLocalizations.of(context)!.geral}: ${TranslateService.formatCurrency(((currentDate.month == DateTime.now().month && currentDate.year == DateTime.now().year)) ? ((avaregeDaily - monthFixedExpenses) * Monthinsightsservices().daysInCurrentMonth(currentDate) + projecaoFixed) : monthExpenses + (((currentDate.month > DateTime.now().month && currentDate.year == DateTime.now().year) || (currentDate.year > DateTime.now().year)) ? projecaoFixed : 0), context)}",
              ],
              [
                "${AppLocalizations.of(context)!.custoFixo}: ${TranslateService.formatCurrency(projecaoFixed, context)} (${((projecaoFixed == 0 ? 0 : projecaoFixed) / ((currentDate.month == DateTime.now().month && currentDate.year == DateTime.now().year) ? ((((avaregeDaily == 0 ? 0 : avaregeDaily) - (monthFixedExpenses == 0 ? 0 : monthFixedExpenses)) * Monthinsightsservices().daysInCurrentMonth(currentDate)) + (projecaoFixed == 0 ? 1 : projecaoFixed)) : (monthExpenses == 0 ? (projecaoFixed == 0 ? 1 : projecaoFixed) : monthExpenses)) * 100).round()}%)",
                "${AppLocalizations.of(context)!.custoVariavel}: ${TranslateService.formatCurrency(((avaregeDaily - monthFixedExpenses) * Monthinsightsservices().daysInCurrentMonth(currentDate)), context)} "
                    "(${(((avaregeDaily == 0 ? 0 : avaregeDaily) - (monthFixedExpenses == 0 ? 0 : monthFixedExpenses)) * Monthinsightsservices().daysInCurrentMonth(currentDate) / ((currentDate.month == DateTime.now().month && currentDate.year == DateTime.now().year) ? (((avaregeDaily == 0 ? 0 : avaregeDaily) - (monthFixedExpenses == 0 ? 0 : monthFixedExpenses)) * Monthinsightsservices().daysInCurrentMonth(currentDate) + (projecaoFixed == 0 ? 1 : projecaoFixed)) : (monthExpenses == 0 ? 1 : monthExpenses)) * 100).round()}%)"
              ],
            ],
          },
        ],
      },
      {
        "sections": [
          {
            "title": AppLocalizations.of(context)!.myMonthNow,
            "phrases": [
              [
                "${AppLocalizations.of(context)!.geral}: ${TranslateService.formatCurrency(monthExpenses, context)}"
              ],
              [
                "${AppLocalizations.of(context)!.custoFixo}: ${TranslateService.formatCurrency(monthFixedExpensesTotals, context)} (${_safePercent(monthFixedExpensesTotals, monthExpenses)}%)",
                "${AppLocalizations.of(context)!.custoVariavel}: ${TranslateService.formatCurrency(monthExpenses - monthFixedExpensesTotals, context)} (${_safePercent(monthExpenses - monthFixedExpensesTotals, monthExpenses)}%)"
              ],
              [
                "${AppLocalizations.of(context)!.averageCostPerPurchase}: ${TranslateService.formatCurrency(averageCostPerPurchase > 0 ? averageCostPerPurchase : 0, context)}",
                "${AppLocalizations.of(context)!.dailyTransactions}: ${transectionsDaily}"
              ],
              [
                "${AppLocalizations.of(context)!.mostExpensiveDay}: ${dayWithHigerExpense.isNotEmpty ? getFormatResume(context, currentDate, dayWithHigerExpense.keys.first) : '-'} - ${TranslateService.formatCurrency(dayWithHigerExpense.isNotEmpty ? dayWithHigerExpense.values.first : 0, context)}"
              ]
            ],
          },
          {
            "title": AppLocalizations.of(context)!.distribution,
            "phrases": [
              [
                "${AppLocalizations.of(context)!.firstTenDays}: ${TranslateService.formatCurrency(tenDaysExpenses.isNotEmpty ? tenDaysExpenses[0] : 0, context)} (${_safePercent(tenDaysExpenses.isNotEmpty ? tenDaysExpenses[0] : 0, monthExpenses)}%)",
                "${AppLocalizations.of(context)!.secondTenDays}: ${TranslateService.formatCurrency(tenDaysExpenses.isNotEmpty ? tenDaysExpenses[1] : 0, context)} (${_safePercent(tenDaysExpenses.isNotEmpty ? tenDaysExpenses[1] : 0, monthExpenses)}%)",
                "${AppLocalizations.of(context)!.thirdTenDays}: ${TranslateService.formatCurrency(tenDaysExpenses.isNotEmpty ? tenDaysExpenses[2] : 0, context)} (${_safePercent(tenDaysExpenses.isNotEmpty ? tenDaysExpenses[2] : 0, monthExpenses)}%)"
              ],
            ],
          },
        ],
      },
      {
        "sections": [
          {
            "title": AppLocalizations.of(context)!.currentMonthVsPrevious,
            "phrases": [
              [
                "${AppLocalizations.of(context)!.geral}:"
                    " ${TranslateService.formatCurrency(resumeCurrentMonth['general'] ?? 0, context)} / "
                    "${TranslateService.formatCurrency(resumePreviousMonth['general'] ?? 0, context)} "
                    "(${(resumeCurrentMonth['general'] != null && resumeCurrentMonth['general']! > 0 ? ((((resumeCurrentMonth['general']! - (resumePreviousMonth['general'] ?? 0)) / resumeCurrentMonth['general']!) * 100).round()) : 0) > 0 ? '+' : ''}"
                    "${resumeCurrentMonth['general'] != null && resumeCurrentMonth['general']! > 0 ? ((((resumeCurrentMonth['general']! - (resumePreviousMonth['general'] ?? 0)) / resumeCurrentMonth['general']!) * 100).round()) : 0}%)",
              ],
              [
                "${AppLocalizations.of(context)!.custoFixo}:"
                    " ${TranslateService.formatCurrency(resumeCurrentMonth['fixed'] ?? 0, context)} / "
                    "${TranslateService.formatCurrency(resumePreviousMonth['fixed'] ?? 0, context)} "
                    "(${(resumeCurrentMonth['fixed'] != null && resumeCurrentMonth['fixed']! > 0 ? ((((resumeCurrentMonth['fixed']! - (resumePreviousMonth['fixed'] ?? 0)) / resumeCurrentMonth['fixed']!) * 100).round()) : 0) > 0 ? '+' : ''}"
                    "${resumeCurrentMonth['fixed'] != null && resumeCurrentMonth['fixed']! > 0 ? ((((resumeCurrentMonth['fixed']! - (resumePreviousMonth['fixed'] ?? 0)) / resumeCurrentMonth['fixed']!) * 100).round()) : 0}%)",
                "${AppLocalizations.of(context)!.custoVariavel}: "
                    "${TranslateService.formatCurrency(resumeCurrentMonth['variable'] ?? 0, context)} / "
                    "${TranslateService.formatCurrency(resumePreviousMonth['variable'] ?? 0, context)} "
                    "(${(resumeCurrentMonth['variable'] != null && resumeCurrentMonth['variable']! > 0 ? ((((resumeCurrentMonth['variable']! - (resumePreviousMonth['variable'] ?? 0)) / resumeCurrentMonth['variable']!) * 100).round()) : 0) > 0 ? '+' : ''}"
                    "${resumeCurrentMonth['variable'] != null && resumeCurrentMonth['variable']! > 0 ? ((((resumeCurrentMonth['variable']! - (resumePreviousMonth['variable'] ?? 0)) / resumeCurrentMonth['variable']!) * 100).round()) : 0}%)",
              ],
              [
                "${AppLocalizations.of(context)!.finaisDeSemana}: "
                    "${TranslateService.formatCurrency(resumeCurrentMonth['weekends'] ?? 0, context)} / "
                    "${TranslateService.formatCurrency(resumePreviousMonth['weekends'] ?? 0, context)} "
                    "(${(resumeCurrentMonth['weekends'] != null && resumeCurrentMonth['weekends']! > 0 ? ((((resumeCurrentMonth['weekends']! - (resumePreviousMonth['weekends'] ?? 0)) / resumeCurrentMonth['weekends']!) * 100).round()) : 0) > 0 ? '+' : ''}"
                    "${resumeCurrentMonth['weekends'] != null && resumeCurrentMonth['weekends']! > 0 ? ((((resumeCurrentMonth['weekends']! - (resumePreviousMonth['weekends'] ?? 0)) / resumeCurrentMonth['weekends']!) * 100).round()) : 0}%)",
                "${AppLocalizations.of(context)!.diasUteis}: "
                    "${TranslateService.formatCurrency(resumeCurrentMonth['businessDays'] ?? 0, context)} /"
                    " ${TranslateService.formatCurrency(resumePreviousMonth['businessDays'] ?? 0, context)} "
                    "(${(resumeCurrentMonth['businessDays'] != null && resumeCurrentMonth['businessDays']! > 0 ? ((((resumeCurrentMonth['businessDays']! - (resumePreviousMonth['businessDays'] ?? 0)) / resumeCurrentMonth['businessDays']!) * 100).round()) : 0) > 0 ? '+' : ''}"
                    "${resumeCurrentMonth['businessDays'] != null && resumeCurrentMonth['businessDays']! > 0 ? ((((resumeCurrentMonth['businessDays']! - (resumePreviousMonth['businessDays'] ?? 0)) / resumeCurrentMonth['businessDays']!) * 100).round()) : 0}%)",
              ]
            ],
          },
          {
            "title": AppLocalizations.of(context)!.category,
            "phrases": [
              [
                "${AppLocalizations.of(context)!.highestIncrease}: "
                    "${TranslateService.getTranslatedCategoryName(context, categories.firstWhere(
                          (cat) =>
                              cat.id ==
                              (highestIncrease.isNotEmpty
                                  ? highestIncrease.keys.first
                                  : ''),
                          orElse: () => CategoryModel(id: '', name: ''),
                        ).name)} (+${highestIncrease.isNotEmpty && (listOfExpensesByCategoryOfCurrentMonth[highestIncrease.keys.first] ?? 0) > 0 ? ((highestIncrease.values.first / (listOfExpenseByCategoryOfPreviousMonth[highestIncrease.keys.first] ?? 1))).round() : 0}%)",
                "${AppLocalizations.of(context)!.highestDrop}: "
                    "${TranslateService.getTranslatedCategoryName(context, categories.firstWhere(
                          (cat) =>
                              cat.id ==
                              (highestDrop.isNotEmpty
                                  ? highestDrop.keys.first
                                  : ''),
                          orElse: () => CategoryModel(id: '', name: ''),
                        ).name)} "
                    "(${_calculateDropPercentage(highestDrop, listOfExpenseByCategoryOfPreviousMonth, listOfExpensesByCategoryOfCurrentMonth)}%)",
                "${AppLocalizations.of(context)!.mostUsed}: "
                    "${TranslateService.getTranslatedCategoryName(context, categories.firstWhere(
                          (cat) =>
                              cat.id ==
                              (highestFrequency.isNotEmpty
                                  ? highestFrequency.keys.first
                                  : ''),
                          orElse: () => CategoryModel(id: '', name: ''),
                        ).name)} (${highestFrequency.isNotEmpty ? highestFrequency.values.first : 0}%)"
              ]
            ],
          },
        ],
      }
    ];
  }

  int _calculateDropPercentage(
      Map<String, double> highestDrop,
      Map<String, double> listOfExpenseByCategoryOfPreviousMonth,
      Map<String, double> listOfExpensesByCategoryOfCurrentMonth) {
    if (highestDrop.isEmpty) return 0;
    final key = highestDrop.keys.first;
    final previous = listOfExpenseByCategoryOfPreviousMonth[key] ?? 0;
    final current = listOfExpensesByCategoryOfCurrentMonth[key] ?? 0;

    if (previous == 0) return 0;
    final drop = ((current - previous) / previous) * 100;
    if (drop.isNaN || drop.isInfinite) return 0;
    return drop.round();
  }

  int _safePercent(double value, double total) {
    if (total == 0) return 0;
    final percent = (value / total) * 100;
    if (percent.isNaN || percent.isInfinite) return 0;
    return percent.round();
  }

  String getFormatResume(BuildContext context, DateTime currentDate, int day) {
    final DateFormat formatter =
        DateFormat(AppLocalizations.of(context)!.resumeDateFormat);

    return '${formatter.format(DateTime(currentDate!.year, currentDate!.month, day))}';
  }
}
