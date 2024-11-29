import 'dart:io';
import 'package:meus_gastos/controllers/Purchase/ProModalAndroid.dart';
import 'package:meus_gastos/gastos_fixos/CardDetails/DetailScreenMainScrean.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:meus_gastos/controllers/Purchase/ProModal.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/gastos_fixos/ListCard.dart';
import 'package:meus_gastos/gastos_fixos/UI/criar_gastosFixos.dart';
import 'package:meus_gastos/gastos_fixos/fixedExpensesModel.dart';
import 'package:meus_gastos/gastos_fixos/fixedExpensesService.dart';
import '../../../models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart' as service;
import 'package:meus_gastos/controllers/CardDetails/DetailScreen.dart';
import 'package:meus_gastos/controllers/CategoryCreater/CategoryCreater.dart';
import 'package:meus_gastos/controllers/ads_review/constructReview.dart';
import 'package:meus_gastos/controllers/ads_review/bannerAdconstruct.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import '../../Purchase/ProModal.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:meus_gastos/controllers/Transactions/InsertTransactions/ViewComponents/ListCard.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Text(
            AppLocalizations.of(context)!.emptyDay,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.labelPlaceholder,
              fontSize: 18,
            ),
          ),
        ),
      );
    }

    final reversedTransactions = transactions.reversed.toList();
    return ListView.builder(
      itemCount: reversedTransactions.length,
      itemBuilder: (context, index) {
        final transaction = reversedTransactions[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
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
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height - 120,
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
          ),
        );
      },
    );
  }
}
