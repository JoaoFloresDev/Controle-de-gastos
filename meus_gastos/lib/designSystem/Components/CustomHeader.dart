import 'package:meus_gastos/designSystem/ImplDS.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WorkingHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onCancelPressed;
  final VoidCallback? onDeletePressed;
  final bool showDeleteButton;
  final Icon deleteButtonIcon;

  const WorkingHeader({
    Key? key,
    required this.title,
    this.onCancelPressed,
    this.onDeletePressed,
    this.showDeleteButton = false,
    this.deleteButtonIcon = const Icon(CupertinoIcons.delete, color: Colors.white),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue, // Altere conforme sua paleta de cores
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botão de fechar usando CupertinoButton
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.clear, color: Colors.white),
            onPressed: () {
              print("Close button pressed");
              if (onCancelPressed != null) {
                onCancelPressed!();
              } else {
                Navigator.pop(context);
              }
            },
          ),
          // Título
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Botão de deletar (ou compartilhar) usando CupertinoButton
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: showDeleteButton
                ? deleteButtonIcon
                : const SizedBox(width: 24, height: 24),
            onPressed: onDeletePressed,
          ),
        ],
      ),
    );
  }
}

class CustomHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onCancelPressed;
  final VoidCallback? onDeletePressed;
  final bool showDeleteButton;
  final Icon deleteButtonIcon; // Agora obrigatório com valor padrão

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
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botão de Cancelar
          _buildCancelButton(context),
          // Título
          _buildTitle(),
          // Botão de Deletar (opcional)
          _buildDeleteButton(context),
        ],
      ),
    );
  }

  // MARK: - Cancel Button
//mark - Cancel Button
Widget _buildCancelButton(BuildContext context) {
  return Material(
    color: Colors.transparent,
    child: IconButton(
      icon: const Icon(Icons.close, color: AppColors.label),
      onPressed: () {
        print("aqui!!!");
        Navigator.pop(context);
      },
    ),
  );
}


  // MARK: - Title
  Widget _buildTitle() {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.label,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // MARK: - Delete Button
  Widget _buildDeleteButton(BuildContext context) {
    return IconButton(
      onPressed: onDeletePressed,
      icon: showDeleteButton
          ? deleteButtonIcon
          : const Icon(Icons.delete, color: Colors.transparent),
    );
  }
}
