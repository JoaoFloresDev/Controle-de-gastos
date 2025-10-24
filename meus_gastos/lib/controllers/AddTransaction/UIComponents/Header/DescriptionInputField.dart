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
import 'HeaderBar.dart';
import 'ValueInputSection.dart';

class DescriptionInputField extends StatelessWidget {
  final GlobalKey descriptionKey;
  final TextEditingController controller;

  const DescriptionInputField({
    required this.descriptionKey,
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: descriptionKey,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: CupertinoColors.white.withOpacity(0.1),
        ),
      ),
      child: CupertinoTextField(
        decoration: const BoxDecoration(),
        placeholder: AppLocalizations.of(context)!.description,
        placeholderStyle: TextStyle(
          color: CupertinoColors.white.withOpacity(0.5),
          fontSize: 18,
        ),
        style: const TextStyle(
          color: CupertinoColors.white,
          fontSize: 18,
        ),
        controller: controller,
        textCapitalization: TextCapitalization.sentences,
        maxLines: 1,
        keyboardAppearance: Brightness.dark,
        textInputAction: TextInputAction.newline
      ),
    );
  }
}
