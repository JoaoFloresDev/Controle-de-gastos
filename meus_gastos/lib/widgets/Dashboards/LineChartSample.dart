import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';

class LineChartSample extends StatelessWidget {
  final List<DailySpending> spendingData;

  LineChartSample({Key? key, required this.spendingData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData:
            FlTitlesData(show: false), // Personalize conforme necessário
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spendingData.asMap().entries.map((entry) {
              int idx = entry.key;
              DailySpending spending = entry.value;
              return FlSpot(idx.toDouble(), spending.amount);
            }).toList(),
            isCurved: true,
            colors: [Colors.blue],
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false), // Exibe ou oculta os pontos
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}

class DailySpending {
  final DateTime date;
  final double amount;

  DailySpending(this.date, this.amount);
}

// Exemplo de dados
List<DailySpending> spendingData = [
  DailySpending(DateTime(2023, 4, 1), 50.0),
  DailySpending(DateTime(2023, 4, 2), 30.0),
  DailySpending(DateTime(2023, 4, 3), 70.0),
];
