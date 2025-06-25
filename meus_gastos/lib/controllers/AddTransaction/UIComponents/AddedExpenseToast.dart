import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddedExpenseToast extends StatefulWidget {
  final double amount;
  final String description;
  final String category;
  final IconData? categoryIcon;

  const AddedExpenseToast({
    required this.amount,
    required this.description,
    required this.category,
    this.categoryIcon,
    super.key,
  });

  static void show({
    required BuildContext context,
    required double amount,
    required String description,
    required String category,
    IconData? categoryIcon,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    
    entry = OverlayEntry(
      builder: (_) => AddedExpenseToast(
        amount: amount,
        description: description,
        category: category,
        categoryIcon: categoryIcon,
      ),
    );
    
    overlay.insert(entry);
    
    Timer(const Duration(milliseconds: 2500), () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }

  @override
  State<AddedExpenseToast> createState() => _AddedExpenseToastState();
}

class _AddedExpenseToastState extends State<AddedExpenseToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 200),
    );

    _slide = Tween(begin: const Offset(0, -1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
    );
    
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _controller.forward();
    
    if (Platform.isIOS || Platform.isAndroid) {
      HapticFeedback.lightImpact();
    }

    Timer(const Duration(milliseconds: 2200), () => _closeToast());
  }

  void _closeToast() async {
    if (mounted) {
      await _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _getCategoryIcon() {
    if (widget.categoryIcon != null) return widget.categoryIcon!;
    
    // Ícones padrão baseados na categoria
    switch (widget.category.toLowerCase()) {
      case 'alimentação':
      case 'comida':
      case 'food':
        return CupertinoIcons.bag;
      case 'transporte':
      case 'transport':
        return CupertinoIcons.car;
      case 'saúde':
      case 'health':
        return CupertinoIcons.heart;
      case 'educação':
      case 'education':
        return CupertinoIcons.book;
      case 'entretenimento':
      case 'entertainment':
        return CupertinoIcons.game_controller;
      case 'casa':
      case 'home':
        return CupertinoIcons.house;
      default:
        return CupertinoIcons.tag;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: _buildCard(),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 26, 26, 35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Despesa adicionada',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: _closeToast,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      CupertinoIcons.xmark,
                      color: Colors.white60,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Content
            Row(
              children: [
                // Left column - Category
                Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        _getCategoryIcon(),
                        color: Colors.white70,
                        size: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.category,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                // Right column - Amount and Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'R\$ ${widget.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.description.isNotEmpty
                            ? widget.description
                            : '',
                        style: TextStyle(
                          color: widget.description.isNotEmpty
                              ? Colors.white60
                              : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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