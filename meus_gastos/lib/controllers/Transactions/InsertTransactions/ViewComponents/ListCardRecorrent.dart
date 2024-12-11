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
      date: card.date,
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
          color: AppColors.background1,
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
            Align(
              alignment: Alignment.center,
              child: Text("${AppLocalizations.of(context)!.recurringExpenses}",
                  style: TextStyle(
                    color: AppColors.label,
                  )),
            ),
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
                      decoration: const BoxDecoration(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    // Ação do botão excluir
                    print('Excluir pressionado');

                    fakeExpens(card);
                    onAddClicked;
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Cor de fundo do botão
                  ),
                  child: Text('Excluir',
                      style: TextStyle(
                        color: AppColors.label,
                      )),
                ),
                SizedBox(width: 16), // Espaço entre os botões
                ElevatedButton(
                  onPressed: () {
                    // Ação do botão adicionar
                    print('Adicionar pressionado');
                    adicionar();
                    onAddClicked;
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Cor de fundo do botão
                  ),
                  child: Text('Adicionar',
                      style: TextStyle(
                        color: AppColors.label,
                      )),
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
