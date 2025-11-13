import 'package:flutter/material.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import '../fixedExpensesModel.dart';

class ListCardFixeds extends StatefulWidget {
  final FixedExpense card;
  final Function(FixedExpense) onTap;

  const ListCardFixeds({super.key, required this.card, required this.onTap});

  @override
  State<ListCardFixeds> createState() => _ListCardFixedsState();
}

class _ListCardFixedsState extends State<ListCardFixeds> with SingleTickerProviderStateMixin {
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
            color: AppColors.card,
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
                              color: AppColors.background1,
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
                                  TranslateService.getTranslatedCategoryUsingModel(
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
                                  _getRepetitionText(
                                    context,
                                    widget.card.repetitionType,
                                    widget.card.date,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16,
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
                        widget.card.price,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}