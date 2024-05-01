import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartDataItem {
  final String label;
  final double value;
  final Color color;

  PieChartDataItem(
      {required this.label, required this.value, required this.color});
}

class DashboardCard extends StatelessWidget {
  final List<PieChartDataItem> items;

  DashboardCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 50,
                  sections: items
                      .map((item) => PieChartSectionData(
                            color: item.color,
                            value: item.value,
                            title:
                                '${(item.value / items.fold(0, (sum, item) => sum + item.value) * 100).toStringAsFixed(2)}%',
                            radius: 30,
                            titleStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            titlePositionPercentageOffset: 1.8,
                          ))
                      .toList(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Wrap(
                spacing: 8, // Espaço horizontal entre os itens
                runSpacing: 8, // Espaço vertical entre as linhas
                alignment: WrapAlignment
                    .start, // Align the items to the start (left) of the container
                children: items
                    .map((item) => _buildLegendItem(
                        item.color,
                        '${(item.value / items.fold(0, (sum, item) => sum + item.value) * 100).toStringAsFixed(2)}%',
                        item.label))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String percent, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, color: color, size: 14),
        SizedBox(width: 8),
        Text('$label - $percent',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
