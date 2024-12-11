import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/models/ProgressIndicatorModel.dart';
import 'package:meus_gastos/services/DashbordService.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:meus_gastos/controllers/Dashboards/ViewComponents/bar_chartWeek/selectCategorys.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';

class WeeklyStackedBarChart extends StatefulWidget {
  final List<WeekInterval> weekIntervals;
  final List<List<ProgressIndicatorModel>> weeklyData;

  const WeeklyStackedBarChart({
    super.key,
    required this.weekIntervals,
    required this.weeklyData,
  });

  @override
  _WeeklyStackedBarChartState createState() => _WeeklyStackedBarChartState();
}

class _WeeklyStackedBarChartState extends State<WeeklyStackedBarChart> {
  List<CategoryModel> selectedCategories = [];

  @override
  void initState() {
    super.initState();
    selectedCategories = Dashbordservice.extractCategories(widget.weeklyData);
  }

  @override
  Widget build(BuildContext context) {
    bool hasExpenses = widget.weeklyData
        .expand((week) => week.map((w) => w.progress))
        .isNotEmpty;

    if (!hasExpenses || widget.weekIntervals.isEmpty) {
      return _buildEmptyState(context);
    }

    double maxY = widget.weeklyData
            .expand((week) => week.map((data) => data.progress))
            .isEmpty
        ? 0
        : 120;

    return Card(
      color: AppColors.card,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          Expanded(child: _buildChart(maxY)),
          _buildCategorySelector(),
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
                    primaryXAxis: const CategoryAxis(
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
                    series: <CartesianSeries>[
                      StackedColumnSeries<Map<String, dynamic>, String>(
                        dataSource: _buildPlaceholderData(),
                        xValueMapper: (data, _) => data['week'],
                        yValueMapper: (data, _) => data['progress'],
                        pointColorMapper: (data, __) => data['color'],
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
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0), // Adicionando padding horizontal
              child: Text(
                AppLocalizations.of(context)!.dailyGraphPlaceholder,
                style: const TextStyle(
                  color: AppColors.label,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 32.0),
              child: Text(
                AppLocalizations.of(context)!.addNewTransactions,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.label,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _buildPlaceholderData() {
    return [
      {'week': 'Week 1', 'progress': 40.0, 'color': const Color.fromARGB(255, 48, 48, 48)},
      {
        'week': 'Week 2',
        'progress': 60.0,
        'color': const Color.fromARGB(255, 85, 85, 85)
      },
      {
        'week': 'Week 3',
        'progress': 30.0,
        'color': const Color.fromARGB(255, 80, 80, 80)
      },
      {
        'week': 'Week 4',
        'progress': 50.0,
        'color': const Color.fromARGB(255, 40, 40, 40)
      },
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

  Widget _buildChart(double maxY) {
    // Construção do gráfico real quando houver dados
    return SfCartesianChart(
      primaryXAxis:
          const CategoryAxis(majorGridLines: MajorGridLines(width: 0)),
      primaryYAxis: NumericAxis(
        isVisible: false,
        maximum: maxY,
        majorGridLines: const MajorGridLines(
            width: 0.5, color: Color.fromARGB(255, 78, 78, 78)),
      ),
      legend: const Legend(isVisible: false),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: _buildVerticalStackedBarSeries(),
      borderWidth: 0,
      plotAreaBorderWidth: 0,
      plotAreaBorderColor: Colors.transparent,
    );
  }

  Widget _buildCategorySelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: SelectCategories(
        categoryList: Dashbordservice.extractCategories(widget.weeklyData),
        onSelectionChanged: (selectedIndices) {
          setState(() {
            selectedCategories = selectedIndices
                .map((index) =>
                    Dashbordservice.extractCategories(widget.weeklyData)[index])
                .toList();
          });
        },
      ),
    );
  }

  List<List<ProgressIndicatorModel>> _getFilteredData() {
    if (selectedCategories.isEmpty) {
      return List.generate(widget.weeklyData.length, (_) => []);
    }

    return widget.weeklyData.map((week) {
      return week.where((data) {
        return selectedCategories.contains(data.category);
      }).toList();
    }).toList();
  }

  List<List<ProgressIndicatorModel>> _getAllData() {
    return widget.weeklyData.map((week) => week.toList()).toList();
  }

  List<
      StackedColumnSeries<MapEntry<WeekInterval, List<ProgressIndicatorModel>>,
          String>> _buildVerticalStackedBarSeries() {
    final List<String> categories = _getFilteredData()
        .expand((week) => week.map((data) => data.category.name))
        .toSet()
        .toList();

    List<double> weeklyTotalsControl = widget.weekIntervals.map((weekInterval) {
      int index = widget.weekIntervals.indexOf(weekInterval);
      return _getFilteredData()[index]
          .fold(0.0, (sum, item) => sum + item.progress);
    }).toList();

    List<double> weeklyTotals = widget.weekIntervals.map((weekInterval) {
      int index = widget.weekIntervals.indexOf(weekInterval);
      return _getAllData()[index]
          .fold(0.0, (sum, item) => sum + item.progress);
    }).toList();
    double maxWeeklyTotal = weeklyTotals.reduce((a, b) => a > b ? a : b);

    return categories.map((category) {
      return StackedColumnSeries<
          MapEntry<WeekInterval, List<ProgressIndicatorModel>>, String>(
        dataSource: widget.weekIntervals.asMap().entries.map((entry) {
          return MapEntry(entry.value, widget.weeklyData[entry.key]);
        }).toList(),
        xValueMapper: (entry, _) => _getWeekLabel(entry.key),
        yValueMapper: (entry, _) {
          final totalWeekProgress =
              entry.value.fold(0.0, (sum, item) => sum + item.progress);

          if (totalWeekProgress == 0) return null;

          final categoryData = entry.value.firstWhere(
              (data) => data.category.name == category,
              orElse: () => ProgressIndicatorModel(
                  title: category,
                  progress: 0,
                  category: CategoryModel(
                      id: '',
                      name: category,
                      color: AppColors.card,
                      icon: Icons.device_unknown),
                  color: AppColors.card));
          final proportion = categoryData.progress / maxWeeklyTotal;

          const double maxBarHeight = 100.0;
          return proportion * maxBarHeight;
        },
        pointColorMapper: (entry, _) {
          final categoryData = entry.value.firstWhere(
              (data) => data.category.name == category,
              orElse: () => ProgressIndicatorModel(
                  title: category,
                  progress: 0,
                  category: CategoryModel(
                      id: '',
                      name: category,
                      color: AppColors.card,
                      icon: Icons.device_unknown),
                  color: AppColors.card));
          return categoryData.color;
        },
        width: 0.5,
        borderRadius:
            BorderRadius.circular(4), // Adiciona cantos arredondados às barras
        name: Translateservice.getTranslatedCategoryName(context, category),
        borderWidth: 3,
        borderColor: AppColors.card,
      );
    }).toList()
      ..add(StackedColumnSeries<
              MapEntry<WeekInterval, List<ProgressIndicatorModel>>, String>(
          dataSource: widget.weekIntervals.asMap().entries.map((entry) {
            return MapEntry(entry.value, widget.weeklyData[entry.key]);
          }).toList(),
          xValueMapper: (entry, _) => _getWeekLabel(entry.key),
          yValueMapper: (entry, index) => 20,
          dataLabelMapper: (entry, index) => weeklyTotalsControl[index] > 0
              ? Translateservice.formatCurrency(weeklyTotalsControl[index], context)
              : '',
          pointColorMapper: (entry, _) => Colors.transparent,
          width: 0.5,
          name: AppLocalizations.of(context)!.total,
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.top,
            textStyle:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )));
  }

  String _getWeekLabel(WeekInterval week) {
    final DateFormat formatter =
        DateFormat(AppLocalizations.of(context)!.resumeDateFormat);
    return '${formatter.format(week.start)} \n${formatter.format(week.end)}';
  }
}
