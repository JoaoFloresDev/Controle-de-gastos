import 'package:flutter/material.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:meus_gastos/controllers/Transactions/InsertTransactions/ViewComponents/ListCard.dart';

class TransactionList extends StatelessWidget {
  final List<CardModel> transactions;

  const TransactionList({Key? key, required this.transactions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(
        child: Text(
          "Nenhuma transação para este dia",
          style: const TextStyle(
            color: AppColors.labelPlaceholder,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ListCard(
            card: transaction,
            onTap: (selectedCard) {
              print("Card selecionado: ${selectedCard.description}");
            },
            background: AppColors.card,
          ),
        );
      },
    );
  }
}
