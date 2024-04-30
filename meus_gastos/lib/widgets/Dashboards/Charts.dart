import 'package:meus_gastos/enums/Category.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'LinearProgressIndicatorSection.dart';
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
              Column(
                children: [
                  for (var category in Category.values)
                    LinearProgressIndicatorSection(
                      progress: 0.2,
                      label: CategoryInfo.getByCategory(Category.Shopping).name,
                      color: Colors.blueAccent,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
