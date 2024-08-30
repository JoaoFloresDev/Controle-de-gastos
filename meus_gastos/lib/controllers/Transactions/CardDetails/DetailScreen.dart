import 'package:flutter/material.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'EditionHeaderCard.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meus_gastos/controllers/ads_review/bannerAdconstruct.dart';

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
    // Acessando as traduções diretamente no método build
    final String update = AppLocalizations.of(context)!.update;
    final String cancel = AppLocalizations.of(context)!.cancel;
    final String transactionDetails =
        AppLocalizations.of(context)!.transactionDetails;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildHeader(context, cancel, transactionDetails),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: EditionHeaderCard(
                card: widget.card,
                adicionarButtonTitle: update,
                onAddClicked: () {
                  widget.onAddClicked();
                  Navigator.of(context).pop();
                },
              ),
            ),
            Expanded(
              child: SizedBox(),
            ),
            // SizedBox(
            //   height: 60, // banner height
            //   width: double.infinity, // banner width
            //   child: BannerAdconstruct(), // banner widget
            // ),
          ],
        ),
      ),
    );
  }

  // MARK: - Header
  Widget _buildHeader(
      BuildContext context, String cancel, String transactionDetails) {
    return Padding(
      padding: EdgeInsets.all(0),
      child: Container(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCancelButton(context, cancel),
            _buildTitle(transactionDetails),
            _buildDeleteButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context, String cancelText) {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Text(
        cancelText,
        style: TextStyle(
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildTitle(String transactionDetailsText) {
    return Text(
      transactionDetailsText,
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        CardService.deleteCard(widget.card.id);
        Future.delayed(Duration(milliseconds: 300), () {
          widget.onAddClicked();
          Navigator.of(context).pop();
        });
      },
      icon: Icon(
        Icons.delete,
        color: Colors.red,
      ),
    );
  }
}
