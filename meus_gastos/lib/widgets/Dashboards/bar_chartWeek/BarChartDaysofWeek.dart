import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/models/ProgressIndicatorModel.dart';
import 'package:meus_gastos/services/DashbordService.dart';
import 'package:meus_gastos/widgets/Dashboards/bar_chartWeek/selectCategorys.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
  int selectedWeek = 4;
  @override
  void initState() {
    super.initState();
    selectedCategories = Dashbordservice.extractCategories(
        widget.last5weewdailyData[selectedWeek]);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.last5weewdailyData[selectedWeek].isEmpty) {
      return Card(
        color: Colors.grey[900],
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Container(
          height: 200,
          child: Center(
              child: Text('No data available',
                  style: TextStyle(color: Colors.white))),
        ),
      );
    }

    double maxY = widget.last5weewdailyData[selectedWeek]
            .expand((day) => day.map((data) => data.progress))
            .isEmpty
        ? 0
        : widget.last5weewdailyData[selectedWeek]
                .expand((day) => day.map((data) => data.progress))
                .reduce((a, b) => a > b ? a : b) +
            50;

    return Card(
      color: Colors.grey[900],
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildWeekButtons(),
            SfCartesianChart(
              primaryXAxis:
                  CategoryAxis(majorGridLines: MajorGridLines(width: 0)),
              primaryYAxis: NumericAxis(
                maximum: maxY / 0.5 > 0 ? maxY / 0.4 : 1,
                interval: maxY / 2 > 0 ? maxY / 2 : 1,
                majorGridLines: MajorGridLines(
                    width: 0.5, color: const Color.fromARGB(255, 78, 78, 78)),
              ),
              title: ChartTitle(text: 'Gastos Diários por Categoria'),
              legend: Legend(isVisible: false),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: _buildVerticalStackedBarSeries(),
              borderWidth: 0,
              plotAreaBorderWidth: 0,
              plotAreaBorderColor: Colors.transparent,
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
            ),
          ],
        ),
      ),
    );
  }

  List<List<ProgressIndicatorModel>> _getFilteredData() {
    if (selectedCategories.isEmpty) {
      return List.generate(
          widget.last5weewdailyData[selectedWeek].length, (_) => []);
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
      child: ListView.builder(
        itemCount: widget.last5WeeksIntervals.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          WeekInterval interval = widget.last5WeeksIntervals[index];
          bool isSelected = selectedWeek == index;

          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 2.0), // Adicione um padding para separar os botões
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(

                foregroundColor: CupertinoColors.systemBlue,
                backgroundColor: isSelected ? CupertinoColors.white.withOpacity(0.2): Colors.transparent,
              ),
              onPressed: () {
                setState(() {
                  selectedWeek = index;
                  
                });
              },
              child: Text(_getWeekLabel(interval)),
            ),
          );
        },
      ),
    );
  }

  List<StackedColumnSeries<ProgressIndicatorModel, String>>
      _buildVerticalStackedBarSeries() {
    // Lista de categorias únicas para garantir que cada categoria tenha a mesma cor em cada dia
    final List<String> categories = _getFilteredData()
        .expand((day) => day.map((data) => data.category.name))
        .toSet()
        .toList();

    return categories.map((category) {
      return StackedColumnSeries<ProgressIndicatorModel, String>(
        dataSource: _getFilteredData().expand((day) => day).where((data) {
          return data.category.name == category;
        }).toList(),
        xValueMapper: (data, index) => _getDayLabel(index % 7),
        yValueMapper: (data, index) => data.progress,
        pointColorMapper: (data, _) => data.color,
        width: 0.5,
        name: category,
        borderWidth: 3,
        borderColor: Colors.grey[900],
      );
    }).toList();
  }

  String _getDayLabel(int dayIndex) {
    const days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    return days[dayIndex];
  }

  String _getWeekLabel(WeekInterval week) {
    final DateFormat formatter = DateFormat('dd/MM');
    return '${formatter.format(week.start)} \n${formatter.format(week.end)}';
  }
}
