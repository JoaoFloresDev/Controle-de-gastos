import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Barchart extends StatelessWidget {
  final Map<int, Map<String, Map<String, dynamic>>>
      totalExpansivesMonthsCategory;

  Barchart({required this.totalExpansivesMonthsCategory});

  @override
  Widget build(BuildContext context) {
    if (totalExpansivesMonthsCategory.isEmpty) {
      return Card(
        color: Colors.grey[900],
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Container(
          child: Center(child: Text('No data available')),
        ),
      );
    }

    // Calcula o valor máximo do eixo Y, garantindo que não haja erro
    double maxY = totalExpansivesMonthsCategory.values
            .expand(
                (month) => month.values.map((data) => data['amount'] as double))
            .isEmpty
        ? 0
        : totalExpansivesMonthsCategory.values
                .expand((month) =>
                    month.values.map((data) => data['amount'] as double))
                .reduce((a, b) => a > b ? a : b) +
            50;

    return Card(
      color: Colors.grey[900],
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(majorGridLines: MajorGridLines(width: 0)),
          primaryYAxis: NumericAxis(
            maximum: maxY / 0.5 > 0 ? maxY / 0.5 : 1,
            interval: maxY / 2 > 0 ? maxY / 5 : 1,
            majorGridLines: MajorGridLines(
                width: 0.5, color: const Color.fromARGB(255, 78, 78, 78)),
          ),
          title: ChartTitle(text: 'Gastos do Ano'),
          legend: Legend(isVisible: false),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: _buildVerticalStackedBarSeries(),
          borderWidth: 0,
          plotAreaBorderWidth: 0,
          plotAreaBorderColor: Colors.transparent,
        ),
      ),
    );
  }

  List<
      StackedColumnSeries<MapEntry<int, Map<String, Map<String, dynamic>>>,
          String>> _buildVerticalStackedBarSeries() {
    // Lista de categorias únicas para garantir que cada categoria tenha a mesma cor em cada mês
    final List<String> categories = totalExpansivesMonthsCategory.values
        .expand((month) => month.keys)
        .toSet()
        .toList();
    return categories.map((category) {
      final firstEntryWithCategory =
          totalExpansivesMonthsCategory.entries.firstWhere(
        (entry) => entry.value.containsKey(category),
        orElse: () => MapEntry(0, {}),
      );

      final categoryName;
      if (firstEntryWithCategory.value.isNotEmpty) {
        categoryName =
            firstEntryWithCategory.value[category]?['name'] as String;
      } else {
        categoryName = ' ';
      }

      return StackedColumnSeries<
              MapEntry<int, Map<String, Map<String, dynamic>>>, String>(
          dataSource: totalExpansivesMonthsCategory.entries.toList(),
          xValueMapper: (entry, _) => _getMonthName(entry.key),
          yValueMapper: (entry, _) {
            final categoryData = entry.value[category];
            return categoryData != null ? categoryData['amount'] as double : 0;
          },
          pointColorMapper: (entry, _) {
            final categoryData = entry.value[category];
            return categoryData != null
                ? categoryData['color'] as Color
                : Colors.transparent;
          },
          width: 0.5,
          name: categoryName);
    }).toList();
  }

  String _getMonthName(int month) {
    const List<String> monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return monthNames[month - 1];
  }
}
