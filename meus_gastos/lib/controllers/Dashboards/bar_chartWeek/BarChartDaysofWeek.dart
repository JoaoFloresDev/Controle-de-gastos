import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/models/ProgressIndicatorModel.dart';
import 'package:meus_gastos/services/DashbordService.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:meus_gastos/controllers/Dashboards/bar_chartWeek/selectCategorys.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';

class DailyStackedBarChart extends StatefulWidget {
  final List<List<List<ProgressIndicatorModel>>> last5weewdailyData;
  final List<WeekInterval> last5WeeksIntervals;

  DailyStackedBarChart({
    required this.last5weewdailyData,
    required this.last5WeeksIntervals,
  });

  @override
  _DailyStackedBarChartState createState() => _DailyStackedBarChartState();
}

class _DailyStackedBarChartState extends State<DailyStackedBarChart> {
  List<CategoryModel> selectedCategories = [];
  int selectedWeek = 4; // Última semana selecionada
  Key selectCategoryKey = UniqueKey(); // Chave única para SelectCategories

  @override
  void initState() {
    super.initState();
    selectedCategories = Dashbordservice.extractCategories(
        widget.last5weewdailyData[selectedWeek]);
  }

  @override
  Widget build(BuildContext context) {
    bool hasExpenses = widget.last5weewdailyData.any((week) {
      return week.any((day) => day.isNotEmpty);
    });

    if (!hasExpenses) {
      return _buildEmptyState(context);
    }

    double maxY = widget.last5weewdailyData[selectedWeek]
            .expand((day) => day.map((data) => data.progress))
            .isEmpty
        ? 0
        : 110;
    double maxDailySum = widget.last5weewdailyData[selectedWeek]
    .map((day) => day.map((data) => data.progress).reduce((a, b) => a + b)) // Soma os progressos de cada dia
    .reduce((a, b) => a > b ? a : b);
    return Card(
      color: AppColors.card,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildWeekButtons(),
          ),
          Expanded(child: _buildChart(maxY, maxDailySum)),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: SelectCategories(
              categoryList: Dashbordservice.extractCategories(
                  widget.last5weewdailyData[selectedWeek]),
              onSelectionChanged: (selectedIndices) {
                setState(() {
                  selectedCategories = selectedIndices
                      .map((index) => Dashbordservice.extractCategories(
                          widget.last5weewdailyData[selectedWeek])[index])
                      .toList();
                });
              },
              key: selectCategoryKey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Card(
          color: AppColors.card,
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: SizedBox(
            height: 300, // Altura suficiente para gráfico e legendas
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(
                      majorGridLines: MajorGridLines(width: 0),
                    ),
                    primaryYAxis: NumericAxis(
                      isVisible: false,
                      maximum: 100,
                      majorGridLines: MajorGridLines(
                        width: 0.5,
                        color: Colors.grey[600]!,
                      ),
                    ),
                    series: <ChartSeries>[
                      StackedColumnSeries<Map<String, dynamic>, String>(
                        dataSource: _buildPlaceholderData(),
                        xValueMapper: (data, _) => data['week'],
                        yValueMapper: (data, _) => data['progress'],
                        pointColorMapper: (_, __) => Colors.grey[500],
                        width: 0.5,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    alignment: WrapAlignment.center,
                    children: _buildExampleLegend(),
                  ),
                ),
              ],
            ),
          ),
        ),
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              width: double.infinity,
              height: 300,
              color: Colors.black.withOpacity(0),
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.addNewTransactions,
              style: TextStyle(
                color: AppColors.label,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.dailyGraphPlaceholder,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.label,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _buildPlaceholderData() {
    return [
      {'week': 'Week 1', 'progress': 40.0},
      {'week': 'Week 2', 'progress': 60.0},
      {'week': 'Week 3', 'progress': 30.0},
      {'week': 'Week 4', 'progress': 50.0},
    ];
  }

  List<Widget> _buildExampleLegend() {
    return [
      _buildLegendItem(Colors.grey[400]!, '40%', 'Exemplo 1'),
      _buildLegendItem(Colors.grey[500]!, '30%', 'Exemplo 2'),
      _buildLegendItem(Colors.grey[600]!, '20%', 'Exemplo 3'),
      _buildLegendItem(Colors.grey[700]!, '10%', 'Exemplo 4'),
    ];
  }

  Widget _buildLegendItem(Color color, String percent, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, color: color, size: 16),
        const SizedBox(width: 8),
        Text('$label - $percent',
            style: const TextStyle(
                color: AppColors.label,
                fontWeight: FontWeight.bold,
                fontSize: 12)),
      ],
    );
  }

  Widget _buildChart(double maxY, double maxDailySum) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(majorGridLines: MajorGridLines(width: 0)),
      primaryYAxis: NumericAxis(
        isVisible: false,
        maximum: maxY,
        majorGridLines: MajorGridLines(
            width: 0.5, color: const Color.fromARGB(255, 78, 78, 78)),
      ),
      legend: Legend(isVisible: false),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: _buildVerticalStackedBarSeries(maxDailySum),
      borderWidth: 0,
      plotAreaBorderWidth: 0,
      plotAreaBorderColor: Colors.transparent,
    );
  }

  Widget _buildWeekButtons() {
    return Container(
      width: double.infinity,
      height: 50.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          widget.last5WeeksIntervals.length,
          (int index) {
            WeekInterval interval = widget.last5WeeksIntervals[index];
            bool isSelected = selectedWeek == index;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selectedWeek != index) {
                        selectedWeek = index;
                        selectedCategories = [];
                        selectCategoryKey = UniqueKey();
                      }
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.buttonSelected
                          : AppColors.buttonDeselected,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getWeekLabel(interval),
                      style: TextStyle(color: AppColors.button),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<StackedColumnSeries<ProgressIndicatorModel, String>>
      _buildVerticalStackedBarSeries(double maxDailySum) {
    final List<String> categories = _getFilteredData()
        .expand((day) => day.map((data) => data.category.name))
        .toSet()
        .toList();

    final days = [
      AppLocalizations.of(context)!.monday,
      AppLocalizations.of(context)!.tuesday,
      AppLocalizations.of(context)!.wednesday,
      AppLocalizations.of(context)!.thursday,
      AppLocalizations.of(context)!.friday,
      AppLocalizations.of(context)!.saturday,
      AppLocalizations.of(context)!.sunday,
    ];

    List<double> totalByDay = List.generate(
      days.length,
      (dayIndex) {
        return _getFilteredData()[dayIndex]
            .fold(0.0, (sum, data) => sum + data.progress);
      },
    );

    List<StackedColumnSeries<ProgressIndicatorModel, String>> seriesList = [];

    seriesList.addAll(categories.map((category) {
      return StackedColumnSeries<ProgressIndicatorModel, String>(
        dataSource: _getFilteredData()
            .expand((day) => day)
            .where((data) => data.category.name == category)
            .toList(),
        xValueMapper: (data, index) => days[index % 7],
        yValueMapper: (data, index) =>
            totalByDay[index] > 1 ? (data.progress / maxDailySum) * 95 : data.progress,
        pointColorMapper: (data, _) => data.color,
        width: 0.5,
        borderRadius: BorderRadius.circular(4),
        name: Translateservice.getTranslatedCategoryName(context, category),
        borderWidth: 2,
        borderColor: AppColors.card,
      );
    }).toList());
    print(maxDailySum);
    seriesList.add(StackedColumnSeries<ProgressIndicatorModel, String>(
      dataSource: List.generate(days.length, (index) {
        return ProgressIndicatorModel(
          category: CategoryModel(
              name: 'Total',
              id: Uuid().v4(),
              color: AppColors.background1,
              icon: Icons.device_unknown),
          progress: totalByDay[index],
          color: Colors.transparent,
          title: 'Total',
        );
      }),
      xValueMapper: (data, index) => days[index],
      yValueMapper: (data, index) => 30,
      dataLabelMapper: (data, index) => data.progress > 0
          ? Translateservice.formatCurrency(data.progress, context)
          : '',
      pointColorMapper: (data, _) => Colors.transparent,
      width: 0.5,
      borderRadius: BorderRadius.circular(4),
      name: 'Total',
      borderWidth: 0,
      dataLabelSettings: DataLabelSettings(
        isVisible: true,
        labelAlignment: ChartDataLabelAlignment.top,
        textStyle:
            TextStyle(color: AppColors.label, fontWeight: FontWeight.bold),
        builder: (data, point, series, pointIndex, seriesIndex) {
          return Text(
            data.progress > 0
                ? Translateservice.formatCurrency(data.progress, context)
                : '',
            style: TextStyle(
                fontSize: 8,
                color: AppColors.label,
                fontWeight: FontWeight.bold),
          );
        },
      ),
    ));

    return seriesList;
  }

  List<List<ProgressIndicatorModel>> _getFilteredData() {
    if (selectedCategories.isEmpty) {
      return widget.last5weewdailyData[selectedWeek];
    }

    return widget.last5weewdailyData[selectedWeek].map((day) {
      return day.where((data) {
        return selectedCategories.contains(data.category);
      }).toList();
    }).toList();
  }

  String _getWeekLabel(WeekInterval week) {
    final formatter =
        DateFormat(AppLocalizations.of(context)!.resumeDateFormat);
    return '${formatter.format(week.start)} \n${formatter.format(week.end)}';
  }
}
