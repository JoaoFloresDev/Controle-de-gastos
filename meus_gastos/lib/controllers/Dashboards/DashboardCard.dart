import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

  DashboardCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (items.isEmpty)
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 300, // Aumentado para incluir gráfico e legendas
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Gráfico de exemplo em tons de cinza
                        SizedBox(
                          width: double.infinity,
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 4,
                              centerSpaceRadius: 50,
                              sections: [
                                PieChartSectionData(
                                  color: Colors.grey[900],
                                  value: 40,
                                  title: '40%',
                                  radius: 30,
                                  titleStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                  titlePositionPercentageOffset: 1.8,
                                ),
                                PieChartSectionData(
                                  color: Colors.grey[800],
                                  value: 30,
                                  title: '30%',
                                  radius: 30,
                                  titleStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                  titlePositionPercentageOffset: 1.8,
                                ),
                                PieChartSectionData(
                                  color: Colors.grey[700],
                                  value: 20,
                                  title: '20%',
                                  radius: 30,
                                  titleStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                  titlePositionPercentageOffset: 1.8,
                                ),
                                PieChartSectionData(
                                  color: Colors.grey[700],
                                  value: 10,
                                  title: '10%',
                                  radius: 30,
                                  titleStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                  titlePositionPercentageOffset: 1.8,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Legendas de exemplo
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            alignment: WrapAlignment.center,
                            children: _buildExampleLegend(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Aplica o efeito de blur tanto no gráfico quanto nas legendas
                  ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        width: double.infinity,
                        height: 300, // Mesma altura do gráfico e das legendas
                        color: Colors.black.withOpacity(0),
                      ),
                    ),
                  ),
                  // Texto por cima do gráfico e legendas
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!
                            .addNewTransactions, // Texto principal
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.label,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!
                            .pieGraphPlaceholder, // Texto secundário
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.label,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              )
            else
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
                              Translateservice.getTranslatedCategoryName(
                                  context, item.label)))
                          .toList(),
                    ),
                  ),
                ],
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
