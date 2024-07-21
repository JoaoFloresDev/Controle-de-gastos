import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';

class Dashboardbarchart extends StatelessWidget {
  final List<double> monthlyExpenses;

  Dashboardbarchart({required this.monthlyExpenses});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: monthlyExpenses.reduce((a, b) => a > b ? a : b) + 100,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: SideTitles(
              showTitles: true,
              getTextStyles: (context, value) => const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              margin: 16,
              getTitles: (double value) {
                switch (value.toInt()) {
                  case 0:
                    return 'Jan';
                  case 1:
                    return 'Feb';
                  case 2:
                    return 'Mar';
                  case 3:
                    return 'Apr';
                  case 4:
                    return 'May';
                  case 5:
                    return 'Jun';
                  case 6:
                    return 'Jul';
                  case 7:
                    return 'Aug';
                  case 8:
                    return 'Sep';
                  case 9:
                    return 'Oct';
                  case 10:
                    return 'Nov';
                  case 11:
                    return 'Dec';
                  default:
                    return '';
                }
              },
            ),
            topTitles: SideTitles(
              showTitles: false,
            ),
            rightTitles: SideTitles(
                showTitles: true,
                getTextStyles: (context, value) => const TextStyle(
                      color: Colors.white,
                ),
            reservedSize: 40,
            ),
            leftTitles: SideTitles(
              showTitles: false,
              getTextStyles: (context, value) => const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              margin: 16,
              reservedSize: 14,
              interval: 200,
              getTitles: (value) {
                return value.toInt().toString();
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            checkToShowHorizontalLine: (value) => value % 200 == 0,
          ),
          borderData: FlBorderData(
            show: false,
          ),
          barGroups: monthlyExpenses.asMap().entries.map((entry) {
            int index = entry.key;
            double value = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  y: value,
                  colors: [Colors.lightBlueAccent, Colors.blueAccent],
                ),
              ],
              showingTooltipIndicators: [],
            );
          }).toList(),
        ),
      ),
    );
  }
}
