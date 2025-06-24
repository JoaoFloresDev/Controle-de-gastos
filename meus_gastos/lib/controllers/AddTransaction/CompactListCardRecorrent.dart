import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/services/TranslateService.dart';

class CompactListCardRecorrent extends StatelessWidget {
  final CardModel card;
  final Function(CardModel) onTap;
  final Future<void> onAddClicked;

  const CompactListCardRecorrent({
    super.key,
    required this.card,
    required this.onTap,
    required this.onAddClicked,
  });

  // Ação para lançar o gasto no mês atual
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
    await onAddClicked;
  }

  // Ação para "pular" o gasto deste mês
  Future<void> fakeExpens() async {
    card.amount = 0;
    await CardService.addCard(card);
    await onAddClicked;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(card),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        decoration: BoxDecoration(
          // REFINAMENTO: Gradiente sutil para dar profundidade
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF333333), // Um pouco mais claro no topo
              const Color(0xFF282828), // Cor original na base
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Ícone da Categoria
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        card.category.color.withOpacity(0.25),
                        card.category.color.withOpacity(0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: card.category.color.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    card.category.icon,
                    size: 20,
                    color: card.category.color,
                  ),
                ),
                // Tag "Recorrente"
                Positioned(
                  top: -4,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 0, 92, 198),
                      borderRadius: BorderRadius.circular(6),
                      // border: Border.all(
                      //   color: const Color(0xFF1A1A1A),
                      //   width: 1,
                      // ),
                    ),
                    child: const Icon(
                      CupertinoIcons.arrow_2_circlepath,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),

            // Informações do Gasto (Descrição e Valor)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    card.description,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.label,
                      letterSpacing: 0.2, // REFINAMENTO: Leve espaçamento para legibilidade
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Translateservice.formatCurrency(card.amount, context),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500, // REFINAMENTO: Peso um pouco maior para o valor
                      color: AppColors.label.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Botões de Ação (com Ícones)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Botão "Pular"
                IconButton(
                  // REFINAMENTO: Ícone preenchido para maior peso visual
                  icon: const Icon(CupertinoIcons.xmark_circle_fill, color: Color.fromARGB(255, 255, 140, 140), size: 24),
                  onPressed: fakeExpens,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: "skip",
                ),
                const SizedBox(width: 8),
                
                // Botão "Lançar/Adicionar"
                IconButton(
                  // REFINAMENTO: Ícone preenchido para maior peso visual e clareza
                  icon: const Icon(CupertinoIcons.check_mark_circled_solid, color: CupertinoColors.systemGreen, size: 24),
                  onPressed: adicionar,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: AppLocalizations.of(context)!.add,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}