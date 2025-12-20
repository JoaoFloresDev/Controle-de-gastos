import 'package:flutter/material.dart';
import 'package:meus_gastos/controllers/Transactions/TransactionsViewModel.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/services/CardServiceRefatore.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:provider/provider.dart';

class ListCardRecorrent extends StatefulWidget {
  final CardModel card;
  final Function(CardModel) onTap;
  final VoidCallback onAddClicked;

  const ListCardRecorrent({
    Key? key,
    required this.card,
    required this.onTap,
    required this.onAddClicked,
  }) : super(key: key);

  @override
  State<ListCardRecorrent> createState() => _ListCardRecorrentState();
}

class _ListCardRecorrentState extends State<ListCardRecorrent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  void adicionar() async {
    final newCard = CardModel(
      amount: widget.card.amount,
      description: widget.card.description,
      date: DateTime(
        widget.card.date.year,
        widget.card.date.month,
        widget.card.date.day,
        DateTime.now().hour,
        DateTime.now().minute,
      ),
      category: widget.card.category,
      id: CardService().generateUniqueId(),
      idFixoControl: widget.card.idFixoControl,
    );
    await context.read<TransactionsViewModel>().addCard(newCard);
    await widget.onAddClicked;
  }

  Future<void> fakeExpens(CardModel cardFix) async {
    cardFix.amount = 0;
    await context.read<TransactionsViewModel>().addCard(cardFix);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final dateFormatString = localizations?.dateFormat ?? 'dd/MM/yyyy';

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: () => widget.onTap(widget.card),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color.fromARGB(104, 44, 44, 44),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                spreadRadius: 0,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: AppColors.label.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge de "Despesa Recorrente"
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.label.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      localizations?.recurringExpenses ?? "Despesa Recorrente",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.label,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Header com categoria e valor
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Categoria com ícone
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.label.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              widget.card.category.icon,
                              size: 20,
                              color: widget.card.category.color,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  TranslateService
                                      .getTranslatedCategoryUsingModel(
                                    context,
                                    widget.card.category,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.label,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat(dateFormatString)
                                      .format(widget.card.date),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.labelPlaceholder,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Valor
                    Text(
                      TranslateService.formatCurrency(
                        widget.card.amount,
                        context,
                      ),
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w500,
                        color: AppColors.label,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),

                // Descrição (se existir)
                if (widget.card.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Divider(
                    color: AppColors.label.withOpacity(0.1),
                    thickness: 1,
                    height: 1,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2, left: 6),
                        child: Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 14,
                          color: AppColors.label.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.card.description,
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.label.withOpacity(0.85),
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                // Botões de ação
                const SizedBox(height: 12),
                Divider(
                  color: AppColors.label.withOpacity(0.1),
                  thickness: 1,
                  height: 1,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await fakeExpens(widget.card);
                          await widget.onAddClicked;
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.deletionButton,
                          foregroundColor: AppColors.label,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          localizations?.delete ?? "Deletar",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          adicionar();
                          await widget.onAddClicked;
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.button,
                          foregroundColor: AppColors.label,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          localizations?.add ?? "Adicionar",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
