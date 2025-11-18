import 'package:flutter/material.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import '../fixedExpensesModel.dart';

class ListCardFixeds extends StatefulWidget {
  final FixedExpense card;
  final Function(FixedExpense) onTap;
  final bool showAdditionType;

  const ListCardFixeds({
    super.key,
    required this.card,
    required this.onTap,
    this.showAdditionType = false,
  });

  @override
  State<ListCardFixeds> createState() => _ListCardFixedsState();
}

class _ListCardFixedsState extends State<ListCardFixeds>
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

  void _handleTapDown(TapDownDetails details) => _controller.forward();
  void _handleTapUp(TapUpDetails details) => _controller.reverse();
  void _handleTapCancel() => _controller.reverse();

  Color _getAdditionTypeColor() {
    return widget.card.isAutomaticAddition
        ? const Color(0xFF4CAF50)
        : const Color(0xFFFF9800);
  }

  IconData _getAdditionTypeIcon() {
    return widget.card.isAutomaticAddition
        ? Icons.check_circle_outline
        : Icons.lightbulb_outline;
  }

  String _getAdditionTypeText(BuildContext context) {
    return widget.card.isAutomaticAddition
        ? AppLocalizations.of(context)!.automatic ?? 'Automatic'
        : AppLocalizations.of(context)!.suggestion ?? 'Suggestion';
  }

  String _getRepetitionText(
      BuildContext context, String repetition, DateTime referenceDate) {
    final DateFormat dayFormat = DateFormat('d');
    final String dayOfMonth = dayFormat.format(referenceDate);
    final localizations = AppLocalizations.of(context)!;

    switch (repetition) {
      case 'monthly':
      case 'mensal':
        return "${localizations.monthlyEveryDay} $dayOfMonth";
      case 'weekly':
      case 'semanal':
        return "${localizations.weeklyEvery} ${DateFormat.EEEE('pt_BR').format(referenceDate)}";
      case 'yearly':
      case 'anual':
        return "${localizations.yearlyEveryDay} ${DateFormat('d MMMM', 'pt_BR').format(referenceDate)}";
      case 'weekdays':
      case 'seg_sex':
        return localizations.weekdaysMondayToFriday;
      case 'daily':
      case 'diario':
        return localizations.daily;
      default:
        return "${localizations.monthlyEveryDay} $dayOfMonth";
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
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
                      if (widget.showAdditionType) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getAdditionTypeColor().withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _getAdditionTypeColor().withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getAdditionTypeIcon(),
                                size: 14,
                                color: _getAdditionTypeColor(),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getAdditionTypeText(context),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _getAdditionTypeColor(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ] else if (widget.showAdditionType) ...[
                  const SizedBox(height: 12),
                  Divider(
                    color: AppColors.label.withOpacity(0.1),
                    thickness: 1,
                    height: 1,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getAdditionTypeColor().withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getAdditionTypeColor().withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getAdditionTypeIcon(),
                          size: 16,
                          color: _getAdditionTypeColor(),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getAdditionTypeText(context),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getAdditionTypeColor(),
                          ),
                        ),
                      ],
                    ),
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