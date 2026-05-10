import 'package:flutter/material.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';

/// Shimmer-style loading container, used as a generic placeholder.
class LoadingContainer extends StatefulWidget {
  const LoadingContainer({super.key});

  @override
  State<LoadingContainer> createState() => _LoadingContainerState();
}

class _LoadingContainerState extends State<LoadingContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.label.withOpacity(0.1),
                  AppColors.label.withOpacity(0.3),
                  AppColors.label.withOpacity(0.1),
                ],
                stops: [
                  _animation.value,
                  _animation.value + 0.5,
                  _animation.value + 1.0
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            width: double.infinity,
            height: 50,
          );
        },
      ),
    );
  }
}
