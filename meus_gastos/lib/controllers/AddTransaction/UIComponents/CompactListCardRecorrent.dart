import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// Mocks para o código ser executável.
// No seu projeto, remova-os e use suas importações reais.
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
  State<HorizontalCompactCardList> createState() =>
      _HorizontalCompactCardListState();
}

class _HorizontalCompactCardListState extends State<HorizontalCompactCardList>
    with SingleTickerProviderStateMixin {
  late List<CardModel> _cards;
  late AnimationController _animationController;

  // Guarda o estado da animação de saída
  CardModel? _dismissingCard;
  Animation<Offset>? _slideAnimation;
  // A animação de rotação foi removida

  @override
  void initState() {
    super.initState();
    // Invertemos a lista para que o primeiro item fique no topo da pilha visual
    _cards = List<CardModel>.from(widget.cards.reversed);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    )..addStatusListener((status) {
      // Quando a animação de saída termina, remove o card da lista
      if (status == AnimationStatus.completed) {
        if (_dismissingCard != null) {
          setState(() {
            _cards.remove(_dismissingCard);
            _dismissingCard = null;
          });
        }
        _animationController.reset();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Inicia a animação de dispensa do card
  void _dismissCard(CardModel card, String action) {
    if (_animationController.isAnimating || _dismissingCard != null) return;
    
    // Define a direção da animação com base na ação
    final slideDirection = action == 'add' ? 1.0 : -1.0;

    setState(() {
      _dismissingCard = card;
      // Animação de deslize apenas na horizontal
      _slideAnimation = Tween<Offset>(
        begin: Offset.zero,
        end: Offset(slideDirection * 1.5, 0.0), // Movimento puramente horizontal
      ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
    });
    
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84, // Altura ajustada para ser mais compacta
      child: Stack(
        alignment: Alignment.topCenter,
        children: _buildCardStack(),
      ),
    );
  }

  List<Widget> _buildCardStack() {
    // Renderiza a pilha de cards, com o último da lista no topo
    return List.generate(_cards.length, (index) {
      final card = _cards[index];
      final isTopCard = index == _cards.length - 1;

      // O card sendo dispensado é tratado de forma especial
      if (card == _dismissingCard && _slideAnimation != null) {
        // A RotationTransition foi removida
        return SlideTransition(
          position: _slideAnimation!,
          child: _buildCardUI(card, isInteractive: true),
        );
      }

      // Calcula a posição do card na pilha (0 = topo)
      final stackIndex = (_cards.length - 1) - index;
      
      // Apenas os 3 cards do topo são visíveis
      if (stackIndex > 2) {
        return const SizedBox.shrink();
      }
      
      // Anima as propriedades para criar o efeito de pilha
      final scale = 1.0 - (stackIndex * 0.05);
      final topOffset = stackIndex * 8.0; // Deslocamento reduzido

      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..translate(0.0, topOffset)
          ..scale(scale),
        child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: isTopCard ? 1.0 : 1.0 - (stackIndex * 0.3),
            child: _buildCardUI(card, isInteractive: isTopCard),
        ),
      );
    }).toList();
  }

  Widget _buildCardUI(CardModel card, {required bool isInteractive}) {
    return SizedBox(
      // A altura do card é definida pelo seu conteúdo interno
      width: MediaQuery.of(context).size.width * 0.9,
      child: CompactListCardRecorrent(
        card: card,
        onTap: widget.onTap,
        onAddClicked: widget.onAddClicked,
        onAction: isInteractive
            ? (c, action) {
                if (widget.onAction != null) {
                  widget.onAction!(c, action);
                }
                _dismissCard(c, action);
              }
            : null,
      ),
    );
  }
}

// Widget do card para o código ser executável. Use o seu original no projeto.
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
      onTap: onAction == null ? null : () => onTap(card),
      child: Container(
        height: 70, // Altura fixa para o card interno
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF333333), const Color(0xFF333333)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                Positioned(
                  top: -8,
                  right: -8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    // decoration: BoxDecoration(
                    //   color: const Color.fromARGB(42, 0, 0, 0),
                    //   borderRadius: BorderRadius.circular(18),
                    // ),
                    child: const Icon(
                      CupertinoIcons.arrow_2_circlepath,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 18),
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
            if (onAction != null)
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
