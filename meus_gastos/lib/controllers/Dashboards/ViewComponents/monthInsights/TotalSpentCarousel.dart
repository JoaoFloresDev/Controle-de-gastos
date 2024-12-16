import 'package:intl/intl.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/controllers/Dashboards/ViewComponents/monthInsights/monthInsightsServices.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TotalSpentCarouselWithTitles extends StatefulWidget {
  final DateTime currentDate;
  late final Future<double> dailyAverageSpent;

  TotalSpentCarouselWithTitles({
    Key? key,
    required this.currentDate,
  });

  @override
  _TotalSpentCarouselWithTitles createState() =>
      _TotalSpentCarouselWithTitles();
}

class _TotalSpentCarouselWithTitles
    extends State<TotalSpentCarouselWithTitles> {
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

  @override
  void initState() {
    super.initState();
    getValues();
  }

  //didChanges...
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getValues();
  }

  Future<void> getValues() async {
    await CardService.retrieveCards();
    var mediaValues =
        await Monthinsightsservices.monthExpenses(widget.currentDate);
    var gastosMensaisAteAgora =
        await Monthinsightsservices.monthExpenses(widget.currentDate);
    var ValuesFixeds =
        await Monthinsightsservices.getFixedExpenses(widget.currentDate);
    var valuesBusnisses =
        await Monthinsightsservices.getBusinessDaysExpenses(widget.currentDate);
    var valuesWeekends =
        await Monthinsightsservices.getWeekendExpenses(widget.currentDate);
    var daysExpensers =
        await Monthinsightsservices.doisDiasComMaiorGasto(widget.currentDate);
    var averageCostPerPurchaseAux =
        await Monthinsightsservices.avaregeCostPerPurchase(widget.currentDate);
    var mediaDiariaDeTransacoes =
        await Monthinsightsservices.avareCardsByDay(widget.currentDate);
    var auxiliarDayWithBiggerExpense =
        await Monthinsightsservices.dayWithHigerExpense(widget.currentDate);
    var auxDezenasDaysExpenses =
        await Monthinsightsservices.expensesInDezenas(widget.currentDate);
    resumePreviousMonth = await Monthinsightsservices.resumeMonth(
        Monthinsightsservices.diminuirUmMes(widget.currentDate));
    resumeCurrentMonth =
        await Monthinsightsservices.resumeMonth(widget.currentDate);
    setState(() {
      avaregeDaily =
          Monthinsightsservices.dailyAverage(widget.currentDate, mediaValues);

      // gastos do mes selecionado em questão
      monthExpenses = gastosMensaisAteAgora;
      monthFixedExpensesTotals = ValuesFixeds;
      monthFixedExpenses =
          Monthinsightsservices.dailyAverage(widget.currentDate, ValuesFixeds);
      businessExpensives = valuesBusnisses;
      avaregeBusinessDailys = Monthinsightsservices.dailyAverageBusinessDays(
          widget.currentDate, valuesBusnisses);
      weekendExpensives = valuesWeekends;
      avaregeWeekendExpensives = Monthinsightsservices.dailyAverageWeekendDays(
          widget.currentDate, valuesWeekends);
      daysWithMostVariavelExepenses = daysExpensers;
      averageCostPerPurchase = averageCostPerPurchaseAux;
      transectionsDaily = mediaDiariaDeTransacoes.round();
      dayWithHigerExpense = auxiliarDayWithBiggerExpense;
      tenDaysExpenses = auxDezenasDaysExpenses;

      resumeCurrentMonth = resumeCurrentMonth;
      resumePreviousMonth = resumePreviousMonth;
    });
    print(resumeCurrentMonth['businessDays']);
  }

  Future<List<Map<String, dynamic>>> buildGroupedPhrases() async {
    return [
      {
        "sections": [
          {
            "title": "${AppLocalizations.of(context)!.mediaDiaria}",
            "phrases": [
              [
                "${AppLocalizations.of(context)!.geral}: ${Translateservice.formatCurrency(avaregeDaily, context)}",
              ],
              [
                "${AppLocalizations.of(context)!.custoFixo}: ${Translateservice.formatCurrency(monthFixedExpenses, context)} (${(monthFixedExpenses / avaregeDaily * 100).truncate()}%)",
                "${AppLocalizations.of(context)!.custoVariavel}: ${Translateservice.formatCurrency((avaregeDaily - monthFixedExpenses), context)} (${((avaregeDaily - monthFixedExpenses) / avaregeDaily * 100).truncate()}%)"
              ],
              [
                "${AppLocalizations.of(context)!.diasUteis}: ${Translateservice.formatCurrency(avaregeBusinessDailys, context)} (${(businessExpensives / monthExpenses * 100).truncate()}%)",
                "${AppLocalizations.of(context)!.finaisDeSemana}: ${Translateservice.formatCurrency(avaregeWeekendExpensives, context)} (${(avaregeWeekendExpensives / monthExpenses * 100).truncate()}%)",
              ],
            ],
          },
          {
            "title": "${AppLocalizations.of(context)!.diasMaiorCustoVariavel}",
            "phrases": [
              [
                "1. ${daysWithMostVariavelExepenses[0].key}: ${Translateservice.formatCurrency(daysWithMostVariavelExepenses[0].value, context)} (${(daysWithMostVariavelExepenses[0].value / monthExpenses * 100).truncate()}%)",
                "2. ${daysWithMostVariavelExepenses[1].key}: ${Translateservice.formatCurrency(daysWithMostVariavelExepenses[1].value, context)} (${(daysWithMostVariavelExepenses[1].value / monthExpenses * 100).truncate()}%)"
              ],
            ],
          },
          {
            "title": "${AppLocalizations.of(context)!.projecaoMes}",
            "phrases": [
              [
                "${AppLocalizations.of(context)!.geral}: 0.0",
              ],
              [
                "${AppLocalizations.of(context)!.custoFixo}: 0.0 (%)",
                "${AppLocalizations.of(context)!.custoVariavel}: 0.0 (%)"
              ],
            ],
          },
        ],
      },
      {
        "sections": [
          {
            "title": "${AppLocalizations.of(context)!.myMonthNow}",
            "phrases": [
              [
                "${AppLocalizations.of(context)!.geral}: ${Translateservice.formatCurrency(monthExpenses, context)}"
              ],
              [
                "${AppLocalizations.of(context)!.custoFixo}: ${Translateservice.formatCurrency(monthFixedExpensesTotals, context)} (${(monthFixedExpensesTotals / monthExpenses * 100).truncate()}%)",
                "${AppLocalizations.of(context)!.custoVariavel}: ${Translateservice.formatCurrency(monthExpenses - monthFixedExpensesTotals, context)} (${((monthExpenses - monthFixedExpensesTotals) / monthExpenses * 100).truncate()}%)"
              ],
              [
                "${AppLocalizations.of(context)!.averageCostPerPurchase}: ${Translateservice.formatCurrency(averageCostPerPurchase, context)}",
                "${AppLocalizations.of(context)!.dailyTransactions}: ${transectionsDaily}"
              ],
              [
                "${AppLocalizations.of(context)!.mostExpensiveDay}: ${getFormatResume(dayWithHigerExpense.keys.first)} - ${Translateservice.formatCurrency(dayWithHigerExpense.values.first, context)}"
              ]
            ],
          },
          {
            "title": "${AppLocalizations.of(context)!.distribution}",
            "phrases": [
              [
                "${AppLocalizations.of(context)!.firstTenDays}: ${Translateservice.formatCurrency(tenDaysExpenses[0], context)} (${(tenDaysExpenses[0] / monthExpenses * 100).round()}%)",
                "${AppLocalizations.of(context)!.secondTenDays}: ${Translateservice.formatCurrency(tenDaysExpenses[1], context)} (${(tenDaysExpenses[1] / monthExpenses * 100).round()}%)",
                "${AppLocalizations.of(context)!.thirdTenDays}: ${Translateservice.formatCurrency(tenDaysExpenses[2], context)} (${(tenDaysExpenses[2] / monthExpenses * 100).round()}%)"
              ],
            ],
          },
        ],
      },
      {
        "sections": [
          {
            "title": "${AppLocalizations.of(context)!.currentMonthVsPrevious}",
            "phrases": [
              [
                "${AppLocalizations.of(context)!.geral}:"
                    " ${Translateservice.formatCurrency(resumeCurrentMonth['general'] ?? 0, context)} / "
                    "${Translateservice.formatCurrency(resumePreviousMonth['general'] ?? 0, context)} "
                    "(${resumeCurrentMonth['general'] != null && resumeCurrentMonth['general']! > 0 ? ((((resumeCurrentMonth['general']! - (resumePreviousMonth['general'] ?? 0)) / resumeCurrentMonth['general']!) * 100).round()) : 0}%)",
              ],
              [
                "${AppLocalizations.of(context)!.custoFixo}:"
                    " ${Translateservice.formatCurrency(resumeCurrentMonth['fixed'] ?? 0, context)} / "
                    "${Translateservice.formatCurrency(resumePreviousMonth['fixed'] ?? 0, context)} "
                    "(${resumeCurrentMonth['fixed'] != null && resumeCurrentMonth['fixed']! > 0 ? ((((resumeCurrentMonth['fixed']! - (resumePreviousMonth['fixed'] ?? 0)) / resumeCurrentMonth['fixed']!) * 100).round()) : 0}%)",
                "${AppLocalizations.of(context)!.custoVariavel}: "
                    "${Translateservice.formatCurrency(resumeCurrentMonth['variable'] ?? 0, context)} / "
                    "${Translateservice.formatCurrency(resumePreviousMonth['variable'] ?? 0, context)} "
                    "(${resumeCurrentMonth['variable'] != null && resumeCurrentMonth['variable']! > 0 ? ((((resumeCurrentMonth['variable']! - (resumePreviousMonth['variable'] ?? 0)) / resumeCurrentMonth['variable']!) * 100).round()) : 0}%)",
              ],
              [
                "${AppLocalizations.of(context)!.finaisDeSemana}: "
                    "${Translateservice.formatCurrency(resumeCurrentMonth['weekends'] ?? 0, context)} / "
                    "${Translateservice.formatCurrency(resumePreviousMonth['weekends'] ?? 0, context)} "
                    "(${resumeCurrentMonth['weekends'] != null && resumeCurrentMonth['weekends']! > 0 ? ((((resumeCurrentMonth['weekends']! - (resumePreviousMonth['weekends'] ?? 0)) / resumeCurrentMonth['weekends']!) * 100).round()) : 0}%)",
                "${AppLocalizations.of(context)!.diasUteis}: "
                    "${Translateservice.formatCurrency(resumeCurrentMonth['businessDays'] ?? 0, context)} /"
                    " ${Translateservice.formatCurrency(resumePreviousMonth['businessDays'] ?? 0, context)} "
                    "(${resumeCurrentMonth['businessDays'] != null && resumeCurrentMonth['businessDays']! > 0 ? ((((resumeCurrentMonth['businessDays']! - (resumePreviousMonth['businessDays'] ?? 0)) / resumeCurrentMonth['businessDays']!) * 100).round()) : 0}%)",
              ]
            ],
          },
          {
            "title": "${AppLocalizations.of(context)!.category}",
            "phrases": [
              [
                "${AppLocalizations.of(context)!.highestIncrease}: Mercado (+10%)",
                "${AppLocalizations.of(context)!.highestDrop}: Agua (-20%)",
                "${AppLocalizations.of(context)!.mostUsed}: Luz (+20%)"
              ]
            ],
          },
        ],
      }
    ];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: buildGroupedPhrases(),
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
        } else {
          final groupedPhrases = snapshot.data ?? [];
          return PageView.builder(
            itemCount: groupedPhrases.length,
            controller: PageController(viewportFraction: 0.9),
            itemBuilder: (context, index) {
              final group = groupedPhrases[index];
              final sections = group['sections'] as List<Map<String, dynamic>>;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 16, bottom: 0),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
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
                    final phrases = section['phrases'] as List<List<String>>;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.label,
                            fontSize: 16,
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
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            label,
                                            style: const TextStyle(
                                              color: AppColors.label,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: RichText(
                                              text: TextSpan(
                                                children: _styleValue(
                                                    value,
                                                    const TextStyle(
                                                      color: AppColors.label,
                                                      fontSize: 14,
                                                    )),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                              // Adiciona divisor entre grupos de frases, exceto após o último
                              if (i < phrases.length - 1)
                                const Divider(
                                  color: Colors.grey,
                                  thickness: 0.5,
                                  height: 0,
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
          );
        }
      },
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

  List<Widget> _buildGroupedRows(
    List<List<String>> phrases,
    TextStyle tableHeaderStyle,
    TextStyle tableCellStyle,
  ) {
    List<Widget> rows = [];
    for (int groupIndex = 0; groupIndex < phrases.length; groupIndex++) {
      final group = phrases[groupIndex];

      for (int phraseIndex = 0; phraseIndex < group.length; phraseIndex++) {
        final phrase = group[phraseIndex];
        final parts = phrase.split(':');
        final label = parts[0];
        final value = parts.sublist(1).join(':').trim();

        rows.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    label,
                    style: tableHeaderStyle,
                    textAlign: TextAlign.left, // Alinha o texto à esquerda
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: RichText(
                    textAlign: TextAlign.right,
                    text: TextSpan(
                      children: _styleValue(value, tableCellStyle),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      if (groupIndex < phrases.length - 1) {
        rows.add(const Divider(
          color: Colors.grey,
          thickness: 0.5,
        ));
      }
    }
    return rows;
  }

  TextStyle _getParenthesesStyle(String value) {
    if (value.startsWith('+')) {
      return TextStyle(
          color: Colors.red, fontSize: 14, fontWeight: FontWeight.w600);
    } else if (value.startsWith('-')) {
      return TextStyle(
          color: Colors.green, fontSize: 14, fontWeight: FontWeight.w600);
    } else {
      return TextStyle(
          color: Color(0xFFB0BEC5), fontSize: 14, fontWeight: FontWeight.w400);
    }
  }

  String _getStyledValue(String value) {
    return value; // Apenas retorna o valor sem os parênteses
  }

  String getFormatResume(int day) {
    final DateFormat formatter =
        DateFormat(AppLocalizations.of(context)!.resumeDateFormat);

    return '${formatter.format(DateTime(widget.currentDate.year, widget.currentDate.month, day))}';
  }
}
