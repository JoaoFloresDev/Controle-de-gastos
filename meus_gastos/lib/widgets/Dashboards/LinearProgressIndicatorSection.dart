import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:meus_gastos/enums/Category.dart';
import 'DashboardCard.dart';

class ProgressIndicatorModel {
  String title;
  double progress;
  Category category;
  final Color color;

  ProgressIndicatorModel(
      {required this.title,
      required this.progress,
      required this.category,
      required this.color});

  PieChartDataItem toPieChartDataItem() {
    return PieChartDataItem(
      label: title,
      value: progress,
      color: color,
    );
  }
}

class LinearProgressIndicatorSection extends StatelessWidget {
  final ProgressIndicatorModel model;
  final double totalAmount;

  const LinearProgressIndicatorSection({
    Key? key,
    required this.model,
    required this.totalAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(model.title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          LinearPercentIndicator(
            width: MediaQuery.of(context).size.width - 50,
            animation: true,
            lineHeight: 30.0,
            animationDuration: 1000,
            percent: model.progress / totalAmount,
            center: Text(
              "${model.progress.toStringAsFixed(0)}",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            linearStrokeCap: LinearStrokeCap.roundAll,
            barRadius: const Radius.circular(12),
            backgroundColor: model.color.withOpacity(0.2),
            progressColor: model.color,
          ),
        ],
      ),
    );
  }
}
