import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'EditionHeaderCard.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meus_gastos/controllers/ads_review/bannerAdconstruct.dart';
import 'package:flutter/material.dart';

class DetailScreen extends StatefulWidget {
  final CardModel card;
  final VoidCallback onAddClicked;

  DetailScreen({
    required this.card,
    required this.onAddClicked,
  });

  @override
  _DetailScreen createState() => _DetailScreen();
}

class _DetailScreen extends State<DetailScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        decoration: BoxDecoration(
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
                CardService.deleteCard(widget.card.id);
                Future.delayed(Duration(milliseconds: 300), () {
                  widget.onAddClicked();
                  Navigator.of(context).pop();
                });
              },
              showDeleteButton: true,
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: EditionHeaderCard(
                card: widget.card,
                adicionarButtonTitle: AppLocalizations.of(context)!.update,
                onAddClicked: () {
                  widget.onAddClicked();
                  Navigator.of(context).pop();
                },
              ),
            ),
            Expanded(child: SizedBox())
          ],
        ),
      ),
    );
  }
}
