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
    bool hasExpenses = widget.last5weewdailyData[selectedWeek]
        .expand((day) => day.map((data) => data.progress))
        .isNotEmpty;

    if (!hasExpenses) {
      return _buildEmptyCard(context);
    }

    double maxY = widget.last5weewdailyData[selectedWeek]
            .expand((day) => day.map((data) => data.progress))
            .isEmpty
        ? 0
        : 110;

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
          Expanded(child: _buildChart(maxY)),
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

  Widget _buildEmptyCard(BuildContext context) {
    return Card(
      color: AppColors.card,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildWeekButtons(),
          ),
          SizedBox(height: 40),
          Center(
            child: Text(
              AppLocalizations.of(context)!.noExpensesThisWeek,
              style: TextStyle(color: AppColors.label, fontSize: 20),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildChart(double maxY) {
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
      series: _buildVerticalStackedBarSeries(),
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
      _buildVerticalStackedBarSeries() {
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
        yValueMapper: (data, index) => totalByDay[index] > 1
            ? (data.progress / totalByDay[index]) * 95
            : data.progress,
        pointColorMapper: (data, _) => data.color,
        width: 0.5,
        borderRadius: BorderRadius.circular(4),
        name: Translateservice.getTranslatedCategoryName(context, category),
        borderWidth: 2,
        borderColor: AppColors.card,
      );
    }).toList());

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
