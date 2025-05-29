import 'package:flutter/material.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';

import 'package:meus_gastos/services/TranslateService.dart';

class ListCard extends StatelessWidget {
  final CardModel card;
  final Function(CardModel) onTap;
  final Color background;

  const ListCard(
      {Key? key,
      required this.card,
      required this.onTap,
      required this.background})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final dateFormatString = localizations?.dateFormat ?? 'dd/MM/yyyy';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(card),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //mark - Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Translateservice.formatCurrency(card.amount, context),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.label,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: AppColors.card,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          card.category.icon,
                          size: 16,
                          color: card.category.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Translateservice.getTranslatedCategoryUsingModel(
                            context, card.category),
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.label),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
              Divider(
                color: AppColors.cardShadow.withOpacity(0.5),
                thickness: 1,
              ),
              Row(
                children: [
                  if (card.description.isNotEmpty)
                    Expanded(
                      child: Text(
                        card.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.label,
                        ),
                      ),
                    )
                  else
                    Spacer(),
                  Text(
                    DateFormat(dateFormatString).format(card.date),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.label,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
