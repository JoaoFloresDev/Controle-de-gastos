import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'LinearProgressIndicatorSection.dart';
import 'LineChartSample.dart';
import 'DashboardCard.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Dashboard Elegante"),
        backgroundColor: Colors.deepPurple.withAlpha(200),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DashboardCard(),
              ),
              LinearProgressIndicatorSection(
                  progress: 800, label: "Progresso 1", color: Colors.redAccent),
              LinearProgressIndicatorSection(
                  progress: 800,
                  label: "Progresso 2",
                  color: Colors.greenAccent),
              LinearProgressIndicatorSection(
                  progress: 800,
                  label: "Progresso 3",
                  color: Colors.blueAccent),
              LinearProgressIndicatorSection(
                  progress: 800, label: "Progresso 1", color: Colors.redAccent),
              LinearProgressIndicatorSection(
                  progress: 800,
                  label: "Progresso 2",
                  color: Colors.greenAccent),
              LinearProgressIndicatorSection(
                  progress: 0.2,
                  label: "Progresso 3",
                  color: Colors.blueAccent),
            ],
          ),
        ),
      ),
    );
  }
}
