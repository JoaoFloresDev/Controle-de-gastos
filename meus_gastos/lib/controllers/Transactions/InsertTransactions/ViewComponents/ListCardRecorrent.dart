import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/gastos_fixos/fixedExpensesModel.dart';
import 'package:meus_gastos/gastos_fixos/fixedExpensesService.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/services/TranslateService.dart';

class ListCardRecorrent extends StatelessWidget {
  final CardModel card;
  final Function(CardModel) onTap;
  final Future<void> onAddClicked;

  const ListCardRecorrent(
      {super.key,
      required this.card,
      required this.onTap,
      required this.onAddClicked});

  void adicionar() async {
    final newCard = CardModel(
      amount: card.amount,
      description: card.description,
      date: DateTime.now(),
      category: card.category,
      id: CardService.generateUniqueId(),
      idFixoControl: card.idFixoControl,
    );
    await CardService.addCard(newCard);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(card),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(104, 44, 44, 44),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text("${AppLocalizations.of(context)!.recurringExpenses}",
                  style: TextStyle(
                    color: AppColors.label,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Translateservice.formatCurrency(card.amount, context),
                  style: const TextStyle(
                    fontSize: 14,
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
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(0, 44, 44, 44),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        card.category.icon,
                        size: 18,
                        color: card.category.color,
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
            const SizedBox(height: 2),
                                      Divider(
                color: AppColors.cardShadow.withOpacity(0.3),
                thickness: 1,
              ),
              const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      fakeExpens(card);
                      onAddClicked;
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.deletionButton, // Cor de fundo do botão
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                    child: Text(AppLocalizations.of(context)!.delete,
                        style: TextStyle(
                          color: AppColors.label,
                          
                        )),
                  ),
                ),
                SizedBox(width: 16), // Espaço entre os botões
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      adicionar();
                      onAddClicked;
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.button, // Cor de fundo do botão
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                    child: Text(AppLocalizations.of(context)!.add,
                        style: TextStyle(
                          color: AppColors.label,
                        )),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fakeExpens(CardModel cardFix) async {
    cardFix.amount = 0;
    await CardService.addCard(cardFix);
  }
}
