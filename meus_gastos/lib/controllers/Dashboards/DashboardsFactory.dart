import 'package:meus_gastos/ViewsModelsGerais/addCardViewModel.dart';
import 'package:meus_gastos/controllers/CategoryCreater/CetegoryViewModel.dart';
import 'package:meus_gastos/controllers/Dashboards/DashboardScreenRefatore.dart';
import 'package:meus_gastos/controllers/Dashboards/DashboardViewModel.dart';
import 'package:meus_gastos/controllers/Dashboards/ViewComponents/monthInsights/MonthInsightsViewModel.dart';
import 'package:meus_gastos/controllers/Transactions/TransactionsViewModel.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/FixedExpensesViewModel.dart';
import 'package:meus_gastos/controllers/ads_review/constructReview.dart';
import 'package:meus_gastos/controllers/ads_review/intersticalConstruct.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:provider/provider.dart';

class DashboardsFactory extends StatelessWidget {
  final bool isActivate;
  final InterstitialAdManager adManager;
  const DashboardsFactory(
      {required this.isActivate, required this.adManager, super.key});

  @override
  Widget build(BuildContext context) {
    final transactionsVM = context.watch<TransactionsViewModel>();
    final fixedExpensesVM = context.watch<FixedExpensesViewModel>();
    final categoryViewModel = context.read<CategoryViewModel>();
    if (isActivate) ReviewService().checkAndRequestReview(context, adManager);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel(
              transactionsVM: transactionsVM,
              cardEvents: CardEvents(),
              categoriesVM: categoryViewModel)
            ..loadProgressIndicators(),
        ),
        ChangeNotifierProvider(
          create: (_) => MonthInsightsViewModel(
              transactionsViewModel: transactionsVM,
              categoryViewModel: categoryViewModel,
              fixedExpensesViewModel: fixedExpensesVM)
            ..loadValues(DateTime.now()),
        )
      ],
      child: DashboardScreen(isActive: isActivate),
    );
  }
}
