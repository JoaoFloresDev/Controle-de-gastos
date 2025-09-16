import 'package:meus_gastos/controllers/Login/Authentication.dart';
import 'package:meus_gastos/controllers/Transactions/InsertTransactions.dart';
import 'package:meus_gastos/controllers/Transactions/TransactionsViewModel.dart';
import 'package:meus_gastos/controllers/Transactions/data/TransactionsRepository.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class TransactionsFactory {
  final BuildContext context;
  TransactionsFactory({required this.context});

  Widget build(bool isActive) {
    Authentication auth = Authentication();
    TransactionsRepository repo = TransactionsRepository(auth);
    TransactionsViewModel viewModel = TransactionsViewModel(repository: repo);

    return ChangeNotifierProvider(
        create: (_) => viewModel..init(),
        builder: (context, child) => InsertTransactions(
              isActive: isActive,
              title: AppLocalizations.of(context)!.myExpenses,
              onAddClicked: () {},
            ));
  }
}
