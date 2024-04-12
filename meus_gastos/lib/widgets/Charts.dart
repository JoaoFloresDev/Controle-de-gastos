import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Dashboard Elegante"),
        backgroundColor: Colors.deepPurple.withAlpha(200), // Semi-transparent
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              LinearProgressIndicatorSection(
                  progress: 0.8, label: "Progresso 1", color: Colors.redAccent),
              LinearProgressIndicatorSection(
                  progress: 0.5,
                  label: "Progresso 2",
                  color: Colors.greenAccent),
              LinearProgressIndicatorSection(
                  progress: 0.2,
                  label: "Progresso 3",
                  color: Colors.blueAccent),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double
                          .infinity, // Ajuste para ocupar toda a largura disponível
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 4, // Espaço entre as seções
                          centerSpaceRadius: 50,
                          sections: [
                            PieChartSectionData(
                              color: Colors.redAccent,
                              value: 40,
                              title: '40%',
                              titleStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            PieChartSectionData(
                              color: Colors.greenAccent,
                              value: 30,
                              title: '30%',
                              titleStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            PieChartSectionData(
                              color: Colors.blueAccent,
                              value: 30,
                              title: '30%',
                              titleStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LinearProgressIndicatorSection extends StatelessWidget {
  final double progress;
  final String label;
  final Color color;

  const LinearProgressIndicatorSection({
    Key? key,
    required this.progress,
    required this.label,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          LinearPercentIndicator(
            width: MediaQuery.of(context).size.width - 50,
            animation: true,
            lineHeight: 30.0, // Aumento para dar mais destaque
            animationDuration: 2000,
            percent: progress,
            center: Text(
              "${(progress * 100).toStringAsFixed(0)}%",
              style: TextStyle(color: Colors.white),
            ),
            linearStrokeCap: LinearStrokeCap.roundAll,
            barRadius: const Radius.circular(12), // Cantos arredondados
            backgroundColor: color.withOpacity(0.2), // Cor de fundo mais clara
            progressColor: color, // Cor sólida para o progresso
          ),
        ],
      ),
    );
  }
}

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
