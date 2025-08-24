import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';

class PieChartDataItem {
  final String label;
  final double value;
  final Color color;

  PieChartDataItem(
      {required this.label, required this.value, required this.color});
}

class DashboardCard extends StatelessWidget {
  final List<PieChartDataItem> items;

  const DashboardCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
        color: AppColors.card,
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
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: items.isEmpty
                ? _buildPieChartPlaceholder(context)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                                          titleStyle: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.label),
                                          titlePositionPercentageOffset: 1.8,
                                        ))
                                    .toList(),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              alignment: WrapAlignment.center,
                              children: items
                                  .map((item) => _buildLegendItem(
                                      item.color,
                                      '${(item.value / items.fold(0, (sum, item) => sum + item.value) * 100).toStringAsFixed(2)}%',
                                      Translateservice
                                          .getTranslatedCategoryName(
                                              context, item.label)))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ));
  }

  Widget _buildPieChartPlaceholder(BuildContext context) {
    return SizedBox.expand(
      child: Container(
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart, size: 60, color: AppColors.label),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.pieGraphPlaceholder,
              style: const TextStyle(
                color: AppColors.label,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.pietutorial,
              style: const TextStyle(
                color: AppColors.label,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
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
                color: AppColors.label,
                fontWeight: FontWeight.bold,
                fontSize: 12)),
      ],
    );
  }

  List<Widget> _buildExampleLegend() {
    return [
      _buildLegendItem(
          const Color.fromARGB(255, 57, 57, 57), '40%', 'Exemplo 1'),
      _buildLegendItem(
          const Color.fromARGB(255, 55, 54, 54), '30%', 'Exemplo 2'),
      _buildLegendItem(Colors.grey[600]!, '20%', 'Exemplo 3'),
      _buildLegendItem(Colors.grey[700]!, '10%', 'Exemplo 4'),
    ];
  }
}
