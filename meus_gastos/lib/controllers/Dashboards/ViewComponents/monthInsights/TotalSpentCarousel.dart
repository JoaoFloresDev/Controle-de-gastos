import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/controllers/Dashboards/ViewComponents/monthInsights/monthInsightsServices.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'dart:io';

class TotalSpentCarouselWithTitles extends StatefulWidget {
  final DateTime currentDate;
  late final Future<double> dailyAverageSpent;

  TotalSpentCarouselWithTitles({
    Key? key,
    required this.currentDate,
  });

  @override
  TotalSpentCarouselWithTitlesState createState() =>
      TotalSpentCarouselWithTitlesState();
}

class TotalSpentCarouselWithTitlesState
    extends State<TotalSpentCarouselWithTitles> {
  final PageController _pageController = PageController(viewportFraction: 0.9);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  double avaregeDaily = 0.0;
  double monthExpenses = 0.0;
  double monthFixedExpenses = 0.0;
  double monthFixedExpensesTotals = 0.0;
  double avaregeBusinessDailys = 0.0;
  double businessExpensives = 0.0;
  double avaregeWeekendExpensives = 0.0;
  double weekendExpensives = 0.0;
  List<MapEntry<String, double>> daysWithMostVariavelExepenses = [];
  double averageCostPerPurchase = 0.0;
  int transectionsDaily = 9;
  Map<int, double> dayWithHigerExpense = {};
  List<double> tenDaysExpenses = [];
  Map<String, double> resumeCurrentMonth = {};
  Map<String, double> resumePreviousMonth = {};
  Map<String, double> highestIncrease = {};
  Map<String, double> highestDrop = {};
  Map<String, int> highestFrequency = {};
  Map<String, double> listOfExpensesByCategoryOfCurrentMonth = {};
  Map<String, double> listOfExpenseByCategoryOfPreviousMonth = {};
  Map<String, double> listDiferencesExpenseByCategory = {};
  double projecaoFixed = 0.0;
  late List<CategoryModel> categories = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getValues(widget.currentDate);
  }

  //didChanges...
  // @override
  // Future<void> didChangeDependencies() async {
  //   super.didChangeDependencies();
  //   await buildGroupedPhrases(widget.currentDate);
  // }

  // @override
  // void didUpdateWidget(TotalSpentCarouselWithTitles oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   // Atualiza os textos quando a `referenceDate` for alterada
  //   print("${widget.currentDate}AAAAAAAAAAA");
  //   if (widget.currentDate != oldWidget.currentDate) {
  //       getValues(widget.currentDate);
  //     setState(() {
  //     });
  //   }
  // }

  Widget _buildLoadingIndicator() {
    return const CircularProgressIndicator(color: AppColors.background1);
  }

  Future<void> getValues(DateTime currentDate) async {
    setState(() {
      isLoading = true;
    });
    await CardService.retrieveCards();
    categories = await CategoryService().getAllCategories();

    var mediaValues = await Monthinsightsservices.monthExpenses(currentDate);
    var gastosMensaisAteAgora =
        await Monthinsightsservices.monthExpenses(currentDate);
    var ValuesFixeds =
        await Monthinsightsservices.getFixedExpenses(currentDate);
    var valuesBusnisses =
        await Monthinsightsservices.getBusinessDaysExpenses(currentDate);
    var valuesWeekends =
        await Monthinsightsservices.getWeekendExpenses(currentDate);
    var daysExpensers =
        await Monthinsightsservices.doisDiasComMaiorGasto(currentDate);
    var averageCostPerPurchaseAux =
        await Monthinsightsservices.avaregeCostPerPurchase(currentDate);
    var mediaDiariaDeTransacoes =
        await Monthinsightsservices.avareCardsByDay(currentDate);
    var auxiliarDayWithBiggerExpense =
        await Monthinsightsservices.dayWithHigerExpense(currentDate);
    var auxDezenasDaysExpenses =
        await Monthinsightsservices.expensesInDezenas(currentDate);
    resumePreviousMonth = await Monthinsightsservices.resumeMonth(
        Monthinsightsservices.diminuirUmMes(currentDate));
    resumeCurrentMonth = await Monthinsightsservices.resumeMonth(currentDate);
    listDiferencesExpenseByCategory =
        await Monthinsightsservices.diferencesExpenseByCategory(currentDate);
    highestFrequency =
        await Monthinsightsservices.mostFrequentCategoryByMonth(currentDate);
    listOfExpensesByCategoryOfCurrentMonth =
        await Monthinsightsservices.expenseByCategoryOfCurrentMonth(
            currentDate);
    listOfExpenseByCategoryOfPreviousMonth =
        await Monthinsightsservices.expenseByCategoryOfPreviousMonth(
            currentDate);
    projecaoFixed =
        await Monthinsightsservices.projectionFixedForTheMonth(currentDate);
    highestIncrease = await Monthinsightsservices.highestIncreaseCategory(
        listDiferencesExpenseByCategory);
    highestDrop = await Monthinsightsservices.highestDropCategory(
        listDiferencesExpenseByCategory);

    setState(() {
      avaregeDaily =
          Monthinsightsservices.dailyAverage(currentDate, mediaValues);
      // gastos do mes selecionado em questão
      monthExpenses = gastosMensaisAteAgora;
      monthFixedExpensesTotals = ValuesFixeds;
      monthFixedExpenses =
          Monthinsightsservices.dailyAverage(currentDate, ValuesFixeds);
      businessExpensives = valuesBusnisses;
      avaregeBusinessDailys = Monthinsightsservices.dailyAverageBusinessDays(
          currentDate, valuesBusnisses);
      weekendExpensives = valuesWeekends;
      avaregeWeekendExpensives = Monthinsightsservices.dailyAverageWeekendDays(
          currentDate, valuesWeekends);
      daysWithMostVariavelExepenses = daysExpensers;
      averageCostPerPurchase = averageCostPerPurchaseAux;
      transectionsDaily = mediaDiariaDeTransacoes.round();
      dayWithHigerExpense = auxiliarDayWithBiggerExpense;
      tenDaysExpenses = auxDezenasDaysExpenses;
      resumeCurrentMonth = resumeCurrentMonth;
      resumePreviousMonth = resumePreviousMonth;
      highestIncrease = highestIncrease;
      highestDrop = highestDrop;
      highestFrequency = highestFrequency;
      listOfExpensesByCategoryOfCurrentMonth =
          listOfExpensesByCategoryOfCurrentMonth;
      listDiferencesExpenseByCategory = listDiferencesExpenseByCategory;
      projecaoFixed = projecaoFixed;
      isLoading = false;
    });
    print(listOfExpensesByCategoryOfCurrentMonth[highestFrequency.keys.first]);
  }

  Future<List<Map<String, dynamic>>> buildGroupedPhrases(
      DateTime currentDate) async {
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
                "${AppLocalizations.of(context)!.geral}: ${TranslateService.formatCurrency(((currentDate.month == DateTime.now().month && currentDate.year == DateTime.now().year)) ? ((avaregeDaily - monthFixedExpenses) * Monthinsightsservices.daysInCurrentMonth(currentDate) + projecaoFixed) : monthExpenses + (((currentDate.month > DateTime.now().month && currentDate.year == DateTime.now().year) || (currentDate.year > DateTime.now().year)) ? projecaoFixed : 0), context)}",
              ],
              [
                "${AppLocalizations.of(context)!.custoFixo}: ${TranslateService.formatCurrency(projecaoFixed, context)} (${((projecaoFixed == 0 ? 0 : projecaoFixed) / ((currentDate.month == DateTime.now().month && currentDate.year == DateTime.now().year) ? ((((avaregeDaily == 0 ? 0 : avaregeDaily) - (monthFixedExpenses == 0 ? 0 : monthFixedExpenses)) * Monthinsightsservices.daysInCurrentMonth(currentDate)) + (projecaoFixed == 0 ? 1 : projecaoFixed)) : (monthExpenses == 0 ? (projecaoFixed == 0 ? 1 : projecaoFixed) : monthExpenses)) * 100).round()}%)",
                "${AppLocalizations.of(context)!.custoVariavel}: ${TranslateService.formatCurrency(((avaregeDaily - monthFixedExpenses) * Monthinsightsservices.daysInCurrentMonth(currentDate)), context)} "
                    "(${(((avaregeDaily == 0 ? 0 : avaregeDaily) - (monthFixedExpenses == 0 ? 0 : monthFixedExpenses)) * Monthinsightsservices.daysInCurrentMonth(currentDate) / ((currentDate.month == DateTime.now().month && currentDate.year == DateTime.now().year) ? (((avaregeDaily == 0 ? 0 : avaregeDaily) - (monthFixedExpenses == 0 ? 0 : monthFixedExpenses)) * Monthinsightsservices.daysInCurrentMonth(currentDate) + (projecaoFixed == 0 ? 1 : projecaoFixed)) : (monthExpenses == 0 ? 1 : monthExpenses)) * 100).round()}%)"
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
                "${AppLocalizations.of(context)!.dailyTransactions}: $transectionsDaily"
              ],
              [
                "${AppLocalizations.of(context)!.mostExpensiveDay}: ${dayWithHigerExpense.isNotEmpty ? getFormatResume(dayWithHigerExpense.keys.first) : '-'} - ${TranslateService.formatCurrency(dayWithHigerExpense.isNotEmpty ? dayWithHigerExpense.values.first : 0, context)}"
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      print("TACARREGANDOOOOO");
      return Center(child: _buildLoadingIndicator());
    }
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1.0)),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: buildGroupedPhrases(widget.currentDate),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.label),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: AppColors.label),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            // Show loading while waiting for data to avoid showing zeroed values
            return const Center(
              child: CircularProgressIndicator(color: AppColors.label),
            );
          } else {
            final groupedPhrases = snapshot.data!;
            return Stack(
              children: [
                PageView.builder(
                  itemCount: groupedPhrases.length,
                  controller: _pageController,
                  itemBuilder: (context, index) {
                    final group = groupedPhrases[index];
                    final sections =
                        group['sections'] as List<Map<String, dynamic>>;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 16, bottom: 0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color.fromARGB(255, 32, 32, 32),
                            AppColors.card2
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha((0.1 * 255).toInt()),
                            offset: const Offset(0, 4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: sections.map<Widget>((section) {
                          final title = section['title'] as String;
                          final phrases =
                              section['phrases'] as List<List<String>>;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  color: AppColors.label,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (int i = 0; i < phrases.length; i++) ...[
                                    Column(
                                      children: phrases[i].map((phrase) {
                                        final parts = phrase.split(':');
                                        final label = parts[0].trim();
                                        final value =
                                            parts.sublist(1).join(':').trim();
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  label,
                                                  style: const TextStyle(
                                                    color: AppColors.label,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: RichText(
                                                    text: TextSpan(
                                                      children: _styleValue(
                                                        value,
                                                        const TextStyle(
                                                          color:
                                                              AppColors.label,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    if (i < phrases.length - 1)
                                      const Divider(
                                        color: Colors.grey,
                                        thickness: 0.5,
                                        height: 10,
                                      ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
                if (Platform.isMacOS) ...[
                  Positioned(
                    left: 10,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios,
                          color: AppColors.button),
                      onPressed: () {
                        final prevPage =
                            ((_pageController.page?.round() ?? 0) - 1);
                        if (prevPage >= 0) {
                          _pageController.animateToPage(
                            prevPage,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios,
                          color: AppColors.button),
                      onPressed: () {
                        final nextPage =
                            ((_pageController.page?.round() ?? 0) + 1);
                        if (nextPage < groupedPhrases.length) {
                          _pageController.animateToPage(
                            nextPage,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ],
            );
          }
        },
      ),
    );
  }

  List<TextSpan> _styleValue(String value, TextStyle defaultStyle) {
    final RegExp regex =
        RegExp(r'\(([-+]?\d+)%\)'); // Captura números entre parênteses
    final match = regex.firstMatch(value);

    if (match != null) {
      final percentage = match.group(1);
      final styledValue =
          value.replaceAll(regex, '').trim(); // Remove o parêntese e conteúdo

      final color = percentage!.startsWith('+')
          ? Colors.red
          : percentage.startsWith('-')
              ? Colors.green
              : Colors.grey;

      return [
        TextSpan(
          text: styledValue,
          style: defaultStyle,
        ),
        TextSpan(
          text: ' $percentage%',
          style: TextStyle(
            color: color,
            fontSize: defaultStyle.fontSize! * 0.8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ];
    }

    return [TextSpan(text: value, style: defaultStyle)];
  }

  String getFormatResume(int day) {
    final DateFormat formatter =
        DateFormat(AppLocalizations.of(context)!.resumeDateFormat);

    return '${formatter.format(DateTime(widget.currentDate.year, widget.currentDate.month, day))}';
  }
}
