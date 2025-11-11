import 'dart:io';
import 'package:meus_gastos/controllers/Purchase/ProModalAndroid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:meus_gastos/controllers/Purchase/ProModal.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/controllers/gastos_fixos/UI/ListCardFixeds.dart';
import 'package:meus_gastos/controllers/gastos_fixos/CriarGastosFixosScreen.dart';
import 'package:meus_gastos/controllers/gastos_fixos/fixedExpensesModel.dart';
import 'package:meus_gastos/controllers/gastos_fixos/fixedExpensesService.dart';
import '../../../models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart' as service;
import 'package:meus_gastos/controllers/CardDetails/DetailScreen.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:meus_gastos/controllers/Transactions/ViewComponents/ListCard.dart';

class TransactionList extends StatelessWidget {
  final List<CardModel> transactions;
  final VoidCallback onRefresh;

  const TransactionList({
    Key? key,
    required this.transactions,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              // Ícone com círculo de fundo
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.label.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.label.withOpacity(0.1),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: 36,
                  color: AppColors.label.withOpacity(0.3),
                ),
              ),
              const SizedBox(height: 12),
              // Texto existente com melhor estilo
              Text(
                AppLocalizations.of(context)!.emptyDay,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.label.withOpacity(0.6),
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.2,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final reversedTransactions = transactions.reversed.toList();
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reversedTransactions.length,
      itemBuilder: (context, index) {
        final transaction = reversedTransactions[index];
        return Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 0),
          child: ListCard(
            card: transaction,
            onTap: (selectedCard) {
              _showCupertinoModalBottomSheet(context, selectedCard);
            },
            background: AppColors.card,
          ),
        );
      },
    );
  }

  void _showCupertinoModalBottomSheet(BuildContext context, CardModel card) {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height - 70,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: DetailScreen(
            card: card,
            onAddClicked: () {
              onRefresh();
            },
            onDelete: (card) {},
          ),
        );
      },
    );
  }
}