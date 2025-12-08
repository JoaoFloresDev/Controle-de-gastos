import 'package:flutter/material.dart';
import 'package:meus_gastos/controllers/CategoryCreater/CetegoryViewModel.dart';
import 'package:meus_gastos/controllers/Goals/GoalsScreen.dart';
import 'package:meus_gastos/controllers/Goals/GoalsViewModel.dart';
import 'package:meus_gastos/controllers/Transactions/TransactionsViewModel.dart';
import 'package:provider/provider.dart';

class GoalsFactory extends StatelessWidget {
  final String title;
  final GlobalKey key;

  GoalsFactory({required this.title, required this.key});

  @override
  Widget build(BuildContext context) {
    final categoryVM = context.read<CategoryViewModel>();
    final transactionsVM = context.read<TransactionsViewModel>();
    return ChangeNotifierProvider<GoalsViewModel>(
      create: (_) => GoalsViewModel(categoryViewModel: categoryVM, transactionsViewModel: transactionsVM),
      builder: (context, child) => Goalsscrean(
        key: key,
        title: title,
      ),
    );
  }
}
