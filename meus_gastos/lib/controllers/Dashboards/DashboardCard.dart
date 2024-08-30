import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meus_gastos/services/TranslateService.dart';

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
      color: Colors.grey[900],
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            if (items.isEmpty)
              SizedBox(
                width: double.infinity,
                height: 200,
                child: Center(
                  child: Text.rich(
                    TextSpan(
                      text: AppLocalizations.of(context)!.addNewTransactions,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20,
                      ),
                      children: [
                        TextSpan(
                          text:
                              '\n\n${AppLocalizations.of(context)!.youWillBeAbleToUnderstandYourExpensesHere}',
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.expensesOfTheMonth,
                    style: const TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 210,
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
                                  titleStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                  titlePositionPercentageOffset: 1.8,
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: items
                    .map((item) => _buildLegendItem(
                        item.color,
                        '${(item.value / items.fold(0, (sum, item) => sum + item.value) * 100).toStringAsFixed(2)}%',
                        Translateservice.getTranslatedCategoryName(
                            context, item.label)))
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
        Icon(Icons.circle, color: color, size: 16),
        const SizedBox(width: 8),
        Text('$label - $percent',
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12)),
      ],
    );
  }
}
