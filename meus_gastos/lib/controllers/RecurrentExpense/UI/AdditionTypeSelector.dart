import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';

class AdditionTypeSelector extends StatelessWidget {
  const AdditionTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  final String selectedType;
  final ValueChanged<String> onTypeSelected;

  @override
  Widget build(BuildContext context) {
    // ✅ CORREÇÃO: Comparar com 'automatic' (inglês)
    final isAutomatic = selectedType == 'automatic';
    
    return GestureDetector(
      onTap: () => _showActionSheet(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isAutomatic 
                    ? CupertinoColors.activeGreen.withOpacity(0.15)
                    : CupertinoColors.systemYellow.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isAutomatic
                    ? CupertinoIcons.checkmark_circle_fill 
                    : CupertinoIcons.lightbulb_fill,
                color: isAutomatic 
                    ? CupertinoColors.activeGreen
                    : CupertinoColors.systemYellow,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAutomatic
                        ? AppLocalizations.of(context)!.automaticAddition
                        : AppLocalizations.of(context)!.suggestion,
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isAutomatic
                        ? AppLocalizations.of(context)!.automaticAdditionDescription
                        : AppLocalizations.of(context)!.suggestionDescription,
                    style: TextStyle(
                      color: CupertinoColors.white.withOpacity(0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.white.withOpacity(0.3),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  void _showActionSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text(
            AppLocalizations.of(context)!.selectAdditionTypeDescription
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                // ✅ CORREÇÃO: Enviar 'automatic' (inglês) em vez de 'automatica'
                onTypeSelected('automatic');
                Navigator.pop(context);
              },
              isDefaultAction: selectedType == 'automatic',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: CupertinoColors.activeGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      size: 20,
                      color: CupertinoColors.activeGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.automaticAddition,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: CupertinoColors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppLocalizations.of(context)!.automaticAdditionDescription,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                // ✅ CORREÇÃO: Enviar 'suggestion' (inglês) em vez de 'sugestao'
                onTypeSelected('suggestion');
                Navigator.pop(context);
              },
              isDefaultAction: selectedType == 'suggestion',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemYellow.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      CupertinoIcons.lightbulb_fill,
                      size: 20,
                      color: CupertinoColors.systemYellow,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.suggestion,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: CupertinoColors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppLocalizations.of(context)!.suggestionDescription,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                color: CupertinoColors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}