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

class DashboardCard extends StatefulWidget {
  final List<PieChartDataItem> items;

  const DashboardCard({super.key, required this.items});

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.card, AppColors.card2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            offset: const Offset(0, 8),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: widget.items.isEmpty
          ? _buildPieChartPlaceholder(context)
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback: (event, response) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      response == null ||
                                      response.touchedSection == null) {
                                    _touchedIndex = -1;
                                    return;
                                  }
                                  _touchedIndex = response
                                      .touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                            sectionsSpace: 2,
                            centerSpaceRadius: 50,
                            startDegreeOffset: -90,
                            sections: _buildSections(),
                          ),
                        ),
                        _buildCenterLabel(context),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildLegend(context),
                ],
              ),
            ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    final total = widget.items.fold(0.0, (sum, i) => sum + i.value);
    return widget.items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isTouched = index == _touchedIndex;
      final radius = isTouched ? 38.0 : 32.0;
      final pct = (item.value / total * 100);
      final showLabel = pct >= 8;

      return PieChartSectionData(
        color: item.color,
        value: item.value,
        title: showLabel
            ? TranslateService.getTranslatedCategoryName(context, item.label)
            : '',
        titleStyle: TextStyle(
          color: Colors.white,
          fontSize: isTouched ? 11 : 10,
          fontWeight: FontWeight.w600,
          shadows: [
            Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 4),
          ],
        ),
        radius: radius,
        titlePositionPercentageOffset: 1.6,
        borderSide: isTouched
            ? BorderSide(color: item.color.withValues(alpha: 0.6), width: 2)
            : const BorderSide(color: Colors.transparent, width: 0),
      );
    }).toList();
  }

  Widget _buildCenterLabel(BuildContext context) {
    if (_touchedIndex >= 0 && _touchedIndex < widget.items.length) {
      final item = widget.items[_touchedIndex];
      final total = widget.items.fold(0.0, (sum, i) => sum + i.value);
      final pct = (item.value / total * 100).toStringAsFixed(1);
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
          ),
          const SizedBox(height: 6),
          Text(
            '$pct%',
            style: const TextStyle(
              color: AppColors.label,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            TranslateService.getTranslatedCategoryName(context, item.label),
            style: TextStyle(
              color: AppColors.label.withValues(alpha: 0.6),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return const SizedBox.shrink(
    );
  }

  Widget _buildLegend(BuildContext context) {
    final total = widget.items.fold(0.0, (sum, i) => sum + i.value);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: widget.items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final pct = (item.value / total * 100).toStringAsFixed(1);
        final isSelected = index == _touchedIndex;
        return GestureDetector(
          onTap: () => setState(() {
            _touchedIndex = isSelected ? -1 : index;
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? item.color.withValues(alpha: 0.18)
                  : AppColors.background1.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? item.color.withValues(alpha: 0.7)
                    : item.color.withValues(alpha: 0.2),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: item.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  TranslateService.getTranslatedCategoryName(context, item.label),
                  style: TextStyle(
                    color: isSelected ? AppColors.label : AppColors.label.withValues(alpha: 0.8),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '$pct%',
                  style: TextStyle(
                    color: item.color,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPieChartPlaceholder(BuildContext context) {
    return SizedBox.expand(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_outline_rounded, size: 56, color: AppColors.label.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.pieGraphPlaceholder,
              style: TextStyle(
                color: AppColors.label.withValues(alpha: 0.9),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.pietutorial,
              style: TextStyle(
                color: AppColors.label.withValues(alpha: 0.5),
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
