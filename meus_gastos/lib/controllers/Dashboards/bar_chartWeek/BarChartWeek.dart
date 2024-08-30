import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/models/ProgressIndicatorModel.dart';
import 'package:meus_gastos/services/DashbordService.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:meus_gastos/Controllers/Dashboards/bar_chartWeek/selectCategorys.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WeeklyStackedBarChart extends StatefulWidget {
  final List<WeekInterval> weekIntervals;
  final List<List<ProgressIndicatorModel>> weeklyData;

  WeeklyStackedBarChart({
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
    bool hasExpens = widget.weeklyData
        .expand((week) => week.map((w) => w.progress))
        .isNotEmpty;
    if (!hasExpens || widget.weekIntervals.isEmpty) {
      return Card(
        color: Colors.grey[900],
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Container(
          height: 200,
          child: Center(
              child: Text(AppLocalizations.of(context)!.addNewTransactions,
                  style: TextStyle(color: Colors.white))),
        ),
      );
    }

    // Calcula o valor máximo do eixo Y, garantindo que não haja erro
    double maxY = widget.weeklyData
            .expand((week) => week.map((data) => data.progress))
            .isEmpty
        ? 0
        : 120;

    return Card(
      color: Colors.grey[900],
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Text(
              AppLocalizations.of(context)!.weeklyExpenses,
              style: TextStyle(color: Colors.grey, fontSize: 18),
            ),
            SizedBox(
              height: 250,
              child: SfCartesianChart(
                primaryXAxis:
                    CategoryAxis(majorGridLines: MajorGridLines(width: 0)),
                primaryYAxis: NumericAxis(
                  isVisible: false,
                  maximum: maxY,
                  majorGridLines: MajorGridLines(
                      width: 0.5, color: const Color.fromARGB(255, 78, 78, 78)),
                ),
                // title: ChartTitle(
                //     text: AppLocalizations.of(context)!.weeklyExpenses),
                legend: Legend(isVisible: false),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: _buildVerticalStackedBarSeries(),
                borderWidth: 0,
                plotAreaBorderWidth: 0,
                plotAreaBorderColor: Colors.transparent,
              ),
            ),
            Selectcategorys(
              categorieList:
                  Dashbordservice.extractCategories(widget.weeklyData),
              onSelectionChanged: (selectedIndices) {
                setState(() {
                  selectedCategories = selectedIndices
                      .map((index) => Dashbordservice.extractCategories(
                          widget.weeklyData)[index])
                      .toList();
                });
              },
            ),
          ],
        ),
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

  List<
      StackedColumnSeries<MapEntry<WeekInterval, List<ProgressIndicatorModel>>,
          String>> _buildVerticalStackedBarSeries() {
    // Lista de categorias únicas para garantir que cada categoria tenha a mesma cor em cada semana
    final List<String> categories = _getFilteredData()
        .expand((week) => week.map((data) => data.category.name))
        .toSet()
        .toList();

    List<double> weeklyTotals = widget.weekIntervals.map((weekInterval) {
      int index = widget.weekIntervals.indexOf(weekInterval);
      return _getFilteredData()[index]
          .fold(0.0, (sum, item) => sum + item.progress);
    }).toList();
    return categories.map((category) {
      return StackedColumnSeries<
              MapEntry<WeekInterval, List<ProgressIndicatorModel>>, String>(
          dataSource: widget.weekIntervals.asMap().entries.map((entry) {
            return MapEntry(entry.value, widget.weeklyData[entry.key]);
          }).toList(),
          xValueMapper: (entry, _) => _getWeekLabel(entry.key),
          yValueMapper: (entry, _) {
            final totalWeekProgress = entry.value.fold(
                0.0, (sum, item) => sum + item.progress); // Total da semana

            if (totalWeekProgress == 0) return null;

            final categoryData = entry.value.firstWhere(
                (data) => data.category.name == category,
                orElse: () => ProgressIndicatorModel(
                    title: category,
                    progress: 0,
                    category: CategoryModel(
                        id: '',
                        name: category,
                        color: Colors.grey,
                        icon: Icons.device_unknown),
                    color: Colors.grey));
            final proportion = categoryData.progress / totalWeekProgress;

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
                        color: Colors.grey,
                        icon: Icons.device_unknown),
                    color: Colors.grey));
            return categoryData.color;
          },
          width: 0.5,
          name: Translateservice.getTranslatedCategoryName(context, category),
          borderWidth: 3,
          borderColor: Colors.grey[900]);
    }).toList()
      ..add(StackedColumnSeries<
              MapEntry<WeekInterval, List<ProgressIndicatorModel>>, String>(
          dataSource: widget.weekIntervals.asMap().entries.map((entry) {
            return MapEntry(entry.value, widget.weeklyData[entry.key]);
          }).toList(),
          xValueMapper: (entry, _) => _getWeekLabel(entry.key),
          yValueMapper: (entry, index) => 20,
          dataLabelMapper: (entry, index) => weeklyTotals[index] > 0
              ? Translateservice.formatCurrency(weeklyTotals[index], context)
              : '',
          pointColorMapper: (entry, _) => Colors.transparent,
          width: 0.5,
          name: AppLocalizations.of(context)!.total,
          dataLabelSettings: DataLabelSettings(
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
