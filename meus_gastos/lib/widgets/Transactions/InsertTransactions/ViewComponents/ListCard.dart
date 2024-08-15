import 'package:flutter/material.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'package:meus_gastos/services/TranslateService.dart';

class ListCard extends StatelessWidget {
  final CardModel card;
  final Function(CardModel) onTap;

  ListCard({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(card),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Translateservice.formatCurrency(card.amount, context),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Text color changed to white
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        card.category.icon,
                        size: 18,
                        color: Colors.white, // Icon color changed to white
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      Translateservice.getTranslatedCategoryUsingModel(context, card.category), // translate
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.white, // Text color changed to white
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              card.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white, // Description text color changed to white
              ),
            ),
            SizedBox(height: 2),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                DateFormat(AppLocalizations.of(context)!.dateFormat).format(card.date),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white, // Date text color changed to white
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
