import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/models/ProgressIndicatorModel.dart';
import 'package:meus_gastos/controllers/Dashboards/DashbordService.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:meus_gastos/controllers/Dashboards/ViewComponents/bar_chartWeek/selectCategorys.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
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
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.card, AppColors.card2],
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
        child: Column(
          children: [
            Expanded(child: _buildChart(maxY)),
            _buildCategorySelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart, size: 60, color: AppColors.label),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.weaklyGraphPlaceholder,
              style: const TextStyle(
                color: AppColors.label,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.noExpensesThisWeek,
              style: const TextStyle(color: AppColors.label, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
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
      padding: const EdgeInsets.only(bottom: 8.0, left: 16, right: 16),
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

  List<String> getListIdsOfSelectedCategories() {
    List<String> ids = [];
    for (var cat in selectedCategories) {
      ids.add(cat.id);
    }
    return ids;
  }

  List<List<ProgressIndicatorModel>> _getFilteredData() {
    if (selectedCategories.isEmpty) {
      return List.generate(widget.weeklyData.length, (_) => []);
    }
    for (var cat in selectedCategories) {}
    return widget.weeklyData.map((week) {
      return week.where((data) {
        return getListIdsOfSelectedCategories().contains(data.category.id);
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

    List<double> weeklyTotalsControl =
        widget.weekIntervals.asMap().entries.map((entry) {
      int index = entry.key; // Índice atual
      var filteredData = _getFilteredData()[index];
      return _getFilteredData()[index]
          .fold(0.0, (sum, item) => sum + item.progress);
    }).toList();

 

    List<double> weeklyTotals = widget.weekIntervals.map((weekInterval) {
      int index = widget.weekIntervals.indexOf(weekInterval);
      return _getAllData()[index].fold(0.0, (sum, item) => sum + item.progress);
    }).toList();
    double maxWeeklyTotal = weeklyTotals.reduce((a, b) => a > b ? a : b);

    List<
        StackedColumnSeries<
            MapEntry<WeekInterval, List<ProgressIndicatorModel>>,
            String>> seriesList = [];

    seriesList.addAll(categories.map((category) {
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
        name: TranslateService.getTranslatedCategoryName(context, category),
        borderWidth: 0,
        borderColor: AppColors.card,
      );
    }).toList());
    seriesList.add(StackedColumnSeries<
            MapEntry<WeekInterval, List<ProgressIndicatorModel>>, String>(
        dataSource: widget.weekIntervals.asMap().entries.map((entry) {
          return MapEntry(entry.value, widget.weeklyData[entry.key]);
        }).toList(),
        xValueMapper: (entry, _) => _getWeekLabel(entry.key),
        yValueMapper: (entry, index) => 20,
        dataLabelMapper: (entry, index) => weeklyTotalsControl[index] > 0
            ? TranslateService.formatCurrency(
                weeklyTotalsControl[index], context)
            : "",
        pointColorMapper: (entry, _) => Colors.transparent,
        width: 0.5,
        name: AppLocalizations.of(context)!.total,
        animationDuration: 800,
        dataLabelSettings: const DataLabelSettings(
          isVisible: true,
          labelAlignment: ChartDataLabelAlignment.top,
          textStyle:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        )));
    return seriesList;
  }

  String _getWeekLabel(WeekInterval week) {
    final DateFormat formatter =
        DateFormat(AppLocalizations.of(context)!.resumeDateFormat);
    return '${formatter.format(week.start)} \n${formatter.format(week.end)}';
  }
}