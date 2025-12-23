import 'package:flutter/material.dart';
import 'package:meus_gastos/ViewsModelsGerais/SyncViewModel.dart';
import 'package:meus_gastos/controllers/CategoryCreater/CetegoryViewModel.dart';
import 'package:meus_gastos/controllers/Goals/Data/GoalsRepository.dart';
import 'package:meus_gastos/controllers/Goals/GoalsScreen.dart';
import 'package:meus_gastos/controllers/Goals/GoalsViewModel.dart';
import 'package:meus_gastos/controllers/Login/LoginViewModel.dart';
import 'package:meus_gastos/controllers/Transactions/TransactionsViewModel.dart';
import 'package:provider/provider.dart';

class GoalsFactory extends StatelessWidget {
  final String title;
  // final GlobalKey key;

  GoalsFactory({required this.title});

  @override
  Widget build(BuildContext context) {
    final categoryVM = context.read<CategoryViewModel>();
    final transactionsVM = context.read<TransactionsViewModel>();
    final loginVM = context.read<LoginViewModel>();
    final GoalsRepository goalRepo = GoalsRepository(loginVM: loginVM);
    return ChangeNotifierProvider<GoalsViewModel>(
      create: (_) => GoalsViewModel(
        categoryViewModel: categoryVM,
        transactionsViewModel: transactionsVM,
        goalsRepo: goalRepo,
        syncVM: context.read<SyncViewModel>()
      )..init(),
      child: Goalsscrean(
        title: title,
      ),
    );
  }
}
