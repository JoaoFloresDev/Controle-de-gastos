import 'package:flutter/material.dart';
import 'package:meus_gastos/ViewsModelsGerais/addCardViewModel.dart';
import 'package:meus_gastos/controllers/CategoryCreater/CetegoryViewModel.dart';
import 'package:meus_gastos/controllers/CategoryCreater/data/CategoryRepositoryLocal.dart';
import 'package:meus_gastos/controllers/CategoryCreater/data/CategoryRepositoryRemote.dart';
import 'package:meus_gastos/controllers/CategoryCreater/data/CategoryRepositorySelector.dart';
import 'package:meus_gastos/controllers/Login/LoginViewModel.dart';
import 'package:meus_gastos/controllers/Transactions/TransactionsViewModel.dart';
import 'package:meus_gastos/controllers/Transactions/data/TransactionsRepositoryLocal.dart';
import 'package:meus_gastos/controllers/Transactions/data/TransactionsRepositoryRemote.dart';
import 'package:meus_gastos/controllers/Transactions/data/TransactionsRepositorySelector.dart';
import 'package:meus_gastos/controllers/gastos_fixos/FixedExpensesViewModel.dart';
import 'package:meus_gastos/controllers/gastos_fixos/data/FixedExpensesRepository.dart';
import 'package:meus_gastos/controllers/gastos_fixos/fixedExpensesModel.dart';
import 'package:provider/provider.dart';

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // recria TransactionsViewModel sempre que userId mudar
        ChangeNotifierProvider<TransactionsViewModel>(
          key: ValueKey(context.watch<LoginViewModel>().user?.uid ?? ""),
          create: (context) {
            final loginVM = context.read<LoginViewModel>();
            final isLoggedIn = loginVM.isLogin;
            final userId = loginVM.user?.uid ?? "";

            final localRepo = TransactionsRepositoryLocal();
            final remoteRepo = TransactionsRepositoryRemote(userId: userId);
            final repoSelector = TransactionsRepositorySelector(
              remoteRepository: remoteRepo,
              localRepository: localRepo,
              isLoggedIn: isLoggedIn,
            );

            return TransactionsViewModel(
              repository: repoSelector,
              cardEvents: CardEvents(),
              loginVM: loginVM,
            )..init();
          },
        ),
        ChangeNotifierProvider<CategoryViewModel>(
          key: ValueKey(context.read<LoginViewModel>().user?.uid ?? ""),
          create: (context) {
            final loginVM = context.read<LoginViewModel>();
            final isLoggedIn = loginVM.isLogin;
            final userId = loginVM.user?.uid ?? "";

            final localRepo = CategoryRepositoryLocal();
            final remoteRepo = CategoryRepositoryRemote(userId: userId);
            final repoSelector = CategoryRepositorySelector(
              remoteRepository: remoteRepo,
              localRepository: localRepo,
              isLoggedIn: isLoggedIn,
            );

            return CategoryViewModel(
              repo: repoSelector,
            )..load();
          },
        ),
        ChangeNotifierProvider<FixedExpensesViewModel>(
          key: ValueKey(context.read<LoginViewModel>().user?.uid ?? ""),
          create: (context) {
            final loginVM = context.read<LoginViewModel>();
            final _repo = FixedExpensesRepository(loginVM);
            return FixedExpensesViewModel(_repo);
          },
        ),
      ],
      child: child,
    );
  }
}
