import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meus_gastos/services/TranslateService.dart';

class AddedExpenseToast extends StatefulWidget {
  final double amount;
  final String description;
  final String category;
  final IconData? categoryIcon;
  final Color? categoryIconColor;

  const AddedExpenseToast({
    required this.amount,
    required this.description,
    required this.category,
    this.categoryIcon,
    this.categoryIconColor,
    super.key,
  });

  static void show({
    required BuildContext context,
    required double amount,
    required String description,
    required String category,
    IconData? categoryIcon,
    Color? categoryIconColor,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    
    entry = OverlayEntry(
      builder: (_) => AddedExpenseToast(
        amount: amount,
        description: description,
        category: category,
        categoryIcon: categoryIcon,
        categoryIconColor: categoryIconColor,
      ),
    );
    
    overlay.insert(entry);
    
    Timer(const Duration(milliseconds: 1200), () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }

  @override
  State<AddedExpenseToast> createState() => _AddedExpenseToastState();
}

class _AddedExpenseToastState extends State<AddedExpenseToast>
    with TickerProviderStateMixin {
  late final AnimationController _slideController;
  late final AnimationController _scaleController;
  late final AnimationController _progressController;
  
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  // late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 0),
      reverseDuration: const Duration(milliseconds: 300),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slide = Tween(begin: const Offset(0, -1), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );
    
    _fade = CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic);
    
    _scale = Tween(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    // _progress = Tween(begin: 0.0, end: 1.0).animate(
    //   CurvedAnimation(parent: _progressController, curve: Curves.linear),
    // );

    _slideController.forward();
    
    Future.delayed(const Duration(milliseconds: 100), () {
      _scaleController.forward();
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      _progressController.forward();
    });
    
    if (Platform.isIOS || Platform.isAndroid) {
      HapticFeedback.lightImpact();
    }

    Timer(const Duration(milliseconds: 1400), () => _closeToast());
  }

  void _closeToast() async {
    if (mounted) {
      await _slideController.reverse();
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  IconData _getCategoryIcon() {
    if (widget.categoryIcon != null) return widget.categoryIcon!;
    switch (widget.category.toLowerCase()) {
      case 'alimentação':
      case 'comida':
      case 'food':
        return CupertinoIcons.bag_fill;
      case 'transporte':
      case 'transport':
        return CupertinoIcons.car_fill;
      case 'saúde':
      case 'health':
        return CupertinoIcons.heart_fill;
      case 'educação':
      case 'education':
        return CupertinoIcons.book_fill;
      case 'entretenimento':
      case 'entertainment':
        return CupertinoIcons.game_controller_solid;
      case 'casa':
      case 'home':
        return CupertinoIcons.house_fill;
      case 'compras':
      case 'shopping':
        return CupertinoIcons.bag_badge_plus;
      case 'lazer':
      case 'leisure':
        return CupertinoIcons.star_fill;
      default:
        return CupertinoIcons.tag_fill;
    }
  }

  Color _getCategoryColor() {
    if (widget.categoryIconColor != null) return widget.categoryIconColor!;
    switch (widget.category.toLowerCase()) {
      case 'alimentação':
      case 'comida':
      case 'food':
        return const Color(0xFF4CAF50);
      case 'transporte':
      case 'transport':
        return const Color(0xFF2196F3);
      case 'saúde':
      case 'health':
        return const Color(0xFFE91E63);
      case 'educação':
      case 'education':
        return const Color(0xFF9C27B0);
      case 'entretenimento':
      case 'entertainment':
        return const Color(0xFFFF5722);
      case 'casa':
      case 'home':
        return const Color(0xFF795548);
      case 'compras':
      case 'shopping':
        return const Color(0xFFFF9800);
      case 'lazer':
      case 'leisure':
        return const Color(0xFFFFC107);
      default:
        return const Color(0xFF607D8B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: _buildCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    final categoryColor = _getCategoryColor();
    
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1a1a23),
                  const Color(0xFF16161f),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // Category icon compacto
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: categoryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      _getCategoryIcon(),
                      color: categoryColor,
                      size: 18,
                    ),
                  ),
                  
                  const SizedBox(width: 10),
                  
                  // Details (categoria + descrição)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.category,
                          style: TextStyle(
                            color: categoryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.description.isNotEmpty) ...[
                          const SizedBox(height: 1),
                          Text(
                            widget.description,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 10),
                  
                  // Amount
                  Text(
                    '${TranslateService.getCurrencySymbol(context)} ${widget.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Close button compacto
                  GestureDetector(
                    onTap: _closeToast,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        CupertinoIcons.xmark,
                        color: Colors.white60,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}