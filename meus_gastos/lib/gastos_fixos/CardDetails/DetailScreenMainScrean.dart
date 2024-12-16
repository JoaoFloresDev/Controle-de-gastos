import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/gastos_fixos/fixedExpensesModel.dart';
import 'package:meus_gastos/gastos_fixos/fixedExpensesService.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'EditionHeaderCard.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meus_gastos/controllers/ads_review/bannerAdconstruct.dart';
import 'package:flutter/material.dart';

class DetailScreenFixedExpenses extends StatefulWidget {
  final FixedExpense card;
  final VoidCallback onAddClicked;
final void Function(FixedExpense cardFixed) onDeleteClicked;

  const DetailScreenFixedExpenses({
    super.key,
    required this.card,
    required this.onAddClicked,
    required this.onDeleteClicked,
  });

  @override
  _DetailScreen createState() => _DetailScreen();
}

class _DetailScreen extends State<DetailScreenFixedExpenses> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background1,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment
              .stretch, // Faz o cabeçalho ocupar a largura total
          children: <Widget>[
            // CustomHeader colado nos cantos da superview
            CustomHeader(
              title: AppLocalizations.of(context)!.transactionDetails,
              onCancelPressed: () {
                Navigator.of(context).pop();
              },
              onDeletePressed: () {
                // Fixedexpensesservice.deleteCard(widget.card.id);
                Future.delayed(const Duration(milliseconds: 300), () {
                  // Adiciona falso gasto normal, para que não mostre o gasto fixo no determinado período
                  widget.onDeleteClicked(widget.card);
                  // widget.onAddClicked();
                  Navigator.of(context).pop();
                });
              },
              showDeleteButton: true,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: EditionHeaderCard(
                card: widget.card,
                adicionarButtonTitle: AppLocalizations.of(context)!.update,
                onAddClicked: () {
                  widget.onAddClicked();
                  Navigator.of(context).pop();
                },
                botomPageIsVisible: false,
              ),
            ),

            const Expanded(child: SizedBox())
          ],
        ),
      ),
    );
  }
}
