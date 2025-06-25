import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'ValorTextField.dart';
import '../VerticalCircleList.dart';
import 'HeaderBar.dart';
import 'ValueInputSection.dart';

class QuickValueButton extends StatelessWidget {
  final int value;
  final VoidCallback onTap;

  const QuickValueButton({
    super.key,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 66,
        height: 55,
        decoration: BoxDecoration(
          color: CupertinoColors.systemGreen.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: CupertinoColors.systemGreen.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '+',
              style: TextStyle(
                color: CupertinoColors.systemGreen,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '$value',
              style: const TextStyle(
                color: CupertinoColors.systemGreen,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}