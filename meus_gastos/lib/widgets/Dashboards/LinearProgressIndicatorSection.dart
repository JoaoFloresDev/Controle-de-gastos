import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:meus_gastos/models/ProgressIndicatorModel.dart';
import 'package:meus_gastos/services/DashbordService.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'DashboardCard.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'package:meus_gastos/models/CategoryModel.dart';


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
          Text(Translateservice.getTranslatedCategoryName(context, model.title),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                child: LinearPercentIndicator(
                  width: MediaQuery.of(context).size.width - 30,
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
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(
                      right: 10), // Ajuste a posição conforme necessário
                  child: Icon(
                    Icons.arrow_drop_down,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
