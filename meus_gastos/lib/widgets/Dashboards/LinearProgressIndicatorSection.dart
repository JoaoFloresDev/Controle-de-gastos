import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:meus_gastos/enums/Category.dart';

class ProgressIndicatorModel {
  String title;
  double progress;
  Category category;

  ProgressIndicatorModel(
      {required this.title, required this.progress, required this.category});
}

class LinearProgressIndicatorSection extends StatelessWidget {
  final ProgressIndicatorModel model;

  const LinearProgressIndicatorSection({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(model.title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          LinearPercentIndicator(
            width: MediaQuery.of(context).size.width - 50,
            animation: true,
            lineHeight: 30.0, // Aumento para dar mais destaque
            animationDuration: 2000,
            percent: model.progress / 1000,
            center: Text(
              "${model.progress.toStringAsFixed(0)}",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            linearStrokeCap: LinearStrokeCap.roundAll,
            barRadius: const Radius.circular(12), // Cantos arredondados
            backgroundColor:
                Colors.blueAccent.withOpacity(0.2), // Cor de fundo mais clara
            progressColor: Colors.blueAccent, // Cor sólida para o progresso
          ),
        ],
      ),
    );
  }
}
