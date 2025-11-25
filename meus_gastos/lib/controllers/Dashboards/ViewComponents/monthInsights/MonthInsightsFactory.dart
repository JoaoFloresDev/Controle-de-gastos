import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/controllers/Dashboards/ViewComponents/monthInsights/MonthInsightsViewModel.dart';
import 'package:meus_gastos/controllers/Dashboards/ViewComponents/monthInsights/MonthInsightsScreen.dart';
import 'package:meus_gastos/controllers/Transactions/TransactionsViewModel.dart';
import 'package:provider/provider.dart';

class MonthinsIghtsFactory extends StatelessWidget {
  final DateTime currentDate;
  MonthinsIghtsFactory({required this.currentDate});
  @override
  Widget build(BuildContext context) {
    return MonthInsightsScreen(key: ValueKey(currentDate),);
  }
}
