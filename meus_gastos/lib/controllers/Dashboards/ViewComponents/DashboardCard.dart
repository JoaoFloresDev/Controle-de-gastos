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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 2),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: items.isEmpty
            ? _buildPieChartPlaceholder(context)
            : Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 220,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 60,
                        sections: items
                            .map((item) => PieChartSectionData(
                                  color: item.color,
                                  value: item.value,
                                  title:
                                      '${(item.value / items.fold(0, (sum, item) => sum + item.value) * 100).toStringAsFixed(0)}%',
                                  radius: 35,
                                  titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  titlePositionPercentageOffset: 0.6,
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: items
                        .map((item) => _buildLegendItem(
                            item.color,
                            '${(item.value / items.fold(0, (sum, item) => sum + item.value) * 100).toStringAsFixed(0)}%',
                            TranslateService.getTranslatedCategoryName(
                                context, item.label)))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
      ),
    );
  }

  Widget _buildPieChartPlaceholder(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.button.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.pie_chart_outline,
            size: 40,
            color: AppColors.button,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          AppLocalizations.of(context)!.pieGraphPlaceholder,
          style: const TextStyle(
            color: AppColors.label,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            AppLocalizations.of(context)!.pietutorial,
            style: TextStyle(
              color: AppColors.label.withOpacity(0.7),
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String percent, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background1,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.label,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            percent,
            style: TextStyle(
              color: AppColors.label.withOpacity(0.7),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
