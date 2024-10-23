import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meus_gastos/services/TranslateService.dart';

class ListCard extends StatelessWidget {
  final CardModel card;
  final Function(CardModel) onTap;

  const ListCard({super.key, required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(card),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: card.category.name == 'Recorrente' ? Colors.red.withOpacity(0.2) : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
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
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        card.category.icon,
                        size: 18,
                        color: AppColors.label,
                      ),
                    ),
                    Text(
                      Translateservice.getTranslatedCategoryUsingModel(
                          context, card.category),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.label,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    card.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.label,
                    ),
                  ),
                ),
                Text(
                  DateFormat(AppLocalizations.of(context)!.dateFormat)
                      .format(card.date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.label,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
