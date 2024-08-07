import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "package:meus_gastos/models/CategoryModel.dart";
import 'package:meus_gastos/widgets/Dashboards/DashboardCard.dart';
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
