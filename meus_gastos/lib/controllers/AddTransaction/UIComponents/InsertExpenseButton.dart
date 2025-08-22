import 'package:flutter/material.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';


class InsertExpenseButton extends StatelessWidget {
  final VoidCallback onPressed;
  const InsertExpenseButton({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 6),
      child: SizedBox(
        height: 60,
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.button,
            foregroundColor: AppColors.label,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ).copyWith(
            overlayColor: MaterialStateProperty.resolveWith<Color?>(
              (states) => states.contains(MaterialState.pressed)
                  ? Colors.white.withOpacity(0.1)
                  : null,
            ),
          ),
          onPressed: onPressed,
          child: const Text(
            'Inserir Despesa',
            style: TextStyle(
              color: AppColors.label,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}