import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/services/TranslateService.dart';

class HorizontalCompactCardList extends StatefulWidget {
  final List<CardModel> cards;
  final Function(CardModel) onTap;
  final Future<void> onAddClicked;
  final void Function(CardModel card, String action)? onAction;

  const HorizontalCompactCardList({
    Key? key,
    required this.cards,
    required this.onTap,
    required this.onAddClicked,
    this.onAction,
  }) : super(key: key);

  @override
  State<HorizontalCompactCardList> createState() => _HorizontalCompactCardListState();
}

class _HorizontalCompactCardListState extends State<HorizontalCompactCardList> {
  late List<CardModel> _cards;

  @override
  void initState() {
    super.initState();
    _cards = List<CardModel>.from(widget.cards);
  }

  void _removeCard(CardModel card) {
    setState(() => _cards.remove(card));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.9),
        itemCount: _cards.length,
        itemBuilder: (context, index) {
          final card = _cards[index];
          return Container(
            padding: const EdgeInsets.only(left: 0, right: 8, bottom: 12, top: 12),
            child: CompactListCardRecorrent(
              card: card,
              onTap: widget.onTap,
              onAddClicked: widget.onAddClicked,
              onAction: (CardModel c, String action) {
                if (widget.onAction != null) widget.onAction!(c, action);
                _removeCard(c);
              },
            ),
          );
        },
      ),
    );
  }
}

class CompactListCardRecorrent extends StatelessWidget {
  final CardModel card;
  final Function(CardModel) onTap;
  final Future<void> onAddClicked;
  final void Function(CardModel card, String action)? onAction;

  const CompactListCardRecorrent({
    super.key,
    required this.card,
    required this.onTap,
    required this.onAddClicked,
    this.onAction,
  });

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
    if (onAction != null) onAction!(card, 'add');
  }

  Future<void> fakeExpens() async {
    card.amount = 0;
    await CardService.addCard(card);
    await onAddClicked;
    if (onAction != null) onAction!(card, 'skip');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(card),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF333333), const Color(0xFF282828)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
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
            // Informações do Gasto
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
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Translateservice.formatCurrency(card.amount, context),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.label.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Botões de Ação
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(CupertinoIcons.xmark_circle_fill, color: Color.fromARGB(255, 255, 140, 140), size: 36),
                  onPressed: fakeExpens,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: "skip",
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(CupertinoIcons.check_mark_circled_solid, color: CupertinoColors.systemGreen, size: 36),
                  onPressed: adicionar,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: "add",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
