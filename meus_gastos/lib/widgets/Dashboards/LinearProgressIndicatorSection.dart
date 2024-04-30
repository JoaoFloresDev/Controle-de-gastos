import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';

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
            percent: progress / 1000,
            center: Text(
              "${progress.toStringAsFixed(0)}",
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
