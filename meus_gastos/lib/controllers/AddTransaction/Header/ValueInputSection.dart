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
import 'QuickValueButton.dart';
class ValueInputSection extends StatelessWidget {
  final GlobalKey valueKey;
  final MoneyMaskedTextController controller;

  const ValueInputSection({
    required this.valueKey,
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final quickValues = [5, 10, 20, 50, 100, 200];

    return Container(
      key: valueKey,
      decoration: BoxDecoration(
        color: CupertinoColors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: CupertinoColors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 0),
            child: ValorTextField(controller: controller),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 55,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: quickValues.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final value = quickValues[index];
                return QuickValueButton(
                  value: value,
                  onTap: () {
                    final currentValue = controller.numberValue;
                    controller.updateValue(currentValue + value);
                    if (Platform.isIOS) {
                      HapticFeedback.lightImpact();
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}