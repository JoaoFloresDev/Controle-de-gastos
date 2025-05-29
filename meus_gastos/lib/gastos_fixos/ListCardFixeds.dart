import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'fixedExpensesModel.dart';

class ListCardFixeds extends StatelessWidget {
  final FixedExpense card;
  final Function(FixedExpense) onTap;

  const ListCardFixeds({super.key, required this.card, required this.onTap});

  // MARK - Private helper methods
  String _getRepetitionText(BuildContext context, String repetition, DateTime referenceDate) {
    final DateFormat dayFormat = DateFormat('d');
    final String dayOfMonth = dayFormat.format(referenceDate);
    switch (repetition) {
      case 'mensal':
        return "${AppLocalizations.of(context)!.monthlyEveryDay} $dayOfMonth";
      case 'semanal':
        return "${AppLocalizations.of(context)!.weeklyEvery} ${DateFormat.EEEE('pt_BR').format(referenceDate)}";
      case 'anual':
        return "${AppLocalizations.of(context)!.yearlyEveryDay} ${DateFormat('d MMMM', 'pt_BR').format(referenceDate)}";
      case 'seg_sex':
        return "${AppLocalizations.of(context)!.weekdaysMondayToFriday}";
      case 'diario':
        return "${AppLocalizations.of(context)!.daily}";
      default:
        return "${AppLocalizations.of(context)!.monthlyEveryDay} $dayOfMonth";
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(card),
      child: Container(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Translateservice.formatCurrency(card.price, context),
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
                      margin: const EdgeInsets.symmetric(horizontal: 16),
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
                    Text(
                      Translateservice.getTranslatedCategoryUsingModel(context, card.category),
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
            Divider(
              color: AppColors.cardShadow.withOpacity(0.5),
                thickness: 1,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    card.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.label,
                    ),
                  ),
                ),
                Text(
                  _getRepetitionText(context, card.tipoRepeticao, card.date), // Alteração nesta linha
                  style: const TextStyle(
                    fontSize: 14,
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
