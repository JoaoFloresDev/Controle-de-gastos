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
                                              fontSize: 13,
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
                                      TranslateService
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background1.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$label - $percent',
            style: const TextStyle(
              color: AppColors.label,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
