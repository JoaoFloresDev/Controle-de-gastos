import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/designSystem/exportDS.dart';
import "package:meus_gastos/models/CategoryModel.dart";
import 'package:meus_gastos/controllers/Dashboards/DashboardCard.dart';

class ProgressIndicatorModel {
  String title;
  double progress;
  CategoryModel category;
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
