import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class QuickValueButton extends StatefulWidget {
  final int value;
  final VoidCallback onTap;

  const QuickValueButton({
    super.key,
    required this.value,
    required this.onTap,
  });

  @override
  State<QuickValueButton> createState() => _QuickValueButtonState();
}

class _QuickValueButtonState extends State<QuickValueButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 40),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.15,
      end: 0.25,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    // Vibração tátil
    HapticFeedback.lightImpact();
    
    // Anima o botão
    await _animationController.forward();
    await _animationController.reverse();
    
    // Chama o callback
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 70,
              height: 55,
              decoration: BoxDecoration(
                color: CupertinoColors.lightBackgroundGray.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CupertinoColors.lightBackgroundGray.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '+',
                    style: TextStyle(
                      color: CupertinoColors.lightBackgroundGray,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${widget.value}',
                    style: const TextStyle(
                      color: CupertinoColors.lightBackgroundGray,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}