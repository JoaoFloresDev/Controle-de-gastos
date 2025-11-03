import 'package:meus_gastos/ViewsModelsGerais/addCardViewModel.dart';
import 'package:meus_gastos/controllers/Login/AuthenticationSingleton.dart';
import 'package:meus_gastos/controllers/Login/LoginViewModel.dart';
import 'package:meus_gastos/controllers/Transactions/TransactionsScrean.dart';
import 'package:meus_gastos/controllers/Transactions/TransactionsViewModel.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/repositories/Transactions/TransactionsRepositoryLocal.dart';
import 'package:meus_gastos/repositories/Transactions/TransactionsRepositoryRemote.dart';
import 'package:meus_gastos/repositories/Transactions/TransactionsRepositorySelector.dart';
import 'package:provider/provider.dart';

class TransactionsFactory extends StatelessWidget {
  final CardEvents cardEvents;
  final bool isActivate;
  final auth = Authentication();

  TransactionsFactory({required this.cardEvents, required this.isActivate});

  @override
  Widget build(BuildContext context) {
    // LoginViewModel loginVM = context.watch<LoginViewModel>();

    // final isLoggedIn = loginVM.isLogin;
    // final userId = loginVM.isLogin ? loginVM.user!.uid : "";

    // final localRepo = TransactionsRepositoryLocal();
    // final remoteRepo = TransactionsRepositoryRemote(userId: userId);
    // TransactionsRepositorySelector repoSelector = TransactionsRepositorySelector(
    //     remoteRepository: remoteRepo,
    //     localRepository: localRepo,
    //     isLoggedIn: isLoggedIn);
    // TransactionsViewModel viewModel =
    //     TransactionsViewModel(repository: repoSelector, cardEvents: cardEvents, loginVM: loginVM);

    // return MultiProvider(
    //   providers: [
    //     ChangeNotifierProvider(
    //       key: ValueKey(userId),
    //       create: (_) => viewModel..init(),
    //     ),
    //   ],
    //   child: 
      return TransactionsScrean(
        isActive: isActivate,
        cardEvents: cardEvents,
        title: AppLocalizations.of(context)!.myExpenses,
        onAddClicked: () {},
      // ),
    );
  }
}
