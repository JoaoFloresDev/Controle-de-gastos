import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onCancelPressed;
  final VoidCallback? onDeletePressed;
  final bool showDeleteButton;
  final Icon deleteButtonIcon;

  const CustomHeader({
    super.key,
    required this.title,
    this.onCancelPressed,
    this.onDeletePressed,
    this.showDeleteButton = false,
    this.deleteButtonIcon =
        const Icon(Icons.delete, color: AppColors.deletionButton),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.only(
        top: 16,
        bottom: 16,
        left: 20,
        right: 20,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Título centralizado
          _buildTitle(),
          // Botões nas laterais
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCancelButton(context),
              _buildDeleteButton(context),
            ],
          ),
        ],
      ),
    );
  }

  // MARK: - Cancel Button
  Widget _buildCancelButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          if (onCancelPressed != null) {
            onCancelPressed!();
          } else {
            Navigator.pop(context);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.label.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.close_rounded,
            color: AppColors.label,
            size: 20,
          ),
        ),
      ),
    );
  }

  // MARK: - Title
  Widget _buildTitle() {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.label,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
      textAlign: TextAlign.center,
    );
  }

  // MARK: - Delete Button
  Widget _buildDeleteButton(BuildContext context) {
    if (!showDeleteButton) {
      return const SizedBox(width: 36, height: 36);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onDeletePressed,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.deletionButton.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            deleteButtonIcon.icon,
            color: AppColors.deletionButton,
            size: 20,
          ),
        ),
      ),
    );
  }
}