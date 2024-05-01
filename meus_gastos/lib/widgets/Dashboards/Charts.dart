import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/enums/Category.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'LinearProgressIndicatorSection.dart';
import 'DashboardCard.dart';

class DashboardScreen extends StatefulWidget {
  final bool isActive;

  DashboardScreen({this.isActive = false});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  List<ProgressIndicatorModel> progressIndicators = [];
  List<PieChartDataItem> pieChartDataItems = [];
  bool isLoading = true;

  @override
  bool get wantKeepAlive => true; // Usando o mixin para manter o estado

  @override
  void initState() {
    super.initState();
    _loadProgressIndicators();
  }

  @override
  void didUpdateWidget(DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && widget.isActive != oldWidget.isActive) {
      _loadProgressIndicators();
    }
  }

  Future<void> _loadProgressIndicators() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    progressIndicators = await CardService.getProgressIndicators();
    pieChartDataItems.clear();
    for (var progressIndicator in progressIndicators) {
      pieChartDataItems.add(progressIndicator.toPieChartDataItem());
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(
        context); // Chamada necessária para AutomaticKeepAliveClientMixin
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
                child: DashboardCard(
                  items: pieChartDataItems,
                ),
              ),
              if (isLoading)
                CircularProgressIndicator()
              else
                Column(
                  children: [
                    for (var progressIndicator in progressIndicators)
                      LinearProgressIndicatorSection(model: progressIndicator),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
