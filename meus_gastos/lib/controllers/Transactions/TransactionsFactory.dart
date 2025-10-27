import 'package:meus_gastos/ViewsModelsGerais/addCardViewModel.dart';
import 'package:meus_gastos/controllers/Login/Authentication.dart';
import 'package:meus_gastos/controllers/Login/LoginViewModel.dart';
import 'package:meus_gastos/controllers/Transactions/TransactionsScrean.dart';
import 'package:meus_gastos/controllers/Transactions/TransactionsViewModel.dart';
import 'package:meus_gastos/controllers/Transactions/data/TransactionsRepository.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class TransactionsFactory {
  final BuildContext context;
  final CardEvents cardEvents;
  Authentication auth = Authentication();

  TransactionsFactory(
      {required this.context, required this.cardEvents});

  Widget build(bool isActive) {
    LoginViewModel loginVM =
        context.watch<LoginViewModel>();
    TransactionsRepository repo =
        TransactionsRepository(loginViewModel: loginVM);
    TransactionsViewModel viewModel =
        TransactionsViewModel(repository: repo, cardEvents: cardEvents);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => viewModel..init(),
        ),
      ],
      child: TransactionsScrean(
        isActive: isActive,
        cardEvents: cardEvents,
        title: AppLocalizations.of(context)!.myExpenses,
        onAddClicked: () {},
      ),
    );
  }
}
