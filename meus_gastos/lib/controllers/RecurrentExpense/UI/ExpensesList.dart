import 'package:flutter/material.dart';
import 'ListCardFixeds.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/fixedExpensesModel.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';

class ExpensesList extends StatelessWidget {
  const ExpensesList({
    super.key,
    required this.fixedExpenses,
    required this.onExpenseTap,
  });

  final List<FixedExpense> fixedExpenses;
  final Function(FixedExpense) onExpenseTap;

  @override
  Widget build(BuildContext context) {
    if (fixedExpenses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(
            left: 16.0, right: 16.0, top: 20.0, bottom: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.inbox,
              color: AppColors.card,
              size: 40,
            ),
            Text(
              AppLocalizations.of(context)!.addNewTransactions,
              style: const TextStyle(
                color: AppColors.label,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.8,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        ...(fixedExpenses.map((expense) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: ListCardFixeds(
              onTap: onExpenseTap,
              card: expense,
              showAdditionType: true,
            ),
          );
        }).toList()),
        const SizedBox(height: 80),
      ],
    );
  }
}