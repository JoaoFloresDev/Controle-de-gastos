import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/models/ProgressIndicatorModel.dart';
import 'package:meus_gastos/services/DashbordService.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:meus_gastos/widgets/Dashboards/bar_chartWeek/selectCategorys.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

class DailyStackedBarChart extends StatefulWidget {
  final List<List<List<ProgressIndicatorModel>>> last5weewdailyData;
  final List<WeekInterval> last5WeeksIntervals;

  DailyStackedBarChart(
      {required this.last5weewdailyData, required this.last5WeeksIntervals});

  @override
  _DailyStackedBarChartState createState() => _DailyStackedBarChartState();
}

class _DailyStackedBarChartState extends State<DailyStackedBarChart> {
  List<CategoryModel> selectedCategories = [];
  int selectedWeek = 4; // the last week is select
  Key selectCategoryKey =
      UniqueKey(); // make a unique key to call the class selectCategory
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
      return Card(
        color: Colors.grey[900],
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildWeekButtons(),
            ),
            Container(
              child: Center(
                  child: Text(AppLocalizations.of(context)!.noExpensesThisWeek,
                      style: TextStyle(color: Colors.white, fontSize: 20))),
            ),
            SizedBox()
          ],
        ),
      );
    }

    double maxY = widget.last5weewdailyData[selectedWeek]
            .expand((day) => day.map((data) => data.progress))
            .isEmpty
        ? 0
        : 110;

    return Card(
      color: Colors.grey[900],
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildWeekButtons(),
            SizedBox(
              height: 10,
            ),
            Text(
              AppLocalizations.of(context)!.dailyExpensesByCategory,
              style: TextStyle(color: Colors.grey, fontSize: 18),
            ),
            SizedBox(
              height: 250,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  SizedBox(
                    width: 600,
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(
                          majorGridLines: MajorGridLines(width: 0)),
                      primaryYAxis: NumericAxis(
                        isVisible: false,
                        maximum: maxY,
                        majorGridLines: MajorGridLines(
                            width: 0.5,
                            color: const Color.fromARGB(255, 78, 78, 78)),
                      ),
                      // title: ChartTitle(
                      //     text: AppLocalizations.of(context)!.dailyExpensesByCategory),
                      legend: Legend(isVisible: false),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: _buildVerticalStackedBarSeries(context),
                      borderWidth: 0,
                      plotAreaBorderWidth: 0,
                      plotAreaBorderColor: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
            Selectcategorys(
              categorieList: Dashbordservice.extractCategories(
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
          ],
        ),
      ),
    );
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

  Widget _buildWeekButtons() {
    return Container(
        width: double
            .infinity, // Use double.infinity para ocupar toda a largura disponível
        height: 40.0, // Defina uma altura fixa para o Container
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
                              ? CupertinoColors.white.withOpacity(0.2)
                              : Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getWeekLabel(interval),
                          style: TextStyle(color: CupertinoColors.systemBlue),
                        )),
                  ),
                ),
              );
            },
          ),
        ));
  }

  List<StackedColumnSeries<ProgressIndicatorModel, String>>
      _buildVerticalStackedBarSeries(BuildContext context) {
    // Lista de categorias únicas para garantir que cada categoria tenha a mesma cor em cada dia
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
      AppLocalizations.of(context)!.sunday
    ];

    List<double> totalByDay = List.generate(
      days.length,
      (dayIndex) {
        return _getFilteredData()[dayIndex]
            .fold(0.0, (sum, data) => sum + data.progress);
      },
    );
    List<StackedColumnSeries<ProgressIndicatorModel, String>> seriesList = [];

    // Adiciona a série de barras empilhadas para cada categoria
    seriesList.addAll(categories.map((category) {
      return StackedColumnSeries<ProgressIndicatorModel, String>(
        dataSource: _getFilteredData()
            .expand((day) => day)
            .where((data) => data.category.name == category)
            .toList(),
        xValueMapper: (data, index) => days[index % 7],
        yValueMapper: (data, index) => totalByDay[index] > 0
            ? data.progress / totalByDay[index] * 100
            : data.progress,
        pointColorMapper: (data, _) => data.color,
        width: 0.5,
        name: Translateservice.getTranslatedCategoryName(context, category),
        borderWidth: 3,
        borderColor: Colors.grey[900],
      );
    }).toList());

    // Adiciona a série de totais diários
    seriesList.add(StackedColumnSeries<ProgressIndicatorModel, String>(
      dataSource: List.generate(days.length, (index) {
        return ProgressIndicatorModel(
          category: CategoryModel(
              name: 'Total',
              id: Uuid().v4(),
              color: Colors.black,
              icon:
                  Icons.device_unknown), // Crie um modelo de categoria fictício
          progress: totalByDay[index],
          color: Colors.transparent,
          title: 'Total', // Torna a barra transparente
        );
      }),
      xValueMapper: (data, index) => days[index],
      yValueMapper: (data, index) => 30,
      dataLabelMapper: (data, index) => data.progress > 0
          ? Translateservice.formatCurrency(data.progress, context)
          : '',
      pointColorMapper: (data, _) =>
          Colors.transparent, // Torna a barra transparente
      width: 0.5,
      name: 'Total',
      borderWidth: 0,
      dataLabelSettings: DataLabelSettings(
        isVisible: true,
        labelAlignment: ChartDataLabelAlignment.top,
        textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        builder: (data, point, series, pointIndex, seriesIndex) {
          // Exibe o total acima da barra
          return Text(
            data.progress > 0
                ? Translateservice.formatCurrency(data.progress, context)
                : '',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          );
        },
      ),
    ));

    return seriesList;
  }

  String _getWeekLabel(WeekInterval week) {
    final DateFormat formatter =
        DateFormat(AppLocalizations.of(context)!.resumeDateFormat);
    return '${formatter.format(week.start)} \n${formatter.format(week.end)}';
  }
}
