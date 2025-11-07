import 'package:meus_gastos/ViewsModelsGerais/addCardViewModel.dart';
import 'package:meus_gastos/controllers/Dashboards/DashboardScreenRefatore.dart';
import 'package:meus_gastos/controllers/Dashboards/DashboardViewModel.dart';
import 'package:meus_gastos/controllers/Transactions/TransactionsViewModel.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:provider/provider.dart';

class DashboardsFactory extends StatelessWidget {
  final bool isActivate;

  const DashboardsFactory({required this.isActivate, super.key});

  @override
  Widget build(BuildContext context) {
    final transactionsVM = context.watch<TransactionsViewModel>();

    return ChangeNotifierProvider(
      create: (_) => DashboardViewModel(
        transactionsVM: transactionsVM,
        cardEvents: CardEvents(),
      )..loadProgressIndicators(),
      child: DashboardScreen(isActive: isActivate),
    );
  }
}
