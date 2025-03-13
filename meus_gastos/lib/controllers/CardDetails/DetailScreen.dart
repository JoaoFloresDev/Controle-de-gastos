import 'package:meus_gastos/controllers/ads_review/constructReview.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/services/saveExpensOnCloud.dart';
import 'EditionHeaderCard.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meus_gastos/controllers/ads_review/bannerAdconstruct.dart';
import 'package:flutter/material.dart';

// await Constructreview.checkAndRequestReview();
class DetailScreen extends StatefulWidget {
  final CardModel card;
  final VoidCallback onAddClicked;

  const DetailScreen({
    super.key,
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
        decoration: const BoxDecoration(
          color: AppColors.background1,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CustomHeader(
              title: AppLocalizations.of(context)!.transactionDetails,
              onCancelPressed: () {
                // FocusScope.of(context).unfocus();
                // Navigator.of(context).pop();
              },
              onDeletePressed: () {
                CardService.deleteCard(widget.card.id);
                SaveExpensOnCloud().deleteDate(widget.card);
                Future.delayed(const Duration(milliseconds: 300), () {
                  widget.onAddClicked();
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
              ),
            ),
            const Expanded(child: SizedBox())
          ],
        ),
      ),
    );
  }
}
